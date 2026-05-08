using AutoMapper;
using Microsoft.AspNetCore.Identity;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Application.DTOs.Auth;
using TaskFlow.Application.DTOs.Users;
using TaskFlow.Domain.Entities;
using TaskFlow.Domain.Exceptions;

namespace TaskFlow.Application.UseCases.Auth;

public interface IAuthService
{
	Task<AuthResponse> RegisterAsync(RegisterRequest req, CancellationToken ct);
	Task<AuthResponse> LoginAsync(LoginRequest req, string? ip, CancellationToken ct);
	Task<AuthResponse> RefreshAsync(RefreshRequest req, string? ip, CancellationToken ct);
	Task LogoutAsync(RefreshRequest req, CancellationToken ct);
	Task ForgotPasswordAsync(ForgotPasswordRequest req, CancellationToken ct);
	Task<OtpVerifiedResponse> VerifyOtpAsync(VerifyOtpRequest req, CancellationToken ct);
	Task ResetPasswordAsync(ResetPasswordRequest req, CancellationToken ct);
}

public class AuthService : IAuthService
{
	private readonly UserManager<User> _users;
	private readonly SignInManager<User> _signIn;
	private readonly IUnitOfWork _uow;
	private readonly IJwtTokenService _jwt;
	private readonly IOtpService _otp;
	private readonly IEmailService _email;
	private readonly IMapper _mapper;

	public AuthService(UserManager<User> users, SignInManager<User> signIn, IUnitOfWork uow,
		IJwtTokenService jwt, IOtpService otp, IEmailService email, IMapper mapper)
	{ _users = users; _signIn = signIn; _uow = uow; _jwt = jwt; _otp = otp; _email = email; _mapper = mapper; }

	public async Task<AuthResponse> RegisterAsync(RegisterRequest req, CancellationToken ct)
	{
		if (await _users.FindByEmailAsync(req.Email) is not null)
			throw new ConflictException("Email is already registered.");

		var user = new User
		{
			UserName = req.Email, Email = req.Email,
			FullName = req.FullName, AvatarUrl = req.AvatarUrl,
			EmailConfirmed = true
		};
		var res = await _users.CreateAsync(user, req.Password);
		if (!res.Succeeded) throw new DomainException(string.Join("; ", res.Errors.Select(e => e.Description)));

		return await IssueTokensAsync(user, null, ct);
	}

	public async Task<AuthResponse> LoginAsync(LoginRequest req, string? ip, CancellationToken ct)
	{
		var user = await _users.FindByEmailAsync(req.Email)
			?? throw new ForbiddenException("Invalid credentials.");
		var ok = await _signIn.CheckPasswordSignInAsync(user, req.Password, true);
		if (!ok.Succeeded) throw new ForbiddenException("Invalid credentials.");

		user.LastLoginAt = DateTime.UtcNow;
		await _users.UpdateAsync(user);
		return await IssueTokensAsync(user, ip, ct);
	}

	public async Task<AuthResponse> RefreshAsync(RefreshRequest req, string? ip, CancellationToken ct)
	{
		var hash = _jwt.HashToken(req.RefreshToken);
		var token = (await _uow.RefreshTokens.FindAsync(t => t.TokenHash == hash, ct)).FirstOrDefault()
			?? throw new ForbiddenException("Invalid refresh token.");
		if (!token.IsActive) throw new ForbiddenException("Refresh token is no longer active.");

		var user = await _users.FindByIdAsync(token.UserId.ToString())
			?? throw new NotFoundException(nameof(User), token.UserId);

		token.RevokedAt = DateTime.UtcNow;
		var fresh = await IssueTokensAsync(user, ip, ct);
		token.ReplacedByTokenHash = _jwt.HashToken(fresh.RefreshToken);
		_uow.RefreshTokens.Update(token);
		await _uow.SaveChangesAsync(ct);
		return fresh;
	}

	public async Task LogoutAsync(RefreshRequest req, CancellationToken ct)
	{
		var hash = _jwt.HashToken(req.RefreshToken);
		var token = (await _uow.RefreshTokens.FindAsync(t => t.TokenHash == hash, ct)).FirstOrDefault();
		if (token is null || !token.IsActive) return;
		token.RevokedAt = DateTime.UtcNow;
		_uow.RefreshTokens.Update(token);
		await _uow.SaveChangesAsync(ct);
	}

	public async Task ForgotPasswordAsync(ForgotPasswordRequest req, CancellationToken ct)
	{
		var user = await _users.FindByEmailAsync(req.Email);
		if (user is null) return; // do not leak existence
		var code = await _otp.CreateAsync(req.Email, "password_reset", ct);
		await _email.SendAsync(req.Email, "Task-Flow password reset",
			$"<p>Your verification code is <b>{code}</b>. It expires in 10 minutes.</p>", ct);
	}

	public async Task<OtpVerifiedResponse> VerifyOtpAsync(VerifyOtpRequest req, CancellationToken ct)
	{
		var ok = await _otp.VerifyAsync(req.Email, req.Code, "password_reset", ct);
		if (!ok) throw new ForbiddenException("Invalid or expired OTP.");

		var user = await _users.FindByEmailAsync(req.Email)
			?? throw new NotFoundException(nameof(User), req.Email);
		var resetToken = await _users.GeneratePasswordResetTokenAsync(user);
		return new OtpVerifiedResponse(resetToken, DateTime.UtcNow.AddMinutes(15));
	}

	public async Task ResetPasswordAsync(ResetPasswordRequest req, CancellationToken ct)
	{
		var user = await _users.FindByEmailAsync(req.Email)
			?? throw new NotFoundException(nameof(User), req.Email);
		var res = await _users.ResetPasswordAsync(user, req.ResetToken, req.NewPassword);
		if (!res.Succeeded) throw new DomainException(string.Join("; ", res.Errors.Select(e => e.Description)));
	}

	private async Task<AuthResponse> IssueTokensAsync(User user, string? ip, CancellationToken ct)
	{
		var roles = await _users.GetRolesAsync(user);
		var (access, accessExp) = _jwt.GenerateAccessToken(user, roles);
		var (raw, hash, refreshExp) = _jwt.GenerateRefreshToken();

		await _uow.RefreshTokens.AddAsync(new RefreshToken
		{ UserId = user.Id, TokenHash = hash, ExpiresAt = refreshExp, CreatedByIp = ip }, ct);
		await _uow.SaveChangesAsync(ct);

		return new AuthResponse(access, raw, accessExp, _mapper.Map<UserDto>(user));
	}
}

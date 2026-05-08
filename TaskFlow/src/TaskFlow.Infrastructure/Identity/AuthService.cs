using Microsoft.AspNetCore.Identity;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Application.DTOs.Auth;
using TaskFlow.Application.Interfaces;
using TaskFlow.Domain.Entities;
using TaskFlow.Shared.Wrappers;

namespace TaskFlow.Infrastructure.Identity;

public class AuthService : IAuthService
{
    private readonly UserManager<User> _userManager;
    private readonly RoleManager<IdentityRole<Guid>> _roleManager;
    private readonly IJwtTokenService _jwtTokenService;

    public AuthService(
        UserManager<User> userManager, 
        RoleManager<IdentityRole<Guid>> roleManager,
        IJwtTokenService jwtTokenService)
    {
        _userManager = userManager;
        _roleManager = roleManager;
        _jwtTokenService = jwtTokenService;
    }

    public async Task<ApiResponse<AuthResponse>> RegisterAsync(RegisterRequest request)
    {
        var userExists = await _userManager.FindByEmailAsync(request.Email);
        if (userExists != null)
            return ApiResponse<AuthResponse>.Fail("User with this email already exists.");

        var user = new User
        {
            UserName = request.Email,
            Email = request.Email,
            FullName = request.FullName,
            CreatedAt = DateTime.UtcNow
        };

        var result = await _userManager.CreateAsync(user, request.Password);
        if (!result.Succeeded)
            return ApiResponse<AuthResponse>.Fail(result.Errors.Select(e => e.Description).ToList());

        var roles = new List<string> { "Member" };
        foreach (var roleName in roles)
        {
            if (!await _roleManager.RoleExistsAsync(roleName))
            {
                await _roleManager.CreateAsync(new IdentityRole<Guid>(roleName));
            }
        }
        await _userManager.AddToRolesAsync(user, roles);

        var (token, tokenExp) = _jwtTokenService.GenerateAccessToken(user, roles);
        var (refreshToken, _, refreshExp) = _jwtTokenService.GenerateRefreshToken();

        var response = new AuthResponse(
            token,
            refreshToken,
            tokenExp,
            new UserDto(user.Id, user.FullName, user.Email!, user.AvatarUrl, "Member")
        );

        return ApiResponse<AuthResponse>.Success(response, "User registered successfully.");
    }

    public async Task<ApiResponse<AuthResponse>> LoginAsync(LoginRequest request)
    {
        var user = await _userManager.FindByEmailAsync(request.Email);
        if (user == null || !await _userManager.CheckPasswordAsync(user, request.Password))
            return ApiResponse<AuthResponse>.Fail("Invalid email or password.");

        var roles = await _userManager.GetRolesAsync(user);
        var (token, tokenExp) = _jwtTokenService.GenerateAccessToken(user, roles);
        var (refreshToken, _, refreshExp) = _jwtTokenService.GenerateRefreshToken();

        var response = new AuthResponse(
            token,
            refreshToken,
            tokenExp,
            new UserDto(user.Id, user.FullName, user.Email!, user.AvatarUrl, roles.FirstOrDefault() ?? "Member")
        );

        return ApiResponse<AuthResponse>.Success(response, "Login successful.");
    }
}

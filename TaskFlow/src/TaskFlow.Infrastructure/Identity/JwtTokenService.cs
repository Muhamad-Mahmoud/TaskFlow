using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Infrastructure.Identity;

public class JwtTokenService : IJwtTokenService
{
	private readonly JwtSettings _s;
	public JwtTokenService(IOptions<JwtSettings> opts) { _s = opts.Value; }

	public (string AccessToken, DateTime ExpiresAt) GenerateAccessToken(User user, IList<string> roles)
	{
		var claims = new List<Claim>
		{
			new(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
			new(JwtRegisteredClaimNames.Email, user.Email ?? ""),
			new("name", user.FullName),
			new("role", user.Role.ToString()),
			new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
		};
		claims.AddRange(roles.Select(r => new Claim(ClaimTypes.Role, r)));

		var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_s.SecretKey));
		var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
		var expires = DateTime.UtcNow.AddMinutes(_s.AccessTokenMinutes);

		var jwt = new JwtSecurityToken(
			issuer: _s.Issuer, audience: _s.Audience,
			claims: claims, expires: expires, signingCredentials: creds);

		return (new JwtSecurityTokenHandler().WriteToken(jwt), expires);
	}

	public (string RawToken, string Hash, DateTime ExpiresAt) GenerateRefreshToken()
	{
		var bytes = RandomNumberGenerator.GetBytes(64);
		var raw = Convert.ToBase64String(bytes);
		return (raw, HashToken(raw), DateTime.UtcNow.AddDays(_s.RefreshTokenDays));
	}

	public string HashToken(string raw)
	{
		using var sha = SHA256.Create();
		return Convert.ToHexString(sha.ComputeHash(Encoding.UTF8.GetBytes(raw)));
	}
}

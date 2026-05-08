namespace TaskFlow.Infrastructure.Identity;

public class JwtSettings
{
	public string Issuer { get; set; } = default!;
	public string Audience { get; set; } = default!;
	public string SecretKey { get; set; } = default!;
	public int AccessTokenMinutes { get; set; } = 15;
	public int RefreshTokenDays { get; set; } = 7;
}

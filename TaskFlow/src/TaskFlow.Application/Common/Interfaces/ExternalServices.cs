using TaskFlow.Domain.Entities;

namespace TaskFlow.Application.Common.Interfaces;

public interface ICurrentUserService
{
	Guid? UserId { get; }
	string? Email { get; }
	bool IsAuthenticated { get; }
}

public interface IJwtTokenService
{
	(string AccessToken, DateTime ExpiresAt) GenerateAccessToken(User user, IList<string> roles);
	(string RawToken, string Hash, DateTime ExpiresAt) GenerateRefreshToken();
	string HashToken(string raw);
}

public interface IEmailService
{
	Task SendAsync(string to, string subject, string htmlBody, CancellationToken ct = default);
}

public interface IOtpService
{
	Task<string> CreateAsync(string email, string purpose, CancellationToken ct = default);
	Task<bool> VerifyAsync(string email, string code, string purpose, CancellationToken ct = default);
}

public interface IFileStorageService
{
	Task<(string Url, string FileName, string MimeType, long Size)> UploadAsync(
		Stream stream, string fileName, string contentType, CancellationToken ct = default);
	Task DeleteAsync(string url, CancellationToken ct = default);
}

public interface IPushNotificationService
{
	Task SendToUserAsync(Guid userId, string title, string body,
		IDictionary<string, string>? data = null, CancellationToken ct = default);
}

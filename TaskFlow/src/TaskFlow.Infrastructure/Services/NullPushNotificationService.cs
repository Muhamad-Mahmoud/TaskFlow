using TaskFlow.Application.Common.Interfaces;

namespace TaskFlow.Infrastructure.Services;

/// <summary>
/// No-op push notification service used until FCM is fully configured.
/// Replace this registration with FcmPushNotificationService once
/// the Firebase service-account JSON path is set in appsettings.
/// </summary>
public sealed class NullPushNotificationService : IPushNotificationService
{
    public Task SendToUserAsync(Guid userId, string title, string body,
        IDictionary<string, string>? data = null, CancellationToken ct = default)
        => Task.CompletedTask;
}

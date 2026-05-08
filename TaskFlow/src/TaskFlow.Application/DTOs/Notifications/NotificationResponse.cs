namespace TaskFlow.Application.DTOs.Notifications;

public record NotificationResponse(
    Guid Id,
    string Type,
    string Message,
    bool IsRead,
    DateTime CreatedAt);

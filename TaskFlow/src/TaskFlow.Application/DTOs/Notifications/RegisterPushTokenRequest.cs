namespace TaskFlow.Application.DTOs.Notifications;

public record RegisterPushTokenRequest(string Token, string Platform, string DeviceId);

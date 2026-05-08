namespace TaskFlow.Application.DTOs.Users;

public record UserSummary(
    Guid Id,
    string FullName,
    string Email,
    string? AvatarUrl);

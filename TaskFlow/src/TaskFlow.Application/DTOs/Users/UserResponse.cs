namespace TaskFlow.Application.DTOs.Users;

public record UserResponse(
    Guid Id,
    string FullName,
    string Email,
    string Role,
    string? AvatarUrl,
    DateTime CreatedAt,
    DateTime UpdatedAt);

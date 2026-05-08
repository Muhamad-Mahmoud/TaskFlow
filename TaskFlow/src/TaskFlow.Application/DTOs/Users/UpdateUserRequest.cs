namespace TaskFlow.Application.DTOs.Users;

public record UpdateUserRequest(
    string FullName,
    string? AvatarUrl);

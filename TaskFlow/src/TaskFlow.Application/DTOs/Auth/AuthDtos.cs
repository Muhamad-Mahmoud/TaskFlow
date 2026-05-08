namespace TaskFlow.Application.DTOs.Auth;

public record RegisterRequest(
    string FullName,
    string Email,
    string Password,
    string ConfirmPassword,
    string? AvatarUrl
);

public record LoginRequest(
    string Email,
    string Password
);

public record AuthResponse(
    string Token,
    string RefreshToken,
    DateTime ExpiresAt,
    UserDto User
);

public record UserDto(
    Guid Id,
    string FullName,
    string Email,
    string? AvatarUrl,
    string Role
);

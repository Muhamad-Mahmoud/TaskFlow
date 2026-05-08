namespace TaskFlow.Application.DTOs.Auth;

public record ResetPasswordRequest(string Email, string ResetToken, string NewPassword);

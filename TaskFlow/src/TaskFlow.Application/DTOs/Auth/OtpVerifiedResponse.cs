namespace TaskFlow.Application.DTOs.Auth;

public record OtpVerifiedResponse(string Token, DateTime ExpiresAt);

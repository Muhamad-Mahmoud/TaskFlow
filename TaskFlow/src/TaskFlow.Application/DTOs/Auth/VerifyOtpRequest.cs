namespace TaskFlow.Application.DTOs.Auth;

public record VerifyOtpRequest(string Email, string Code);

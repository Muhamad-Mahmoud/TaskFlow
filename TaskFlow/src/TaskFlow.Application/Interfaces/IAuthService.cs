using TaskFlow.Application.DTOs.Auth;
using TaskFlow.Shared.Wrappers;

namespace TaskFlow.Application.Interfaces;

public interface IAuthService
{
    Task<ApiResponse<AuthResponse>> RegisterAsync(RegisterRequest request);
    Task<ApiResponse<AuthResponse>> LoginAsync(LoginRequest request);
}

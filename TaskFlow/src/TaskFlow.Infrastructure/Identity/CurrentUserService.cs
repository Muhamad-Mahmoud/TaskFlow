using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using TaskFlow.Application.Common.Interfaces;

namespace TaskFlow.Infrastructure.Identity;

public class CurrentUserService : ICurrentUserService
{
	private readonly IHttpContextAccessor _http;
	public CurrentUserService(IHttpContextAccessor http) { _http = http; }

	public Guid? UserId
	{
		get
		{
			var id = _http.HttpContext?.User.FindFirstValue(ClaimTypes.NameIdentifier)
				  ?? _http.HttpContext?.User.FindFirstValue("sub");
			return Guid.TryParse(id, out var g) ? g : null;
		}
	}

	public string? Email => _http.HttpContext?.User.FindFirstValue(ClaimTypes.Email);
	public bool IsAuthenticated => _http.HttpContext?.User.Identity?.IsAuthenticated ?? false;
}

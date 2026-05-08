using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TaskFlow.Application.DTOs.Notifications;
using TaskFlow.Application.UseCases;
using TaskFlow.Shared.Wrappers;

namespace TaskFlow.API.Controllers.V1;

[ApiController] [Authorize]
[Route("api/v1/notifications")]
public class NotificationsController : ControllerBase
{
	private readonly INotificationService _svc;
	public NotificationsController(INotificationService svc) { _svc = svc; }

	[HttpGet]
	public async Task<ActionResult<ApiResponse<PagedResult<NotificationResponse>>>> List(
		[FromQuery] int page = 1, [FromQuery] int pageSize = 20, CancellationToken ct = default)
		=> Ok(ApiResponse<PagedResult<NotificationResponse>>.Ok(await _svc.ListAsync(page, pageSize, ct)));

	[HttpPatch("{id:guid}/read")]
	public async Task<ActionResult<ApiResponse<object>>> Read(Guid id, CancellationToken ct)
	{ await _svc.MarkReadAsync(id, ct); return Ok(ApiResponse<object>.Ok(new { })); }

	[HttpPost("read-all")]
	public async Task<ActionResult<ApiResponse<object>>> ReadAll(CancellationToken ct)
	{ await _svc.MarkAllReadAsync(ct); return Ok(ApiResponse<object>.Ok(new { })); }

	[HttpDelete("{id:guid}")]
	public async Task<ActionResult<ApiResponse<object>>> Delete(Guid id, CancellationToken ct)
	{ await _svc.DeleteAsync(id, ct); return Ok(ApiResponse<object>.Ok(new { })); }

	[HttpPost("push-token")]
	public async Task<ActionResult<ApiResponse<object>>> Register([FromBody] RegisterPushTokenRequest req, CancellationToken ct)
	{ await _svc.RegisterPushTokenAsync(req, ct); return Ok(ApiResponse<object>.Ok(new { }, "Token registered.")); }
}

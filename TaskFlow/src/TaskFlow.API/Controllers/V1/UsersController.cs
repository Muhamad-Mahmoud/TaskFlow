using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TaskFlow.Application.DTOs.Users;
using TaskFlow.Application.UseCases;
using TaskFlow.Shared.Wrappers;

namespace TaskFlow.API.Controllers.V1;

[ApiController] [Authorize]
[Route("api/v1/users")]
public class UsersController : ControllerBase
{
	private readonly IUserService _users;
	public UsersController(IUserService users) { _users = users; }

	[HttpGet("me")]
	public async Task<ActionResult<ApiResponse<UserResponse>>> Me(CancellationToken ct)
		=> Ok(ApiResponse<UserResponse>.Ok(await _users.GetMeAsync(ct)));

	[HttpPut("me")]
	public async Task<ActionResult<ApiResponse<UserResponse>>> Update([FromBody] UpdateUserRequest req, CancellationToken ct)
		=> Ok(ApiResponse<UserResponse>.Ok(await _users.UpdateMeAsync(req, ct)));

	[HttpGet("me/stats")]
	public async Task<ActionResult<ApiResponse<UserStatsResponse>>> Stats(CancellationToken ct)
		=> Ok(ApiResponse<UserStatsResponse>.Ok(await _users.GetMyStatsAsync(ct)));

	[HttpPost("me/avatar")]
	public async Task<ActionResult<ApiResponse<AvatarResponse>>> Avatar(IFormFile file, CancellationToken ct)
	{
		if (file is null || file.Length == 0) return BadRequest(ApiResponse<AvatarResponse>.Fail("File required."));
		await using var s = file.OpenReadStream();
		return Ok(ApiResponse<AvatarResponse>.Ok(await _users.UploadAvatarAsync(s, file.FileName, file.ContentType, ct)));
	}

	[HttpGet("search")]
	public async Task<ActionResult<ApiResponse<IReadOnlyList<UserSummary>>>> Search([FromQuery] string q, CancellationToken ct)
		=> Ok(ApiResponse<IReadOnlyList<UserSummary>>.Ok(await _users.SearchAsync(q, ct)));
}

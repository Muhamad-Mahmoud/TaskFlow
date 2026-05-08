using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TaskFlow.Application.DTOs.Comments;
using TaskFlow.Application.UseCases;
using TaskFlow.Shared.Wrappers;

namespace TaskFlow.API.Controllers.V1;

[ApiController] [Authorize]
[Route("api/v1/tasks/{taskId:guid}/comments")]
public class CommentsController : ControllerBase
{
	private readonly ICommentService _svc;
	public CommentsController(ICommentService svc) { _svc = svc; }

	[HttpGet]
	public async Task<ActionResult<ApiResponse<IReadOnlyList<CommentResponse>>>> List(Guid taskId, CancellationToken ct)
		=> Ok(ApiResponse<IReadOnlyList<CommentResponse>>.Ok(await _svc.ListAsync(taskId, ct)));

	[HttpPost]
	public async Task<ActionResult<ApiResponse<CommentResponse>>> Create(Guid taskId, [FromBody] CreateCommentRequest req, CancellationToken ct)
		=> Ok(ApiResponse<CommentResponse>.Ok(await _svc.CreateAsync(taskId, req, ct)));

	[HttpDelete("{cid:guid}")]
	public async Task<ActionResult<ApiResponse<object>>> Delete(Guid taskId, Guid cid, CancellationToken ct)
	{ await _svc.DeleteAsync(taskId, cid, ct); return Ok(ApiResponse<object>.Ok(new { })); }
}

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TaskFlow.Application.DTOs.Tasks;
using TaskFlow.Application.UseCases.Tasks;
using TaskFlow.Shared.Wrappers;

namespace TaskFlow.API.Controllers.V1;

[ApiController] [Authorize]
[Route("api/v1")]
public class TasksController : ControllerBase
{
	private readonly ITaskService _svc;
	public TasksController(ITaskService svc) { _svc = svc; }

	[HttpGet("projects/{projectId:guid}/tasks")]
	public async Task<ActionResult<ApiResponse<IReadOnlyList<TaskSummary>>>> ListByProject(Guid projectId, CancellationToken ct)
		=> Ok(ApiResponse<IReadOnlyList<TaskSummary>>.Ok(await _svc.ListByProjectAsync(projectId, ct)));

	[HttpGet("tasks")]
	public async Task<ActionResult<ApiResponse<PagedResult<TaskSummary>>>> List(
		[FromQuery] Guid? projectId, [FromQuery] int page = 1, [FromQuery] int pageSize = 20, CancellationToken ct = default)
		=> Ok(ApiResponse<PagedResult<TaskSummary>>.Ok(await _svc.ListAsync(page, pageSize, projectId, ct)));

	[HttpPost("tasks")]
	public async Task<ActionResult<ApiResponse<TaskDetailResponse>>> Create([FromBody] CreateTaskRequest req, CancellationToken ct)
		=> Ok(ApiResponse<TaskDetailResponse>.Ok(await _svc.CreateAsync(req, ct)));

	[HttpGet("tasks/{id:guid}")]
	public async Task<ActionResult<ApiResponse<TaskDetailResponse>>> Get(Guid id, CancellationToken ct)
		=> Ok(ApiResponse<TaskDetailResponse>.Ok(await _svc.GetAsync(id, ct)));

	[HttpPut("tasks/{id:guid}")]
	public async Task<ActionResult<ApiResponse<TaskResponse>>> Update(Guid id, [FromBody] UpdateTaskRequest req, CancellationToken ct)
		=> Ok(ApiResponse<TaskResponse>.Ok(await _svc.UpdateAsync(id, req, ct)));

	[HttpPatch("tasks/{id:guid}/status")]
	public async Task<ActionResult<ApiResponse<object>>> Status(Guid id, [FromBody] UpdateStatusRequest req, CancellationToken ct)
	{ await _svc.UpdateStatusAsync(id, req, ct); return Ok(ApiResponse<object>.Ok(new { })); }

	[HttpPatch("tasks/{id:guid}/position")]
	public async Task<ActionResult<ApiResponse<object>>> Reorder(Guid id, [FromBody] ReorderTaskRequest req, CancellationToken ct)
	{ await _svc.ReorderAsync(id, req, ct); return Ok(ApiResponse<object>.Ok(new { })); }

	[HttpDelete("tasks/{id:guid}")]
	public async Task<ActionResult<ApiResponse<object>>> Delete(Guid id, CancellationToken ct)
	{ await _svc.DeleteAsync(id, ct); return Ok(ApiResponse<object>.Ok(new { })); }

	[HttpPost("tasks/{id:guid}/subtasks")]
	public async Task<ActionResult<ApiResponse<SubtaskResponse>>> AddSubtask(Guid id, [FromBody] CreateSubtaskRequest req, CancellationToken ct)
		=> Ok(ApiResponse<SubtaskResponse>.Ok(await _svc.AddSubtaskAsync(id, req, ct)));

	[HttpPatch("tasks/{id:guid}/subtasks/{sid:guid}")]
	public async Task<ActionResult<ApiResponse<SubtaskResponse>>> UpdateSubtask(Guid id, Guid sid, [FromBody] UpdateSubtaskRequest req, CancellationToken ct)
		=> Ok(ApiResponse<SubtaskResponse>.Ok(await _svc.UpdateSubtaskAsync(id, sid, req, ct)));

	[HttpDelete("tasks/{id:guid}/subtasks/{sid:guid}")]
	public async Task<ActionResult<ApiResponse<object>>> DeleteSubtask(Guid id, Guid sid, CancellationToken ct)
	{ await _svc.DeleteSubtaskAsync(id, sid, ct); return Ok(ApiResponse<object>.Ok(new { })); }
}

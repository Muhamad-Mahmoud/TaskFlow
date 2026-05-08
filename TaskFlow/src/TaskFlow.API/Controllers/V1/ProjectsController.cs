using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TaskFlow.Application.DTOs.Projects;
using TaskFlow.Application.UseCases.Projects;
using TaskFlow.Shared.Wrappers;

namespace TaskFlow.API.Controllers.V1;

[ApiController] [Authorize]
[Route("api/v1/projects")]
public class ProjectsController : ControllerBase
{
	private readonly IProjectService _svc;
	public ProjectsController(IProjectService svc) { _svc = svc; }

	[HttpGet]
	public async Task<ActionResult<ApiResponse<PagedResult<ProjectSummary>>>> List(
		[FromQuery] int page = 1, [FromQuery] int pageSize = 20, CancellationToken ct = default)
		=> Ok(ApiResponse<PagedResult<ProjectSummary>>.Ok(await _svc.ListAsync(page, pageSize, ct)));

	[HttpPost]
	public async Task<ActionResult<ApiResponse<ProjectResponse>>> Create([FromBody] CreateProjectRequest req, CancellationToken ct)
		=> Ok(ApiResponse<ProjectResponse>.Ok(await _svc.CreateAsync(req, ct)));

	[HttpGet("{id:guid}")]
	public async Task<ActionResult<ApiResponse<ProjectResponse>>> Get(Guid id, CancellationToken ct)
		=> Ok(ApiResponse<ProjectResponse>.Ok(await _svc.GetAsync(id, ct)));

	[HttpPut("{id:guid}")]
	public async Task<ActionResult<ApiResponse<ProjectResponse>>> Update(Guid id, [FromBody] UpdateProjectRequest req, CancellationToken ct)
		=> Ok(ApiResponse<ProjectResponse>.Ok(await _svc.UpdateAsync(id, req, ct)));

	[HttpDelete("{id:guid}")]
	public async Task<ActionResult<ApiResponse<object>>> Delete(Guid id, CancellationToken ct)
	{ await _svc.DeleteAsync(id, ct); return Ok(ApiResponse<object>.Ok(new { })); }

	[HttpGet("{id:guid}/stats")]
	public async Task<ActionResult<ApiResponse<ProjectStatsResponse>>> Stats(Guid id, CancellationToken ct)
		=> Ok(ApiResponse<ProjectStatsResponse>.Ok(await _svc.GetStatsAsync(id, ct)));

	[HttpPost("{id:guid}/members")]
	public async Task<ActionResult<ApiResponse<ProjectMemberResponse>>> Invite(Guid id, [FromBody] InviteMemberRequest req, CancellationToken ct)
		=> Ok(ApiResponse<ProjectMemberResponse>.Ok(await _svc.InviteMemberAsync(id, req, ct)));

	[HttpPatch("{id:guid}/members/{userId:guid}")]
	public async Task<ActionResult<ApiResponse<ProjectMemberResponse>>> ChangeRole(
		Guid id, Guid userId, [FromBody] ChangeMemberRoleRequest req, CancellationToken ct)
		=> Ok(ApiResponse<ProjectMemberResponse>.Ok(await _svc.ChangeMemberRoleAsync(id, userId, req, ct)));

	[HttpDelete("{id:guid}/members/{userId:guid}")]
	public async Task<ActionResult<ApiResponse<object>>> RemoveMember(Guid id, Guid userId, CancellationToken ct)
	{ await _svc.RemoveMemberAsync(id, userId, ct); return Ok(ApiResponse<object>.Ok(new { })); }
}

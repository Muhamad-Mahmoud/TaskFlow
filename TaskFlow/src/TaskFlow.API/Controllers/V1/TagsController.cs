using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TaskFlow.Application.DTOs.Tags;
using TaskFlow.Application.UseCases;
using TaskFlow.Shared.Wrappers;

namespace TaskFlow.API.Controllers.V1;

[ApiController] [Authorize]
[Route("api/v1/tags")]
public class TagsController : ControllerBase
{
	private readonly ITagService _svc;
	public TagsController(ITagService svc) { _svc = svc; }

	[HttpGet]
	public async Task<ActionResult<ApiResponse<IReadOnlyList<TagResponse>>>> List(CancellationToken ct)
		=> Ok(ApiResponse<IReadOnlyList<TagResponse>>.Ok(await _svc.ListAsync(ct)));

	[HttpPost]
	public async Task<ActionResult<ApiResponse<TagResponse>>> Create([FromBody] CreateTagRequest req, CancellationToken ct)
		=> Ok(ApiResponse<TagResponse>.Ok(await _svc.CreateAsync(req, ct)));

	[HttpDelete("{id:guid}")]
	public async Task<ActionResult<ApiResponse<object>>> Delete(Guid id, CancellationToken ct)
	{ await _svc.DeleteAsync(id, ct); return Ok(ApiResponse<object>.Ok(new { })); }
}

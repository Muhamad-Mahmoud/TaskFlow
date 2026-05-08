using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Application.DTOs.Attachments;
using TaskFlow.Domain.Entities;
using TaskFlow.Domain.Enums;
using TaskFlow.Domain.Exceptions;
using TaskFlow.Shared.Wrappers;

namespace TaskFlow.API.Controllers.V1;

[ApiController] [Authorize]
[Route("api/v1")]
public class AttachmentsController : ControllerBase
{
	private readonly IUnitOfWork _uow;
	private readonly IFileStorageService _storage;
	private readonly ICurrentUserService _current;

	public AttachmentsController(IUnitOfWork uow, IFileStorageService storage, ICurrentUserService current)
	{ _uow = uow; _storage = storage; _current = current; }

	private Guid Me => _current.UserId ?? throw new UnauthorizedAccessException();

	[HttpGet("projects/{projectId:guid}/attachments")]
	public async Task<ActionResult<ApiResponse<IReadOnlyList<AttachmentResponse>>>> ListProject(Guid projectId, CancellationToken ct)
	{
		if (!await _uow.Projects.IsMemberAsync(projectId, Me, ct)) throw new ForbiddenException();
		var items = await _uow.Attachments.FindAsync(
			a => a.EntityType == AttachmentEntityType.Project && a.EntityId == projectId, ct);
		return Ok(ApiResponse<IReadOnlyList<AttachmentResponse>>.Ok(items.Select(Map).ToList()));
	}

	[HttpPost("projects/{projectId:guid}/attachments")]
	public Task<ActionResult<ApiResponse<AttachmentResponse>>> UploadProject(Guid projectId, IFormFile file, CancellationToken ct)
		=> UploadAsync(AttachmentEntityType.Project, projectId, file, ct);

	[HttpGet("tasks/{taskId:guid}/attachments")]
	public async Task<ActionResult<ApiResponse<IReadOnlyList<AttachmentResponse>>>> ListTask(Guid taskId, CancellationToken ct)
	{
		var items = await _uow.Attachments.FindAsync(
			a => a.EntityType == AttachmentEntityType.Task && a.EntityId == taskId, ct);
		return Ok(ApiResponse<IReadOnlyList<AttachmentResponse>>.Ok(items.Select(Map).ToList()));
	}

	[HttpPost("tasks/{taskId:guid}/attachments")]
	public Task<ActionResult<ApiResponse<AttachmentResponse>>> UploadTask(Guid taskId, IFormFile file, CancellationToken ct)
		=> UploadAsync(AttachmentEntityType.Task, taskId, file, ct);

	[HttpDelete("tasks/{taskId:guid}/attachments/{aid:guid}")]
	public async Task<ActionResult<ApiResponse<object>>> Delete(Guid taskId, Guid aid, CancellationToken ct)
	{
		var a = await _uow.Attachments.GetByIdAsync(aid, ct) ?? throw new NotFoundException(nameof(Attachment), aid);
		if (a.UploadedById != Me) throw new ForbiddenException();
		await _storage.DeleteAsync(a.FileUrl, ct);
		_uow.Attachments.Delete(a);
		await _uow.SaveChangesAsync(ct);
		return Ok(ApiResponse<object>.Ok(new { }));
	}

	private async Task<ActionResult<ApiResponse<AttachmentResponse>>> UploadAsync(
		AttachmentEntityType type, Guid entityId, IFormFile file, CancellationToken ct)
	{
		if (file is null || file.Length == 0)
			return BadRequest(ApiResponse<AttachmentResponse>.Fail("File required."));

		await using var s = file.OpenReadStream();
		var (url, name, mime, size) = await _storage.UploadAsync(s, file.FileName, file.ContentType, ct);

		var att = new Attachment
		{
			EntityType = type, EntityId = entityId, UploadedById = Me,
			FileName = name, FileUrl = url, FileSize = size, MimeType = mime
		};
		await _uow.Attachments.AddAsync(att, ct);
		await _uow.SaveChangesAsync(ct);
		return Ok(ApiResponse<AttachmentResponse>.Ok(Map(att)));
	}

	private static AttachmentResponse Map(Attachment a) => new(
		a.Id, a.FileName, a.FileUrl, a.FileSize, a.MimeType, a.UploadedById, a.CreatedAt);
}

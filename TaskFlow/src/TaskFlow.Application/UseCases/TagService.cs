using AutoMapper;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Application.DTOs.Tags;
using TaskFlow.Domain.Entities;
using TaskFlow.Domain.Exceptions;

namespace TaskFlow.Application.UseCases;

public interface ITagService
{
	Task<IReadOnlyList<TagResponse>> ListAsync(CancellationToken ct);
	Task<TagResponse> CreateAsync(CreateTagRequest req, CancellationToken ct);
	Task DeleteAsync(Guid id, CancellationToken ct);
}

public class TagService : ITagService
{
	private readonly IUnitOfWork _uow; private readonly ICurrentUserService _current; private readonly IMapper _mapper;
	public TagService(IUnitOfWork u, ICurrentUserService c, IMapper m) { _uow = u; _current = c; _mapper = m; }
	private Guid Me => _current.UserId ?? throw new UnauthorizedAccessException();

	public async Task<IReadOnlyList<TagResponse>> ListAsync(CancellationToken ct)
		=> _mapper.Map<List<TagResponse>>(await _uow.Tags.FindAsync(t => t.CreatedById == Me, ct));

	public async Task<TagResponse> CreateAsync(CreateTagRequest req, CancellationToken ct)
	{
		var tag = new Tag { Name = req.Name, Color = req.Color, CreatedById = Me };
		await _uow.Tags.AddAsync(tag, ct);
		await _uow.SaveChangesAsync(ct);
		return _mapper.Map<TagResponse>(tag);
	}

	public async Task DeleteAsync(Guid id, CancellationToken ct)
	{
		var tag = await _uow.Tags.GetByIdAsync(id, ct) ?? throw new NotFoundException(nameof(Tag), id);
		if (tag.CreatedById != Me) throw new ForbiddenException();
		_uow.Tags.Delete(tag);
		await _uow.SaveChangesAsync(ct);
	}
}

using AutoMapper;
using Microsoft.EntityFrameworkCore;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Application.DTOs.Comments;
using TaskFlow.Domain.Entities;
using TaskFlow.Domain.Exceptions;

namespace TaskFlow.Application.UseCases;

public interface ICommentService
{
	Task<IReadOnlyList<CommentResponse>> ListAsync(Guid taskId, CancellationToken ct);
	Task<CommentResponse> CreateAsync(Guid taskId, CreateCommentRequest req, CancellationToken ct);
	Task DeleteAsync(Guid taskId, Guid commentId, CancellationToken ct);
}

public class CommentService : ICommentService
{
	private readonly IUnitOfWork _uow;
	private readonly ICurrentUserService _current;
	private readonly IMapper _mapper;
	public CommentService(IUnitOfWork u, ICurrentUserService c, IMapper m) { _uow = u; _current = c; _mapper = m; }

	public async Task<IReadOnlyList<CommentResponse>> ListAsync(Guid taskId, CancellationToken ct)
	{
		var items = await _uow.Comments.Query()
			.Include(c => c.Author)
			.Where(c => c.TaskId == taskId)
			.OrderBy(c => c.CreatedAt).ToListAsync(ct);
		return _mapper.Map<List<CommentResponse>>(items);
	}

	public async Task<CommentResponse> CreateAsync(Guid taskId, CreateCommentRequest req, CancellationToken ct)
	{
		var me = _current.UserId ?? throw new UnauthorizedAccessException();
		var c = new Comment { TaskId = taskId, AuthorId = me, Content = req.Content, ParentId = req.ParentId };
		await _uow.Comments.AddAsync(c, ct);
		await _uow.SaveChangesAsync(ct);
		return _mapper.Map<CommentResponse>(c);
	}

	public async Task DeleteAsync(Guid taskId, Guid commentId, CancellationToken ct)
	{
		var me = _current.UserId ?? throw new UnauthorizedAccessException();
		var c = await _uow.Comments.GetByIdAsync(commentId, ct) ?? throw new NotFoundException(nameof(Comment), commentId);
		if (c.TaskId != taskId || c.AuthorId != me) throw new ForbiddenException();
		_uow.Comments.Delete(c);
		await _uow.SaveChangesAsync(ct);
	}
}

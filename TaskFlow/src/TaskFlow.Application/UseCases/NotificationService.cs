using AutoMapper;
using Microsoft.EntityFrameworkCore;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Application.DTOs.Notifications;
using TaskFlow.Domain.Entities;
using TaskFlow.Domain.Exceptions;
using TaskFlow.Shared.Wrappers;

namespace TaskFlow.Application.UseCases;

public interface INotificationService
{
	Task<PagedResult<NotificationResponse>> ListAsync(int page, int pageSize, CancellationToken ct);
	Task MarkReadAsync(Guid id, CancellationToken ct);
	Task MarkAllReadAsync(CancellationToken ct);
	Task DeleteAsync(Guid id, CancellationToken ct);
	Task RegisterPushTokenAsync(RegisterPushTokenRequest req, CancellationToken ct);
}

public class NotificationService : INotificationService
{
	private readonly IUnitOfWork _uow; private readonly ICurrentUserService _current; private readonly IMapper _mapper;
	public NotificationService(IUnitOfWork u, ICurrentUserService c, IMapper m) { _uow = u; _current = c; _mapper = m; }
	private Guid Me => _current.UserId ?? throw new UnauthorizedAccessException();

	public async Task<PagedResult<NotificationResponse>> ListAsync(int page, int pageSize, CancellationToken ct)
	{
		var q = _uow.Notifications.Query().Where(n => n.UserId == Me).OrderByDescending(n => n.CreatedAt);
		var total = await q.CountAsync(ct);
		var items = await q.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync(ct);
		return new PagedResult<NotificationResponse>
		{
			Items = _mapper.Map<List<NotificationResponse>>(items),
			PageNumber = page, PageSize = pageSize, TotalCount = total
		};
	}

	public async Task MarkReadAsync(Guid id, CancellationToken ct)
	{
		var n = await _uow.Notifications.GetByIdAsync(id, ct) ?? throw new NotFoundException(nameof(Notification), id);
		if (n.UserId != Me) throw new ForbiddenException();
		n.IsRead = true; n.ReadAt = DateTime.UtcNow;
		_uow.Notifications.Update(n);
		await _uow.SaveChangesAsync(ct);
	}

	public Task MarkAllReadAsync(CancellationToken ct) => _uow.Notifications.MarkAllReadAsync(Me, ct);

	public async Task DeleteAsync(Guid id, CancellationToken ct)
	{
		var n = await _uow.Notifications.GetByIdAsync(id, ct) ?? throw new NotFoundException(nameof(Notification), id);
		if (n.UserId != Me) throw new ForbiddenException();
		_uow.Notifications.Delete(n);
		await _uow.SaveChangesAsync(ct);
	}

	public async Task RegisterPushTokenAsync(RegisterPushTokenRequest req, CancellationToken ct)
	{
		var existing = (await _uow.PushTokens.FindAsync(t => t.UserId == Me && t.Token == req.Token, ct)).FirstOrDefault();
		if (existing is not null) return;
		await _uow.PushTokens.AddAsync(new PushToken
		{ UserId = Me, Token = req.Token, Platform = req.Platform, DeviceId = req.DeviceId }, ct);
		await _uow.SaveChangesAsync(ct);
	}
}

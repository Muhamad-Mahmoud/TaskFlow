using Microsoft.EntityFrameworkCore;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Infrastructure.Persistence.Repositories;

public class NotificationRepository : GenericRepository<Notification>, INotificationRepository
{
	public NotificationRepository(TaskFlowDbContext db) : base(db) { }

	public Task<int> CountUnreadAsync(Guid userId, CancellationToken ct = default)
		=> Set.CountAsync(n => n.UserId == userId && !n.IsRead, ct);

	public async Task MarkAllReadAsync(Guid userId, CancellationToken ct = default)
	{
		var now = DateTime.UtcNow;
		await Set.Where(n => n.UserId == userId && !n.IsRead)
			.ExecuteUpdateAsync(s => s
				.SetProperty(n => n.IsRead, true)
				.SetProperty(n => n.ReadAt, now)
				.SetProperty(n => n.UpdatedAt, now), ct);
	}
}

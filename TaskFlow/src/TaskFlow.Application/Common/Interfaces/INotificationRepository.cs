using TaskFlow.Domain.Entities;

namespace TaskFlow.Application.Common.Interfaces;

public interface INotificationRepository : IGenericRepository<Notification>
{
    Task<int> CountUnreadAsync(Guid userId, CancellationToken ct = default);
    Task MarkAllReadAsync(Guid userId, CancellationToken ct = default);
}

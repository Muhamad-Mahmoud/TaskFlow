using TaskFlow.Domain.Entities;
using DomainTaskStatus = TaskFlow.Domain.Enums.TaskStatus;

namespace TaskFlow.Application.Common.Interfaces;

public interface ITaskRepository : IGenericRepository<TaskItem>
{
    Task<TaskItem?> GetWithDetailsAsync(Guid id, CancellationToken ct = default);
    Task<IReadOnlyList<TaskItem>> GetByProjectAsync(Guid projectId, CancellationToken ct = default);
    Task<int> GetMaxPositionAsync(Guid projectId, DomainTaskStatus status, CancellationToken ct = default);
}

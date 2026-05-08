using TaskFlow.Domain.Entities;

namespace TaskFlow.Application.Common.Interfaces;

public interface IProjectRepository : IGenericRepository<Project>
{
    Task<Project?> GetWithMembersAsync(Guid id, CancellationToken ct = default);
    Task<IReadOnlyList<Project>> GetForUserAsync(Guid userId, int page, int pageSize, CancellationToken ct = default);
    Task<int> CountForUserAsync(Guid userId, CancellationToken ct = default);
    Task<bool> IsMemberAsync(Guid projectId, Guid userId, CancellationToken ct = default);
}

using Microsoft.EntityFrameworkCore;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Infrastructure.Persistence.Repositories;

public class ProjectRepository : GenericRepository<Project>, IProjectRepository
{
	public ProjectRepository(TaskFlowDbContext db) : base(db) { }

	public Task<Project?> GetWithMembersAsync(Guid id, CancellationToken ct = default)
		=> Set.Include(p => p.Members).ThenInclude(m => m.User)
			  .Include(p => p.Owner)
			  .FirstOrDefaultAsync(p => p.Id == id, ct);

	public async Task<IReadOnlyList<Project>> GetForUserAsync(
		Guid userId, int page, int pageSize, CancellationToken ct = default)
	{
		return await Set.AsNoTracking()
			.Where(p => p.OwnerId == userId || p.Members.Any(m => m.UserId == userId))
			.OrderByDescending(p => p.UpdatedAt)
			.Skip((page - 1) * pageSize).Take(pageSize)
			.ToListAsync(ct);
	}

	public Task<int> CountForUserAsync(Guid userId, CancellationToken ct = default)
		=> Set.CountAsync(p => p.OwnerId == userId || p.Members.Any(m => m.UserId == userId), ct);

	public Task<bool> IsMemberAsync(Guid projectId, Guid userId, CancellationToken ct = default)
		=> Set.AnyAsync(p => p.Id == projectId &&
			(p.OwnerId == userId || p.Members.Any(m => m.UserId == userId)), ct);
}

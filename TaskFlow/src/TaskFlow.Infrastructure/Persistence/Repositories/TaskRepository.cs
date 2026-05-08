using Microsoft.EntityFrameworkCore;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Domain.Entities;
using DomainTaskStatus = TaskFlow.Domain.Enums.TaskStatus;

namespace TaskFlow.Infrastructure.Persistence.Repositories;

public class TaskRepository : GenericRepository<TaskItem>, ITaskRepository
{
	public TaskRepository(TaskFlowDbContext db) : base(db) { }

	public Task<TaskItem?> GetWithDetailsAsync(Guid id, CancellationToken ct = default)
		=> Set.Include(t => t.Subtasks)
			  .Include(t => t.TaskTags).ThenInclude(tt => tt.Tag)
			  .Include(t => t.Assignee)
			  .Include(t => t.CreatedBy)
			  .FirstOrDefaultAsync(t => t.Id == id, ct);

	public async Task<IReadOnlyList<TaskItem>> GetByProjectAsync(Guid projectId, CancellationToken ct = default)
		=> await Set.AsNoTracking().Include(t => t.Assignee).Include(t => t.Project)
			.Where(t => t.ProjectId == projectId)
			.OrderBy(t => t.Status).ThenBy(t => t.Position).ToListAsync(ct);

	public async Task<int> GetMaxPositionAsync(Guid projectId, DomainTaskStatus status, CancellationToken ct = default)
	{
		var max = await Set.Where(t => t.ProjectId == projectId && t.Status == status)
						   .Select(t => (int?)t.Position).MaxAsync(ct);
		return max ?? -1;
	}
}

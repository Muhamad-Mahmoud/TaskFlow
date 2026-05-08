using AutoMapper;
using Microsoft.EntityFrameworkCore;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Application.DTOs.Tags;
using TaskFlow.Application.DTOs.Tasks;
using TaskFlow.Domain.Entities;
using TaskFlow.Domain.Enums;
using TaskFlow.Domain.Exceptions;
using TaskFlow.Shared.Wrappers;
using DomainTaskStatus = TaskFlow.Domain.Enums.TaskStatus;

namespace TaskFlow.Application.UseCases.Tasks;

public interface ITaskService
{
	Task<TaskDetailResponse> CreateAsync(CreateTaskRequest req, CancellationToken ct);
	Task<TaskDetailResponse> GetAsync(Guid id, CancellationToken ct);
	Task<TaskResponse> UpdateAsync(Guid id, UpdateTaskRequest req, CancellationToken ct);
	Task UpdateStatusAsync(Guid id, UpdateStatusRequest req, CancellationToken ct);
	Task ReorderAsync(Guid id, ReorderTaskRequest req, CancellationToken ct);
	Task DeleteAsync(Guid id, CancellationToken ct);
	Task<IReadOnlyList<TaskSummary>> ListByProjectAsync(Guid projectId, CancellationToken ct);
	Task<PagedResult<TaskSummary>> ListAsync(int page, int pageSize, Guid? projectId, CancellationToken ct);
	Task<SubtaskResponse> AddSubtaskAsync(Guid taskId, CreateSubtaskRequest req, CancellationToken ct);
	Task<SubtaskResponse> UpdateSubtaskAsync(Guid taskId, Guid sid, UpdateSubtaskRequest req, CancellationToken ct);
	Task DeleteSubtaskAsync(Guid taskId, Guid sid, CancellationToken ct);
}

public class TaskService : ITaskService
{
	private readonly IUnitOfWork _uow;
	private readonly ICurrentUserService _current;
	private readonly IMapper _mapper;
	private readonly IPushNotificationService _push;

	public TaskService(IUnitOfWork uow, ICurrentUserService current, IMapper mapper, IPushNotificationService push)
	{ _uow = uow; _current = current; _mapper = mapper; _push = push; }

	private Guid Me => _current.UserId ?? throw new UnauthorizedAccessException();

	public async Task<TaskDetailResponse> CreateAsync(CreateTaskRequest req, CancellationToken ct)
	{
		if (!await _uow.Projects.IsMemberAsync(req.ProjectId, Me, ct)) throw new ForbiddenException();

		var status = Enum.Parse<DomainTaskStatus>(req.Status, true);
		var nextPos = await _uow.Tasks.GetMaxPositionAsync(req.ProjectId, status, ct) + 1;

		var task = new TaskItem
		{
			Title = req.Title, Description = req.Description,
			ProjectId = req.ProjectId, AssigneeId = req.AssigneeId,
			Status = status, Priority = Enum.Parse<TaskPriority>(req.Priority, true),
			DueDate = req.DueDate, EstimatedHours = req.EstimatedHours,
			CreatedById = Me, Position = nextPos
		};
		foreach (var s in req.Subtasks ?? new())
			task.Subtasks.Add(new Subtask { Title = s.Title, Position = s.Position });
		foreach (var tagId in req.TagIds ?? new())
			task.TaskTags.Add(new TaskTag { TagId = tagId });

		await _uow.Tasks.AddAsync(task, ct);
		await _uow.SaveChangesAsync(ct);

		if (task.AssigneeId.HasValue && task.AssigneeId != Me)
			await NotifyAsync(task.AssigneeId.Value, NotificationType.TaskAssigned,
				"Task assigned", $"You were assigned: {task.Title}", "task", task.Id, ct);

		return await BuildDetailAsync(task.Id, ct);
	}

	public Task<TaskDetailResponse> GetAsync(Guid id, CancellationToken ct) => BuildDetailAsync(id, ct);

	public async Task<TaskResponse> UpdateAsync(Guid id, UpdateTaskRequest req, CancellationToken ct)
	{
		var t = await _uow.Tasks.GetByIdAsync(id, ct) ?? throw new NotFoundException(nameof(TaskItem), id);
		if (!await _uow.Projects.IsMemberAsync(t.ProjectId, Me, ct)) throw new ForbiddenException();

		t.Title = req.Title; t.Description = req.Description; t.AssigneeId = req.AssigneeId;
		t.Status = Enum.Parse<DomainTaskStatus>(req.Status, true);
		t.Priority = Enum.Parse<TaskPriority>(req.Priority, true);
		t.DueDate = req.DueDate; t.EstimatedHours = req.EstimatedHours;
		if (t.Status == DomainTaskStatus.Done && t.CompletedAt is null) t.CompletedAt = DateTime.UtcNow;

		_uow.Tasks.Update(t);
		await _uow.SaveChangesAsync(ct);
		return _mapper.Map<TaskResponse>(t);
	}

	public async Task UpdateStatusAsync(Guid id, UpdateStatusRequest req, CancellationToken ct)
	{
		var t = await _uow.Tasks.GetByIdAsync(id, ct) ?? throw new NotFoundException(nameof(TaskItem), id);
		if (!await _uow.Projects.IsMemberAsync(t.ProjectId, Me, ct)) throw new ForbiddenException();
		t.Status = Enum.Parse<DomainTaskStatus>(req.Status, true);
		if (t.Status == DomainTaskStatus.Done && t.CompletedAt is null) t.CompletedAt = DateTime.UtcNow;
		await _uow.SaveChangesAsync(ct);
	}

	public async Task ReorderAsync(Guid id, ReorderTaskRequest req, CancellationToken ct)
	{
		var t = await _uow.Tasks.GetByIdAsync(id, ct) ?? throw new NotFoundException(nameof(TaskItem), id);
		if (!await _uow.Projects.IsMemberAsync(t.ProjectId, Me, ct)) throw new ForbiddenException();

		t.Status = Enum.Parse<DomainTaskStatus>(req.NewStatus, true);
		t.Position = req.NewPosition;
		await _uow.SaveChangesAsync(ct);
	}

	public async Task DeleteAsync(Guid id, CancellationToken ct)
	{
		var t = await _uow.Tasks.GetByIdAsync(id, ct) ?? throw new NotFoundException(nameof(TaskItem), id);
		if (!await _uow.Projects.IsMemberAsync(t.ProjectId, Me, ct)) throw new ForbiddenException();
		_uow.Tasks.Delete(t);
		await _uow.SaveChangesAsync(ct);
	}

	public async Task<IReadOnlyList<TaskSummary>> ListByProjectAsync(Guid projectId, CancellationToken ct)
	{
		if (!await _uow.Projects.IsMemberAsync(projectId, Me, ct)) throw new ForbiddenException();
		var items = await _uow.Tasks.GetByProjectAsync(projectId, ct);
		return _mapper.Map<List<TaskSummary>>(items);
	}

	public async Task<PagedResult<TaskSummary>> ListAsync(int page, int pageSize, Guid? projectId, CancellationToken ct)
	{
		var query = _uow.Tasks.Query()
			.Include(t => t.Assignee)
			.Include(t => t.Project)
			.AsNoTracking();

		if (projectId.HasValue)
		{
			query = query.Where(t => t.ProjectId == projectId.Value);
		}

		// Security: Only tasks from projects where current user is a member
		query = query.Where(t => t.Project.Members.Any(m => m.UserId == Me));

		var total = await query.CountAsync(ct);
		var items = await query.OrderByDescending(t => t.CreatedAt)
			.Skip((page - 1) * pageSize)
			.Take(pageSize)
			.ToListAsync(ct);

		return new PagedResult<TaskSummary>(
			_mapper.Map<List<TaskSummary>>(items),
			total, page, pageSize);
	}

	public async Task<SubtaskResponse> AddSubtaskAsync(Guid taskId, CreateSubtaskRequest req, CancellationToken ct)
	{
		var t = await _uow.Tasks.GetByIdAsync(taskId, ct) ?? throw new NotFoundException(nameof(TaskItem), taskId);
		if (!await _uow.Projects.IsMemberAsync(t.ProjectId, Me, ct)) throw new ForbiddenException();

		var s = new Subtask { TaskId = taskId, Title = req.Title, Position = req.Position };
		await _uow.Subtasks.AddAsync(s, ct);
		await _uow.SaveChangesAsync(ct);
		return _mapper.Map<SubtaskResponse>(s);
	}

	public async Task<SubtaskResponse> UpdateSubtaskAsync(Guid taskId, Guid sid, UpdateSubtaskRequest req, CancellationToken ct)
	{
		var s = await _uow.Subtasks.GetByIdAsync(sid, ct) ?? throw new NotFoundException(nameof(Subtask), sid);
		if (s.TaskId != taskId) throw new NotFoundException(nameof(Subtask), sid);

		if (req.Title is not null) s.Title = req.Title;
		if (req.IsCompleted != null) s.IsCompleted = req.IsCompleted.Value;
		if (req.Position != null) s.Position = req.Position.Value;

		_uow.Subtasks.Update(s);
		await _uow.SaveChangesAsync(ct);
		return _mapper.Map<SubtaskResponse>(s);
	}

	public async Task DeleteSubtaskAsync(Guid taskId, Guid sid, CancellationToken ct)
	{
		var s = await _uow.Subtasks.GetByIdAsync(sid, ct) ?? throw new NotFoundException(nameof(Subtask), sid);
		if (s.TaskId != taskId) throw new NotFoundException(nameof(Subtask), sid);
		_uow.Subtasks.Delete(s);
		await _uow.SaveChangesAsync(ct);
	}

	private async Task<TaskDetailResponse> BuildDetailAsync(Guid id, CancellationToken ct)
	{
		var t = await _uow.Tasks.GetWithDetailsAsync(id, ct) ?? throw new NotFoundException(nameof(TaskItem), id);
		return new TaskDetailResponse(
			t.Id, t.Title, t.Description, t.Status.ToString(), t.Priority.ToString(),
			t.DueDate, t.EstimatedHours, t.ProjectId,
			t.Assignee == null ? null : new AssigneeBrief(t.Assignee.Id, t.Assignee.FullName, t.Assignee.AvatarUrl),
			new AssigneeBrief(t.CreatedBy.Id, t.CreatedBy.FullName, t.CreatedBy.AvatarUrl),
			t.Subtasks.OrderBy(s => s.Position).Select(s => new SubtaskResponse(s.Id, s.Title, s.IsCompleted, s.Position)).ToList(),
			t.TaskTags.Select(tt => new TagBrief(tt.Tag.Id, tt.Tag.Name, tt.Tag.Color)).ToList(),
			t.Comments.Count, t.Attachments.Count, t.CreatedAt, t.UpdatedAt);
	}

	private async Task NotifyAsync(Guid userId, NotificationType type, string title, string message,
		string relatedType, Guid relatedId, CancellationToken ct)
	{
		await _uow.Notifications.AddAsync(new Notification
		{
			UserId = userId, Type = type, Title = title, Message = message,
			RelatedEntityType = relatedType, RelatedEntityId = relatedId
		}, ct);
		await _uow.SaveChangesAsync(ct);
		await _push.SendToUserAsync(userId, title, message,
			new Dictionary<string, string> { ["entityType"] = relatedType, ["entityId"] = relatedId.ToString() }, ct);
	}
}

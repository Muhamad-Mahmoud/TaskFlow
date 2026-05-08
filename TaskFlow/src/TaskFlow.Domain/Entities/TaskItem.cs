using TaskFlow.Domain.Common;
using TaskFlow.Domain.Enums;

namespace TaskFlow.Domain.Entities;

public class TaskItem : BaseEntity
{
    public string Title { get; set; } = default!;
    public string? Description { get; set; }
    public TaskFlow.Domain.Enums.TaskStatus Status { get; set; } = TaskFlow.Domain.Enums.TaskStatus.Todo;
    public TaskPriority Priority { get; set; } = TaskPriority.Medium;
    public DateTime? DueDate { get; set; }
    public double? EstimatedHours { get; set; }
    public DateTime? CompletedAt { get; set; }
    public int Position { get; set; }

    public Guid ProjectId { get; set; }
    public virtual Project Project { get; set; } = default!;

    public Guid CreatedById { get; set; }
    public virtual User CreatedBy { get; set; } = default!;

    public Guid? AssigneeId { get; set; }
    public virtual User? Assignee { get; set; }

    public virtual ICollection<Subtask> Subtasks { get; set; } = new List<Subtask>();
    public virtual ICollection<Comment> Comments { get; set; } = new List<Comment>();
    public virtual ICollection<Attachment> Attachments { get; set; } = new List<Attachment>();
    public virtual ICollection<TaskTag> TaskTags { get; set; } = new List<TaskTag>();
}

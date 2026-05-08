using TaskFlow.Domain.Common;
using TaskFlow.Domain.Enums;

namespace TaskFlow.Domain.Entities;

public class Project : BaseEntity
{
    public string Name { get; set; } = default!;
    public string? Description { get; set; }
    public string ColorLabel { get; set; } = "#6366F1";
    public ProjectStatus Status { get; set; } = ProjectStatus.Active;
    public TaskPriority Priority { get; set; } = TaskPriority.Medium;
    public DateTime? StartDate { get; set; }
    public DateTime? DueDate { get; set; }

    public Guid OwnerId { get; set; }
    public virtual User Owner { get; set; } = default!;

    public virtual ICollection<ProjectMember> Members { get; set; } = new List<ProjectMember>();
    public virtual ICollection<TaskItem> Tasks { get; set; } = new List<TaskItem>();
    public virtual ICollection<Attachment> Attachments { get; set; } = new List<Attachment>();
}

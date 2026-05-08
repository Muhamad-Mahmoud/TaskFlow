using TaskFlow.Domain.Common;

namespace TaskFlow.Domain.Entities;

public class Tag : BaseEntity
{
    public string Name { get; set; } = default!;
    public string Color { get; set; } = "#9CA3AF";
    public Guid CreatedById { get; set; }
    public virtual User CreatedBy { get; set; } = default!;
    public virtual ICollection<TaskTag> TaskTags { get; set; } = new List<TaskTag>();
}

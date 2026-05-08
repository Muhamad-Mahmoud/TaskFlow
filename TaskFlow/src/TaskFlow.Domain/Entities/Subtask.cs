using TaskFlow.Domain.Common;

namespace TaskFlow.Domain.Entities;

public class Subtask : BaseEntity
{
    public Guid TaskId { get; set; }
    public virtual TaskItem Task { get; set; } = default!;
    public string Title { get; set; } = default!;
    public bool IsCompleted { get; set; }
    public int Position { get; set; }
}

using TaskFlow.Domain.Common;

namespace TaskFlow.Domain.Entities;

public class Comment : BaseEntity
{
    public Guid TaskId { get; set; }
    public virtual TaskItem Task { get; set; } = default!;

    public Guid AuthorId { get; set; }
    public virtual User Author { get; set; } = default!;

    public string Content { get; set; } = default!;
    public Guid? ParentId { get; set; }
    public virtual Comment? Parent { get; set; }
    public virtual ICollection<Comment> Replies { get; set; } = new List<Comment>();

    public DateTime? EditedAt { get; set; }
}

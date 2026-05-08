using TaskFlow.Domain.Common;
using TaskFlow.Domain.Enums;

namespace TaskFlow.Domain.Entities;

public class Notification : BaseEntity
{
    public Guid UserId { get; set; }
    public virtual User User { get; set; } = default!;
    public NotificationType Type { get; set; }
    public string Title { get; set; } = default!;
    public string Message { get; set; } = default!;
    public string? RelatedEntityType { get; set; }    // task | project | comment
    public Guid? RelatedEntityId { get; set; }
    public bool IsRead { get; set; }
    public DateTime? ReadAt { get; set; }
}

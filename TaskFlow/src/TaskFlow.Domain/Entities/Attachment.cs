using TaskFlow.Domain.Common;
using TaskFlow.Domain.Enums;

namespace TaskFlow.Domain.Entities;

public class Attachment : BaseEntity
{
    public AttachmentEntityType EntityType { get; set; }
    public Guid EntityId { get; set; }                 // polymorphic FK
    public Guid UploadedById { get; set; }
    public virtual User UploadedBy { get; set; } = default!;
    public string FileName { get; set; } = default!;
    public string FileUrl { get; set; } = default!;
    public long FileSize { get; set; }
    public string MimeType { get; set; } = default!;
}

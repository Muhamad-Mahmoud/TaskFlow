using TaskFlow.Domain.Enums;

namespace TaskFlow.Domain.Entities;

public class ProjectMember
{
    public Guid ProjectId { get; set; }
    public virtual Project Project { get; set; } = default!;

    public Guid UserId { get; set; }
    public virtual User User { get; set; } = default!;

    public ProjectMemberRole Role { get; set; } = ProjectMemberRole.Viewer;
    public DateTime JoinedAt { get; set; } = DateTime.UtcNow;
}

using TaskFlow.Domain.Entities;

namespace TaskFlow.Application.Common.Interfaces;

public interface IUnitOfWork : IDisposable
{
    IUserRepository Users { get; }
    IProjectRepository Projects { get; }
    ITaskRepository Tasks { get; }
    IGenericRepository<Comment> Comments { get; }
    INotificationRepository Notifications { get; }
    IGenericRepository<Tag> Tags { get; }
    IGenericRepository<Subtask> Subtasks { get; }
    IGenericRepository<Attachment> Attachments { get; }
    IGenericRepository<TaskTag> TaskTags { get; }
    IGenericRepository<ProjectMember> ProjectMembers { get; }
    IGenericRepository<RefreshToken> RefreshTokens { get; }
    IGenericRepository<OtpCode> OtpCodes { get; }
    IGenericRepository<PushToken> PushTokens { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}

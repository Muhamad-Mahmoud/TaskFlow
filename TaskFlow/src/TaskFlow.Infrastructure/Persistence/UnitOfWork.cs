using Microsoft.EntityFrameworkCore.Storage;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Domain.Entities;
using TaskFlow.Infrastructure.Persistence.Repositories;

namespace TaskFlow.Infrastructure.Persistence;

public class UnitOfWork : IUnitOfWork
{
	private readonly TaskFlowDbContext _db;
	private IDbContextTransaction? _tx;

	public UnitOfWork(TaskFlowDbContext db)
	{
		_db = db;
		Users = new UserRepository(db);
		Projects = new ProjectRepository(db);
		Tasks = new TaskRepository(db);
		Notifications = new NotificationRepository(db);
		Comments = new GenericRepository<Comment>(db);
		Subtasks = new GenericRepository<Subtask>(db);
		Tags = new GenericRepository<Tag>(db);
		TaskTags = new GenericRepository<TaskTag>(db);
		Attachments = new GenericRepository<Attachment>(db);
		ProjectMembers = new GenericRepository<ProjectMember>(db);
		RefreshTokens = new GenericRepository<RefreshToken>(db);
		OtpCodes = new GenericRepository<OtpCode>(db);
		PushTokens = new GenericRepository<PushToken>(db);
	}

	public IUserRepository Users { get; }
	public IProjectRepository Projects { get; }
	public ITaskRepository Tasks { get; }
	public INotificationRepository Notifications { get; }
	public IGenericRepository<Comment> Comments { get; }
	public IGenericRepository<Subtask> Subtasks { get; }
	public IGenericRepository<Tag> Tags { get; }
	public IGenericRepository<TaskTag> TaskTags { get; }
	public IGenericRepository<Attachment> Attachments { get; }
	public IGenericRepository<ProjectMember> ProjectMembers { get; }
	public IGenericRepository<RefreshToken> RefreshTokens { get; }
	public IGenericRepository<OtpCode> OtpCodes { get; }
	public IGenericRepository<PushToken> PushTokens { get; }

	public Task<int> SaveChangesAsync(CancellationToken ct = default) => _db.SaveChangesAsync(ct);
	public async Task BeginTransactionAsync(CancellationToken ct = default) => _tx = await _db.Database.BeginTransactionAsync(ct);
	public async Task CommitAsync(CancellationToken ct = default)
	{ if (_tx is null) return; await _tx.CommitAsync(ct); await _tx.DisposeAsync(); _tx = null; }
	public async Task RollbackAsync(CancellationToken ct = default)
	{ if (_tx is null) return; await _tx.RollbackAsync(ct); await _tx.DisposeAsync(); _tx = null; }

	public async ValueTask DisposeAsync()
	{
		if (_tx is not null) await _tx.DisposeAsync();
		await _db.DisposeAsync();
		GC.SuppressFinalize(this);
	}

	public void Dispose()
	{
		_tx?.Dispose();
		_db.Dispose();
		GC.SuppressFinalize(this);
	}
}

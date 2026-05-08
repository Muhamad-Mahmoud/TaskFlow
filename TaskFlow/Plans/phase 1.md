# Task-Flow — .NET 8 Backend API Architecture (2-Hour Sprint Plan)

<aside>
🎯

**Goal:** A fully planned, production-ready .NET 8 Web API for Task-Flow — Clean Architecture, JWT + Identity, EF Core 8 (PostgreSQL/Supabase), ready to code in under 2 hours.

**Stack:** .NET 8 · EF Core 8 · Npgsql · [ASP.NET](http://ASP.NET) Identity · JWT Bearer · AutoMapper · FluentValidation · Swagger

</aside>

## STEP 1 — Solution Structure

```
TaskFlow.sln
├── TaskFlow.API/                  → Presentation layer
├── TaskFlow.Application/          → Business logic / use cases
├── TaskFlow.Domain/               → Entities, enums, base classes
├── TaskFlow.Infrastructure/       → EF Core, Identity, JWT, FCM, Email
└── TaskFlow.Shared/               → Cross-cutting helpers
```

### 🟦 TaskFlow.API

```
TaskFlow.API/
├── Controllers/
│   ├── V1/
│   │   ├── AuthController.cs
│   │   ├── UsersController.cs
│   │   ├── ProjectsController.cs
│   │   ├── TasksController.cs
│   │   ├── CommentsController.cs
│   │   ├── TagsController.cs
│   │   └── NotificationsController.cs
├── Middleware/
│   ├── ExceptionHandlingMiddleware.cs
│   ├── RequestLoggingMiddleware.cs
│   └── CurrentUserMiddleware.cs
├── Filters/
│   └── ValidationFilter.cs
├── Extensions/
│   ├── ServiceCollectionExtensions.cs
│   ├── SwaggerExtensions.cs
│   └── AuthenticationExtensions.cs
├── appsettings.json
├── appsettings.Development.json
├── Program.cs
└── TaskFlow.API.csproj
```

### 🟩 TaskFlow.Application

```
TaskFlow.Application/
├── Common/
│   ├── Behaviors/
│   │   ├── ValidationBehavior.cs
│   │   └── LoggingBehavior.cs
│   ├── Mappings/
│   │   └── MappingProfile.cs
│   └── Interfaces/
│       ├── ICurrentUserService.cs
│       ├── IJwtTokenService.cs
│       ├── IEmailService.cs
│       ├── IFileStorageService.cs
│       ├── IPushNotificationService.cs
│       └── IOtpService.cs
├── DTOs/
│   ├── Auth/
│   ├── Users/
│   ├── Projects/
│   ├── Tasks/
│   ├── Comments/
│   ├── Tags/
│   └── Notifications/
├── UseCases/
│   ├── Auth/    (Register, Login, Refresh, ForgotPassword, VerifyOtp, ResetPassword)
│   ├── Users/   (GetMe, UpdateMe, GetStats, UploadAvatar, SearchUsers)
│   ├── Projects/(CRUD, ManageMembers, GetStats, Attachments)
│   ├── Tasks/   (CRUD, UpdateStatus, Reorder, Subtasks, Attachments)
│   ├── Comments/(CRUD)
│   ├── Tags/    (CRUD)
│   └── Notifications/(List, MarkRead, MarkAllRead, Delete, RegisterPushToken)
├── Validators/
│   └── (one validator per request DTO)
└── TaskFlow.Application.csproj
```

### 🟨 TaskFlow.Domain

```
TaskFlow.Domain/
├── Common/
│   ├── BaseEntity.cs
│   └── ISoftDeletable.cs
├── Entities/
│   ├── User.cs
│   ├── RefreshToken.cs
│   ├── OtpCode.cs
│   ├── Project.cs
│   ├── ProjectMember.cs
│   ├── TaskItem.cs
│   ├── Subtask.cs
│   ├── Comment.cs
│   ├── Attachment.cs
│   ├── Tag.cs
│   ├── TaskTag.cs
│   ├── Notification.cs
│   └── PushToken.cs
├── Enums/
│   ├── UserRole.cs
│   ├── ProjectStatus.cs
│   ├── ProjectMemberRole.cs
│   ├── TaskStatus.cs
│   ├── TaskPriority.cs
│   ├── AttachmentEntityType.cs
│   └── NotificationType.cs
├── Exceptions/
│   ├── DomainException.cs
│   ├── NotFoundException.cs
│   └── ForbiddenException.cs
└── TaskFlow.Domain.csproj
```

### 🟥 TaskFlow.Infrastructure

```
TaskFlow.Infrastructure/
├── Persistence/
│   ├── TaskFlowDbContext.cs
│   ├── Configurations/
│   │   ├── UserConfiguration.cs
│   │   ├── ProjectConfiguration.cs
│   │   ├── ProjectMemberConfiguration.cs
│   │   ├── TaskItemConfiguration.cs
│   │   ├── SubtaskConfiguration.cs
│   │   ├── CommentConfiguration.cs
│   │   ├── AttachmentConfiguration.cs
│   │   ├── TagConfiguration.cs
│   │   ├── TaskTagConfiguration.cs
│   │   ├── NotificationConfiguration.cs
│   │   ├── RefreshTokenConfiguration.cs
│   │   └── OtpCodeConfiguration.cs
│   ├── Interceptors/
│   │   └── AuditableEntityInterceptor.cs
│   ├── Repositories/
│   │   ├── GenericRepository.cs
│   │   ├── UserRepository.cs
│   │   ├── ProjectRepository.cs
│   │   ├── TaskRepository.cs
│   │   └── NotificationRepository.cs
│   ├── UnitOfWork.cs
│   └── DbSeeder.cs
├── Identity/
│   ├── JwtTokenService.cs
│   ├── CurrentUserService.cs
│   └── JwtSettings.cs
├── Services/
│   ├── EmailService.cs           (SMTP / SendGrid)
│   ├── OtpService.cs
│   ├── FileStorageService.cs     (S3 / Supabase Storage)
│   └── FcmPushNotificationService.cs
├── Migrations/
├── DependencyInjection.cs
└── TaskFlow.Infrastructure.csproj
```

### ⬜ TaskFlow.Shared

```
TaskFlow.Shared/
├── Wrappers/
│   ├── ApiResponse.cs
│   └── PagedResult.cs
├── Constants/
│   ├── ApiRoutes.cs
│   ├── ClaimTypes.cs
│   └── ErrorCodes.cs
├── Helpers/
│   ├── DateTimeProvider.cs
│   └── SlugHelper.cs
└── TaskFlow.Shared.csproj
```

---

## STEP 2 — Domain Entities

### `Common/BaseEntity.cs`

```csharp
namespace TaskFlow.Domain.Common;

public abstract class BaseEntity
{
	public Guid Id { get; set; } = Guid.NewGuid();
	public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
	public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
	public bool IsDeleted { get; set; } = false;
	public DateTime? DeletedAt { get; set; }
}
```

### `Enums/*.cs`

```csharp
namespace TaskFlow.Domain.Enums;

public enum UserRole          { Admin, Manager, Member }
public enum ProjectStatus     { Active, Archived, Completed }
public enum ProjectMemberRole { Owner, Editor, Viewer }
public enum TaskStatus        { Todo, InProgress, Review, Done }
public enum TaskPriority      { Low, Medium, High, Critical }
public enum AttachmentEntityType { Task, Project }
public enum NotificationType  { TaskAssigned, TaskDue, CommentAdded, ProjectInvite, StatusChanged }
```

### `Entities/User.cs`

```csharp
using Microsoft.AspNetCore.Identity;
using TaskFlow.Domain.Enums;

namespace TaskFlow.Domain.Entities;

public class User : IdentityUser<Guid>
{
	public string FullName { get; set; } = default!;
	public string? AvatarUrl { get; set; }
	public UserRole Role { get; set; } = UserRole.Member;
	public DateTime? LastLoginAt { get; set; }
	public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
	public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
	public bool IsDeleted { get; set; }
	public DateTime? DeletedAt { get; set; }

	// Navigation
	public ICollection<Project> OwnedProjects { get; set; } = new List<Project>();
	public ICollection<ProjectMember> ProjectMemberships { get; set; } = new List<ProjectMember>();
	public ICollection<TaskItem> CreatedTasks { get; set; } = new List<TaskItem>();
	public ICollection<TaskItem> AssignedTasks { get; set; } = new List<TaskItem>();
	public ICollection<Comment> Comments { get; set; } = new List<Comment>();
	public ICollection<Notification> Notifications { get; set; } = new List<Notification>();
	public ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();
	public ICollection<PushToken> PushTokens { get; set; } = new List<PushToken>();
}
```

### `Entities/RefreshToken.cs`

```csharp
using TaskFlow.Domain.Common;

namespace TaskFlow.Domain.Entities;

public class RefreshToken : BaseEntity
{
	public Guid UserId { get; set; }
	public User User { get; set; } = default!;
	public string TokenHash { get; set; } = default!;
	public DateTime ExpiresAt { get; set; }
	public DateTime? RevokedAt { get; set; }
	public string? ReplacedByTokenHash { get; set; }
	public string? CreatedByIp { get; set; }
	public bool IsActive => RevokedAt is null && DateTime.UtcNow < ExpiresAt;
}
```

### `Entities/OtpCode.cs`

```csharp
using TaskFlow.Domain.Common;

namespace TaskFlow.Domain.Entities;

public class OtpCode : BaseEntity
{
	public string Email { get; set; } = default!;
	public string CodeHash { get; set; } = default!;
	public string Purpose { get; set; } = "password_reset";
	public DateTime ExpiresAt { get; set; }
	public bool IsUsed { get; set; }
	public int Attempts { get; set; }
}
```

### `Entities/Project.cs`

```csharp
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
	public User Owner { get; set; } = default!;

	public ICollection<ProjectMember> Members { get; set; } = new List<ProjectMember>();
	public ICollection<TaskItem> Tasks { get; set; } = new List<TaskItem>();
	public ICollection<Attachment> Attachments { get; set; } = new List<Attachment>();
}
```

### `Entities/ProjectMember.cs`

```csharp
using TaskFlow.Domain.Enums;

namespace TaskFlow.Domain.Entities;

public class ProjectMember
{
	public Guid ProjectId { get; set; }
	public Project Project { get; set; } = default!;

	public Guid UserId { get; set; }
	public User User { get; set; } = default!;

	public ProjectMemberRole Role { get; set; } = ProjectMemberRole.Viewer;
	public DateTime JoinedAt { get; set; } = DateTime.UtcNow;
}
```

### `Entities/TaskItem.cs`

```csharp
using TaskFlow.Domain.Common;
using TaskFlow.Domain.Enums;

namespace TaskFlow.Domain.Entities;

public class TaskItem : BaseEntity
{
	public string Title { get; set; } = default!;
	public string? Description { get; set; }
	public Domain.Enums.TaskStatus Status { get; set; } = Domain.Enums.TaskStatus.Todo;
	public TaskPriority Priority { get; set; } = TaskPriority.Medium;
	public DateTime? DueDate { get; set; }
	public double? EstimatedHours { get; set; }
	public DateTime? CompletedAt { get; set; }
	public int Position { get; set; }

	public Guid ProjectId { get; set; }
	public Project Project { get; set; } = default!;

	public Guid CreatedById { get; set; }
	public User CreatedBy { get; set; } = default!;

	public Guid? AssigneeId { get; set; }
	public User? Assignee { get; set; }

	public ICollection<Subtask> Subtasks { get; set; } = new List<Subtask>();
	public ICollection<Comment> Comments { get; set; } = new List<Comment>();
	public ICollection<Attachment> Attachments { get; set; } = new List<Attachment>();
	public ICollection<TaskTag> TaskTags { get; set; } = new List<TaskTag>();
}
```

### `Entities/Subtask.cs`

```csharp
using TaskFlow.Domain.Common;

namespace TaskFlow.Domain.Entities;

public class Subtask : BaseEntity
{
	public Guid TaskId { get; set; }
	public TaskItem Task { get; set; } = default!;
	public string Title { get; set; } = default!;
	public bool IsCompleted { get; set; }
	public int Position { get; set; }
}
```

### `Entities/Comment.cs`

```csharp
using TaskFlow.Domain.Common;

namespace TaskFlow.Domain.Entities;

public class Comment : BaseEntity
{
	public Guid TaskId { get; set; }
	public TaskItem Task { get; set; } = default!;

	public Guid AuthorId { get; set; }
	public User Author { get; set; } = default!;

	public string Content { get; set; } = default!;
	public Guid? ParentId { get; set; }
	public Comment? Parent { get; set; }
	public ICollection<Comment> Replies { get; set; } = new List<Comment>();

	public DateTime? EditedAt { get; set; }
}
```

### `Entities/Attachment.cs`

```csharp
using TaskFlow.Domain.Common;
using TaskFlow.Domain.Enums;

namespace TaskFlow.Domain.Entities;

public class Attachment : BaseEntity
{
	public AttachmentEntityType EntityType { get; set; }
	public Guid EntityId { get; set; }                 // polymorphic FK
	public Guid UploadedById { get; set; }
	public User UploadedBy { get; set; } = default!;
	public string FileName { get; set; } = default!;
	public string FileUrl { get; set; } = default!;
	public long FileSize { get; set; }
	public string MimeType { get; set; } = default!;
}
```

### `Entities/Tag.cs` + `TaskTag.cs`

```csharp
using TaskFlow.Domain.Common;

namespace TaskFlow.Domain.Entities;

public class Tag : BaseEntity
{
	public string Name { get; set; } = default!;
	public string Color { get; set; } = "#9CA3AF";
	public Guid CreatedById { get; set; }
	public User CreatedBy { get; set; } = default!;
	public ICollection<TaskTag> TaskTags { get; set; } = new List<TaskTag>();
}

public class TaskTag
{
	public Guid TaskId { get; set; }
	public TaskItem Task { get; set; } = default!;
	public Guid TagId { get; set;
	public Tag Tag { get; set; } = default!;
}
```

### `Entities/Notification.cs` + `PushToken.cs`

```csharp
using TaskFlow.Domain.Common;
using TaskFlow.Domain.Enums;

namespace TaskFlow.Domain.Entities;

public class Notification : BaseEntity
{
	public Guid UserId { get; set; }
	public User User { get; set; } = default!;
	public NotificationType Type { get; set; }
	public string Title { get; set; } = default!;
	public string Message { get; set; } = default!;
	public string? RelatedEntityType { get; set; }    // task | project | comment
	public Guid? RelatedEntityId { get; set; }
	public bool IsRead { get; set; }
	public DateTime? ReadAt { get; set; }
}

public class PushToken : BaseEntity
{
	public Guid UserId { get; set; }
	public User User { get; set; } = default!;
	public string Token { get; set; } = default!;
	public string Platform { get; set; } = "android";  // android | ios | web
	public string? DeviceId { get; set; }
}
```

---

## STEP 3 — DbContext + Fluent API

### `Persistence/TaskFlowDbContext.cs`

```csharp
using System.Linq.Expressions;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using TaskFlow.Domain.Common;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Infrastructure.Persistence;

public class TaskFlowDbContext
	: IdentityDbContext<User, IdentityRole<Guid>, Guid>
{
	public TaskFlowDbContext(DbContextOptions<TaskFlowDbContext> options) : base(options) { }

	public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
	public DbSet<OtpCode> OtpCodes => Set<OtpCode>();
	public DbSet<Project> Projects => Set<Project>();
	public DbSet<ProjectMember> ProjectMembers => Set<ProjectMember>();
	public DbSet<TaskItem> Tasks => Set<TaskItem>();
	public DbSet<Subtask> Subtasks => Set<Subtask>();
	public DbSet<Comment> Comments => Set<Comment>();
	public DbSet<Attachment> Attachments => Set<Attachment>();
	public DbSet<Tag> Tags => Set<Tag>();
	public DbSet<TaskTag> TaskTags => Set<TaskTag>();
	public DbSet<Notification> Notifications => Set<Notification>();
	public DbSet<PushToken> PushTokens => Set<PushToken>();

	protected override void OnModelCreating(ModelBuilder builder)
	{
		base.OnModelCreating(builder);

		builder.ApplyConfigurationsFromAssembly(typeof(TaskFlowDbContext).Assembly);

		// ── Identity table renaming ──────────────────────────────
		builder.Entity<User>().ToTable("users");
		builder.Entity<IdentityRole<Guid>>().ToTable("roles");
		builder.Entity<IdentityUserRole<Guid>>().ToTable("user_roles");
		builder.Entity<IdentityUserClaim<Guid>>().ToTable("user_claims");
		builder.Entity<IdentityUserLogin<Guid>>().ToTable("user_logins");
		builder.Entity<IdentityUserToken<Guid>>().ToTable("user_tokens");
		builder.Entity<IdentityRoleClaim<Guid>>().ToTable("role_claims");

		// ── Global soft-delete query filter ─────────────────────
		foreach (var entityType in builder.Model.GetEntityTypes())
		{
			if (typeof(BaseEntity).IsAssignableFrom(entityType.ClrType) ||
				entityType.ClrType == typeof(User))
			{
				var param = Expression.Parameter(entityType.ClrType, "e");
				var prop = Expression.Property(param, nameof(BaseEntity.IsDeleted));
				var filter = Expression.Lambda(Expression.Not(prop), param);
				builder.Entity(entityType.ClrType).HasQueryFilter(filter);
			}
		}
	}

	public override Task<int> SaveChangesAsync(CancellationToken ct = default)
	{
		var now = DateTime.UtcNow;
		foreach (var entry in ChangeTracker.Entries<BaseEntity>())
		{
			switch (entry.State)
			{
				case EntityState.Added:   entry.Entity.CreatedAt = now; entry.Entity.UpdatedAt = now; break;
				case EntityState.Modified:entry.Entity.UpdatedAt = now; break;
				case EntityState.Deleted:
					entry.State = EntityState.Modified;
					entry.Entity.IsDeleted = true;
					entry.Entity.DeletedAt = now;
					break;
			}
		}
		return base.SaveChangesAsync(ct);
	}
}
```

### `Persistence/Configurations/UserConfiguration.cs`

```csharp
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Infrastructure.Persistence.Configurations;

public class UserConfiguration : IEntityTypeConfiguration<User>
{
	public void Configure(EntityTypeBuilder<User> b)
	{
		b.Property(x => x.FullName).IsRequired().HasMaxLength(150);
		b.Property(x => x.AvatarUrl).HasMaxLength(500);
		b.Property(x => x.Role).HasConversion<string>().HasMaxLength(20);
		b.HasIndex(x => x.Email).IsUnique();
		b.HasIndex(x => x.NormalizedEmail).IsUnique();
	}
}
```

### `Configurations/ProjectConfiguration.cs`

```csharp
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Infrastructure.Persistence.Configurations;

public class ProjectConfiguration : IEntityTypeConfiguration<Project>
{
	public void Configure(EntityTypeBuilder<Project> b)
	{
		b.ToTable("projects");
		b.HasKey(x => x.Id);
		b.Property(x => x.Name).IsRequired().HasMaxLength(100);
		b.Property(x => x.Description).HasMaxLength(2000);
		b.Property(x => x.ColorLabel).IsRequired().HasMaxLength(9);
		b.Property(x => x.Status).HasConversion<string>().HasMaxLength(20);
		b.Property(x => x.Priority).HasConversion<string>().HasMaxLength(20);

		b.HasOne(x => x.Owner)
		 .WithMany(u => u.OwnedProjects)
		 .HasForeignKey(x => x.OwnerId)
		 .OnDelete(DeleteBehavior.Restrict);

		b.HasIndex(x => x.OwnerId);
		b.HasIndex(x => x.Status);
	}
}
```

### `Configurations/ProjectMemberConfiguration.cs`

```csharp
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Infrastructure.Persistence.Configurations;

public class ProjectMemberConfiguration : IEntityTypeConfiguration<ProjectMember>
{
	public void Configure(EntityTypeBuilder<ProjectMember> b)
	{
		b.ToTable("project_members");
		b.HasKey(x => new { x.ProjectId, x.UserId });
		b.Property(x => x.Role).HasConversion<string>().HasMaxLength(20);

		b.HasOne(x => x.Project)
		 .WithMany(p => p.Members)
		 .HasForeignKey(x => x.ProjectId)
		 .OnDelete(DeleteBehavior.Cascade);

		b.HasOne(x => x.User)
		 .WithMany(u => u.ProjectMemberships)
		 .HasForeignKey(x => x.UserId)
		 .OnDelete(DeleteBehavior.Cascade);
	}
}
```

### `Configurations/TaskItemConfiguration.cs`

```csharp
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Infrastructure.Persistence.Configurations;

public class TaskItemConfiguration : IEntityTypeConfiguration<TaskItem>
{
	public void Configure(EntityTypeBuilder<TaskItem> b)
	{
		b.ToTable("tasks");
		b.HasKey(x => x.Id);
		b.Property(x => x.Title).IsRequired().HasMaxLength(200);
		b.Property(x => x.Description).HasMaxLength(5000);
		b.Property(x => x.Status).HasConversion<string>().HasMaxLength(20);
		b.Property(x => x.Priority).HasConversion<string>().HasMaxLength(20);

		b.HasOne(x => x.Project).WithMany(p => p.Tasks)
		 .HasForeignKey(x => x.ProjectId).OnDelete(DeleteBehavior.Cascade);

		b.HasOne(x => x.CreatedBy).WithMany(u => u.CreatedTasks)
		 .HasForeignKey(x => x.CreatedById).OnDelete(DeleteBehavior.Restrict);

		b.HasOne(x => x.Assignee).WithMany(u => u.AssignedTasks)
		 .HasForeignKey(x => x.AssigneeId).OnDelete(DeleteBehavior.SetNull);

		b.HasIndex(x => new { x.ProjectId, x.Status });
		b.HasIndex(x => x.AssigneeId);
		b.HasIndex(x => x.DueDate);
	}
}
```

### `Configurations/SubtaskConfiguration.cs`

```csharp
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Infrastructure.Persistence.Configurations;

public class SubtaskConfiguration : IEntityTypeConfiguration<Subtask>
{
	public void Configure(EntityTypeBuilder<Subtask> b)
	{
		b.ToTable("subtasks");
		b.HasKey(x => x.Id);
		b.Property(x => x.Title).IsRequired().HasMaxLength(200);
		b.HasOne(x => x.Task).WithMany(t => t.Subtasks)
		 .HasForeignKey(x => x.TaskId).OnDelete(DeleteBehavior.Cascade);
		b.HasIndex(x => x.TaskId);
	}
}
```

### `Configurations/CommentConfiguration.cs`

```csharp
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Infrastructure.Persistence.Configurations;

public class CommentConfiguration : IEntityTypeConfiguration<Comment>
{
	public void Configure(EntityTypeBuilder<Comment> b)
	{
		b.ToTable("comments");
		b.HasKey(x => x.Id);
		b.Property(x => x.Content).IsRequired().HasMaxLength(4000);

		b.HasOne(x => x.Task).WithMany(t => t.Comments)
		 .HasForeignKey(x => x.TaskId).OnDelete(DeleteBehavior.Cascade);

		b.HasOne(x => x.Author).WithMany(u => u.Comments)
		 .HasForeignKey(x => x.AuthorId).OnDelete(DeleteBehavior.Restrict);

		b.HasOne(x => x.Parent).WithMany(c => c.Replies)
		 .HasForeignKey(x => x.ParentId).OnDelete(DeleteBehavior.Restrict);

		b.HasIndex(x => x.TaskId);
	}
}
```

### `Configurations/AttachmentConfiguration.cs`

```csharp
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Infrastructure.Persistence.Configurations;

public class AttachmentConfiguration : IEntityTypeConfiguration<Attachment>
{
	public void Configure(EntityTypeBuilder<Attachment> b)
	{
		b.ToTable("attachments");
		b.HasKey(x => x.Id);
		b.Property(x => x.EntityType).HasConversion<string>().HasMaxLength(20);
		b.Property(x => x.FileName).IsRequired().HasMaxLength(255);
		b.Property(x => x.FileUrl).IsRequired().HasMaxLength(1000);
		b.Property(x => x.MimeType).IsRequired().HasMaxLength(100);
		b.HasIndex(x => new { x.EntityType, x.EntityId });
	}
}
```

### `Configurations/TagConfiguration.cs` + `TaskTagConfiguration.cs`

```csharp
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Infrastructure.Persistence.Configurations;

public class TagConfiguration : IEntityTypeConfiguration<Tag>
{
	public void Configure(EntityTypeBuilder<Tag> b)
	{
		b.ToTable("tags");
		b.HasKey(x => x.Id);
		b.Property(x => x.Name).IsRequired().HasMaxLength(50);
		b.Property(x => x.Color).IsRequired().HasMaxLength(9);
		b.HasIndex(x => new { x.CreatedById, x.Name }).IsUnique();
	}
}

public class TaskTagConfiguration : IEntityTypeConfiguration<TaskTag>
{
	public void Configure(EntityTypeBuilder<TaskTag> b)
	{
		b.ToTable("task_tags");
		b.HasKey(x => new { x.TaskId, x.TagId });

		b.HasOne(x => x.Task).WithMany(t => t.TaskTags)
		 .HasForeignKey(x => x.TaskId).OnDelete(DeleteBehavior.Cascade);

		b.HasOne(x => x.Tag).WithMany(t => t.TaskTags)
		 .HasForeignKey(x => x.TagId).OnDelete(DeleteBehavior.Cascade);
	}
}
```

### `Configurations/NotificationConfiguration.cs`

```csharp
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Infrastructure.Persistence.Configurations;

public class NotificationConfiguration : IEntityTypeConfiguration<Notification>
{
	public void Configure(EntityTypeBuilder<Notification> b)
	{
		b.ToTable("notifications");
		b.HasKey(x => x.Id);
		b.Property(x => x.Type).HasConversion<string>().HasMaxLength(30);
		b.Property(x => x.Title).IsRequired().HasMaxLength(150);
		b.Property(x => x.Message).IsRequired().HasMaxLength(1000);
		b.Property(x => x.RelatedEntityType).HasMaxLength(20);

		b.HasOne(x => x.User).WithMany(u => u.Notifications)
		 .HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Cascade);

		b.HasIndex(x => new { x.UserId, x.IsRead });
		b.HasIndex(x => x.CreatedAt);
	}
}
```

### `Configurations/RefreshTokenConfiguration.cs` + `OtpCodeConfiguration.cs`

```csharp
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Infrastructure.Persistence.Configurations;

public class RefreshTokenConfiguration : IEntityTypeConfiguration<RefreshToken>
{
	public void Configure(EntityTypeBuilder<RefreshToken> b)
	{
		b.ToTable("refresh_tokens");
		b.HasKey(x => x.Id);
		b.Property(x => x.TokenHash).IsRequired().HasMaxLength(512);
		b.HasIndex(x => x.TokenHash).IsUnique();
		b.HasOne(x => x.User).WithMany(u => u.RefreshTokens)
		 .HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Cascade);
	}
}

public class OtpCodeConfiguration : IEntityTypeConfiguration<OtpCode>
{
	public void Configure(EntityTypeBuilder<OtpCode> b)
	{
		b.ToTable("otp_codes");
		b.HasKey(x => x.Id);
		b.Property(x => x.Email).IsRequired().HasMaxLength(256);
		b.Property(x => x.CodeHash).IsRequired().HasMaxLength(256);
		b.Property(x => x.Purpose).IsRequired().HasMaxLength(50);
		b.HasIndex(x => new { x.Email, x.Purpose });
	}
}
```

---

## STEP 4 — API Endpoints Plan

### 4.1 Auth — `/api/v1/auth`

| Method | Route | Description | Auth | Request Body | Response | POST | /register | Register a new user | ❌ | RegisterRequest | ApiResponse&lt;AuthResponse&gt; |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| POST | /login | Login + return JWT pair | ❌ | LoginRequest | ApiResponse&lt;AuthResponse&gt; | POST | /logout | Revoke refresh token | ✅ | RefreshRequest | ApiResponse&lt;object&gt; |
| POST | /refresh | Exchange refresh for new access token | ❌ | RefreshRequest | ApiResponse&lt;AuthResponse&gt; | POST | /forgot-password | Send OTP to user email | ❌ | ForgotPasswordRequest | ApiResponse&lt;object&gt; |
| POST | /verify-otp | Validate OTP | ❌ | VerifyOtpRequest | ApiResponse&lt;OtpVerifiedResponse&gt; | POST | /reset-password | Set new password after OTP | ❌ | ResetPasswordRequest | ApiResponse&lt;object&gt; |

### 4.2 Users — `/api/v1/users`

| Method | Route | Description | Auth | Request Body | Response |
| --- | --- | --- | --- | --- | --- |
| PUT | /me | Update profile | ✅ | UpdateUserRequest | ApiResponse&lt;UserResponse&gt; |
| GET | /me/stats | Stats: tasks, streak, projects | ✅ | — | ApiResponse&lt;UserStatsResponse&gt; |
| GET | /search?q= | Search users by name/email | ✅ | — | ApiResponse&lt;List&lt;UserSummary&gt;&gt; |

### 4.3 Projects — `/api/v1/projects`

| Method | Route | Description | Auth | Request Body | Response | GET | / | List user's projects (paged) | ✅ | — | ApiResponse&lt;PagedResult&lt;ProjectSummary&gt;&gt; |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| POST | / | Create project | ✅ | CreateProjectRequest | ApiResponse&lt;ProjectResponse&gt; | GET | /{id} | Get project with members | ✅ | — | ApiResponse&lt;ProjectResponse&gt; |
| PUT | /{id} | Update project | ✅ | UpdateProjectRequest | ApiResponse&lt;ProjectResponse&gt; | DELETE | /{id} | Delete project + tasks | ✅ | — | ApiResponse&lt;object&gt; |
| GET | /{id}/stats | Completion stats by status | ✅ | — | ApiResponse&lt;ProjectStatsResponse&gt; | POST | /{id}/members | Invite member | ✅ | InviteMemberRequest | ApiResponse&lt;ProjectMemberResponse&gt; |
| DELETE | /{id}/members/{userId} | Remove member | ✅ | — | ApiResponse&lt;object&gt; | PATCH | /{id}/members/{userId} | Change member role | ✅ | ChangeMemberRoleRequest | ApiResponse&lt;ProjectMemberResponse&gt; |
| GET | /{id}/attachments | List files | ✅ | — | ApiResponse&lt;List&lt;AttachmentResponse&gt;&gt; | POST | /{id}/attachments | Upload file | ✅ | IFormFile | ApiResponse&lt;AttachmentResponse&gt; |

### 4.4 Tasks — `/api/v1/tasks`

| Method | Route | Description | Auth | Request Body | Response |
| --- | --- | --- | --- | --- | --- |
| POST | / | Create task | ✅ | CreateTaskRequest | ApiResponse&lt;TaskResponse&gt; |
| PUT | /{id} | Full update | ✅ | UpdateTaskRequest | ApiResponse&lt;TaskResponse&gt; |
| PATCH | /{id}/position | Kanban reorder | ✅ | ReorderTaskRequest | ApiResponse&lt;object&gt; |
| GET | /projects/{projectId}/tasks | Tasks in project | ✅ | — | ApiResponse&lt;List&lt;TaskSummary&gt;&gt; |
| PATCH | /{id}/subtasks/{sid} | Toggle/rename | ✅ | UpdateSubtaskRequest | ApiResponse&lt;SubtaskResponse&gt; |
| GET | /{id}/attachments | List task files | ✅ | — | ApiResponse&lt;List&lt;AttachmentResponse&gt;&gt; |
| DELETE | /{id}/attachments/{aid} | Remove file | ✅ | — | ApiResponse&lt;object&gt; |

### 4.5 Comments — `/api/v1/tasks/{id}/comments`

| Method | Route | Description | Auth | Request Body | Response |
| --- | --- | --- | --- | --- | --- |
| POST | / | Post comment | ✅ | CreateCommentRequest | ApiResponse&lt;CommentResponse&gt; |
| DELETE | /{cid} | Delete (own/admin) | ✅ | — | ApiResponse&lt;object&gt; |

### 4.6 Tags — `/api/v1/tags`

| Method | Route | Description | Auth | Request Body | Response | GET | / | List user tags | ✅ | — | ApiResponse&lt;List&lt;TagResponse&gt;&gt; |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| POST | / | Create tag | ✅ | CreateTagRequest | ApiResponse&lt;TagResponse&gt; | DELETE | /{id} | Delete tag | ✅ | — | ApiResponse&lt;object&gt; |

### 4.7 Notifications — `/api/v1/notifications`

| Method | Route | Description | Auth | Request Body | Response | GET | / | Paged feed | ✅ | — | ApiResponse&lt;PagedResult&lt;NotificationResponse&gt;&gt; |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| PATCH | /{id}/read | Mark single as read | ✅ | — | ApiResponse&lt;object&gt; | POST | /read-all | Mark all as read | ✅ | — | ApiResponse&lt;object&gt; |
| DELETE | /{id} | Delete notification | ✅ | — | ApiResponse&lt;object&gt; | POST | /push-token | Register FCM token | ✅ | RegisterPushTokenRequest | ApiResponse&lt;object&gt; |

---

## STEP 5 — DTOs

### `Shared/Wrappers/ApiResponse.cs` + `PagedResult.cs`

```csharp
namespace TaskFlow.Shared.Wrappers;

public class ApiResponse<T>
{
	public bool Success { get; set; }
	public T? Data { get; set; }
	public string? Message { get; set; }
	public List<string> Errors { get; set; } = new();

	public static ApiResponse<T> Ok(T data, string? message = null)
		=> new() { Success = true, Data = data, Message = message };

	public static ApiResponse<T> Fail(string message, List<string>? errors = null)
		=> new() { Success = false, Message = message, Errors = errors ?? new() };
}

public class PagedResult<T>
{
	public IReadOnlyList<T> Items { get; set; } = Array.Empty<T>();
	public int Page { get; set; }
	public int PageSize { get; set; }
	public int TotalCount { get; set; }
	public int TotalPages => (int)Math.Ceiling(TotalCount / (double)PageSize);
	public bool HasPrevious => Page > 1;
	public bool HasNext => Page < TotalPages;
}
```

### `DTOs/Auth/*`

```csharp
namespace TaskFlow.Application.DTOs.Auth;

// FluentValidation:
//   FullName: NotEmpty, MaxLength(150)
//   Email:    NotEmpty, EmailAddress
//   Password: NotEmpty, MinLength(8), Matches("[A-Z]"), Matches("[0-9]")
public record RegisterRequest(string FullName, string Email, string Password, string? AvatarUrl);

// Email: NotEmpty, EmailAddress
// Password: NotEmpty
public record LoginRequest(string Email, string Password);

// RefreshToken: NotEmpty
public record RefreshRequest(string RefreshToken);

// Email: NotEmpty, EmailAddress
public record ForgotPasswordRequest(string Email);

// Email + Code (4–6 digits)
public record VerifyOtpRequest(string Email, string Code);
public record OtpVerifiedResponse(string ResetToken);

// Email + ResetToken + NewPassword (same rules as Register)
public record ResetPasswordRequest(string Email, string ResetToken, string NewPassword);

public record AuthResponse(
	string AccessToken,
	string RefreshToken,
	DateTime AccessTokenExpiresAt,
	DateTime RefreshTokenExpiresAt,
	UserResponse User
);

public record UserResponse(
	Guid Id,
	string FullName,
	string Email,
	string? AvatarUrl,
	string Role
);
```

### `DTOs/Users/*`

```csharp
namespace TaskFlow.Application.DTOs.Users;

// FullName: NotEmpty, MaxLength(150)
// AvatarUrl: optional URL
public record UpdateUserRequest(string FullName, string? AvatarUrl);

public record UserStatsResponse(
	int CompletedTasks,
	int TotalTasks,
	double CompletionRate,
	int ActiveProjects,
	int Streak
);

public record AvatarResponse(string AvatarUrl);
public record UserSummary(Guid Id, string FullName, string Email, string? AvatarUrl);
```

### `DTOs/Projects/*`

```csharp
namespace TaskFlow.Application.DTOs.Projects;

// Name: NotEmpty, MaxLength(100)
// ColorLabel: NotEmpty, Matches("^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$")
// DueDate: GreaterThanOrEqualTo(StartDate) when both present
public record CreateProjectRequest(
	string Name, string? Description, string ColorLabel,
	string Priority, DateTime? StartDate, DateTime? DueDate,
	List<Guid>? MemberIds);

public record UpdateProjectRequest(
	string Name, string? Description, string ColorLabel,
	string Status, string Priority, DateTime? StartDate, DateTime? DueDate);

// UserId: NotEmpty; Role: must be Owner|Editor|Viewer
public record InviteMemberRequest(Guid UserId, string Role);
public record ChangeMemberRoleRequest(string Role);

public record ProjectSummary(Guid Id, string Name, string ColorLabel,
	string Status, double CompletionPercentage, int MemberCount, int TaskCount, DateTime? DueDate);

public record ProjectMemberResponse(Guid UserId, string FullName, string? AvatarUrl, string Role);

public record ProjectResponse(
	Guid Id, string Name, string? Description, string ColorLabel,
	string Status, string Priority, DateTime? StartDate, DateTime? DueDate,
	Guid OwnerId, double CompletionPercentage,
	List<ProjectMemberResponse> Members);

public record ProjectStatsResponse(
	int Total, int Todo, int InProgress, int Review, int Done, double CompletionRate);
```

### `DTOs/Tasks/*`

```csharp
namespace TaskFlow.Application.DTOs.Tasks;

// Title: NotEmpty, MaxLength(200)
// ProjectId: NotEmpty
// Status, Priority: must be valid enum string
public record CreateTaskRequest(
	string Title, string? Description, Guid ProjectId, Guid? AssigneeId,
	string Status, string Priority, DateTime? DueDate,
	double? EstimatedHours, List<Guid>? TagIds, List<CreateSubtaskItem>? Subtasks);

public record CreateSubtaskItem(string Title, int Position);

public record UpdateTaskRequest(
	string Title, string? Description, Guid? AssigneeId,
	string Status, string Priority, DateTime? DueDate, double? EstimatedHours);

// Status: enum string
public record UpdateStatusRequest(string Status);

// NewStatus + NewPosition (>=0)
public record ReorderTaskRequest(string NewStatus, int NewPosition);

public record CreateSubtaskRequest(string Title, int Position);
public record UpdateSubtaskRequest(string? Title, bool? IsCompleted, int? Position);

public record TaskSummary(
	Guid Id, string Title, string Status, string Priority,
	DateTime? DueDate, Guid? AssigneeId, string? AssigneeName,
	Guid ProjectId, string ProjectName);

public record SubtaskResponse(Guid Id, string Title, bool IsCompleted, int Position);
public record TagBrief(Guid Id, string Name, string Color);
public record AssigneeBrief(Guid Id, string FullName, string? AvatarUrl);

public record TaskResponse(
	Guid Id, string Title, string? Description, string Status, string Priority,
	DateTime? DueDate, Guid ProjectId, AssigneeBrief? Assignee, int Position);

public record TaskDetailResponse(
	Guid Id, string Title, string? Description, string Status, string Priority,
	DateTime? DueDate, double? EstimatedHours, Guid ProjectId,
	AssigneeBrief? Assignee, AssigneeBrief CreatedBy,
	List<SubtaskResponse> Subtasks, List<TagBrief> Tags,
	int CommentCount, int AttachmentCount,
	DateTime CreatedAt, DateTime UpdatedAt);
```

### `DTOs/Comments/*`, `DTOs/Tags/*`, `DTOs/Notifications/*`, `DTOs/Attachments/*`

```csharp
namespace TaskFlow.Application.DTOs.Comments;
// Content: NotEmpty, MaxLength(4000)
public record CreateCommentRequest(string Content, Guid? ParentId);
public record UpdateCommentRequest(string Content);
public record CommentResponse(Guid Id, Guid TaskId, Guid AuthorId,
	string AuthorName, string? AuthorAvatar, string Content,
	Guid? ParentId, DateTime CreatedAt, DateTime? EditedAt);

namespace TaskFlow.Application.DTOs.Tags;
// Name: NotEmpty, MaxLength(50); Color: hex
public record CreateTagRequest(string Name, string Color);
public record TagResponse(Guid Id, string Name, string Color);

namespace TaskFlow.Application.DTOs.Notifications;
public record NotificationResponse(Guid Id, string Type, string Title,
	string Message, string? RelatedEntityType, Guid? RelatedEntityId,
	bool IsRead, DateTime CreatedAt);
// Token: NotEmpty; Platform: android|ios|web
public record RegisterPushTokenRequest(string Token, string Platform, string? DeviceId);

namespace TaskFlow.Application.DTOs.Attachments;
public record AttachmentResponse(Guid Id, string FileName, string FileUrl,
	long FileSize, string MimeType, Guid UploadedById, DateTime CreatedAt);
```

---

## STEP 6 — Repository Pattern

### `Application/Common/Interfaces/IGenericRepository.cs`

```csharp
using System.Linq.Expressions;

namespace TaskFlow.Application.Common.Interfaces;

public interface IGenericRepository<T> where T : class
{
	Task<T?> GetByIdAsync(Guid id, CancellationToken ct = default);
	Task<IReadOnlyList<T>> GetAllAsync(CancellationToken ct = default);
	Task<IReadOnlyList<T>> FindAsync(Expression<Func<T, bool>> predicate, CancellationToken ct = default);
	IQueryable<T> Query();
	Task AddAsync(T entity, CancellationToken ct = default);
	void Update(T entity);
	void Delete(T entity);
	Task<bool> ExistsAsync(Expression<Func<T, bool>> predicate, CancellationToken ct = default);
}
```

### Specialized repository interfaces

```csharp
using TaskFlow.Domain.Entities;

namespace TaskFlow.Application.Common.Interfaces;

public interface IUserRepository : IGenericRepository<User>
{
	Task<User?> GetByEmailAsync(string email, CancellationToken ct = default);
	Task<IReadOnlyList<User>> SearchAsync(string query, int take, CancellationToken ct = default);
}

public interface IProjectRepository : IGenericRepository<Project>
{
	Task<Project?> GetWithMembersAsync(Guid id, CancellationToken ct = default);
	Task<IReadOnlyList<Project>> GetForUserAsync(Guid userId, int page, int pageSize, CancellationToken ct = default);
	Task<int> CountForUserAsync(Guid userId, CancellationToken ct = default);
	Task<bool> IsMemberAsync(Guid projectId, Guid userId, CancellationToken ct = default);
}

public interface ITaskRepository : IGenericRepository<TaskItem>
{
	Task<TaskItem?> GetWithDetailsAsync(Guid id, CancellationToken ct = default);
	Task<IReadOnlyList<TaskItem>> GetByProjectAsync(Guid projectId, CancellationToken ct = default);
	Task<int> GetMaxPositionAsync(Guid projectId, Domain.Enums.TaskStatus status, CancellationToken ct = default);
}

public interface INotificationRepository : IGenericRepository<Notification>
{
	Task<int> CountUnreadAsync(Guid userId, CancellationToken ct = default);
	Task MarkAllReadAsync(Guid userId, CancellationToken ct = default);
}

public interface IUnitOfWork : IAsyncDisposable
{
	IUserRepository Users { get; }
	IProjectRepository Projects { get; }
	ITaskRepository Tasks { get; }
	INotificationRepository Notifications { get; }
	IGenericRepository<Comment> Comments { get; }
	IGenericRepository<Subtask> Subtasks { get; }
	IGenericRepository<Tag> Tags { get; }
	IGenericRepository<TaskTag> TaskTags { get; }
	IGenericRepository<Attachment> Attachments { get; }
	IGenericRepository<ProjectMember> ProjectMembers { get; }
	IGenericRepository<RefreshToken> RefreshTokens { get; }
	IGenericRepository<OtpCode> OtpCodes { get; }
	IGenericRepository<PushToken> PushTokens { get; }
	Task<int> SaveChangesAsync(CancellationToken ct = default);
	Task BeginTransactionAsync(CancellationToken ct = default);
	Task CommitAsync(CancellationToken ct = default);
	Task RollbackAsync(CancellationToken ct = default);
}
```

---

## STEP 7 — Program.cs Setup

### `appsettings.json` (placeholder)

```json
{
  "ConnectionStrings": {
	"DefaultConnection": "Host=db.<project-ref>.supabase.co;Port=5432;Database=postgres;Username=postgres;Password=<YOUR-PASSWORD>;SSL Mode=Require;Trust Server Certificate=true"
  },
  "Jwt": {
	"Issuer": "TaskFlow.API",
	"Audience": "TaskFlow.Mobile",
	"SecretKey": "REPLACE_WITH_64+_CHAR_RANDOM_BASE64_SECRET",
	"AccessTokenMinutes": 15,
	"RefreshTokenDays": 7
  },
  "Cors": { "AllowedOrigins": [ "*" ] },
  "Smtp": { "Host": "", "Port": 587, "User": "", "Password": "", "From": "" },
  "Fcm":  { "ServiceAccountJsonPath": "firebase-service-account.json" },
  "Storage": { "Bucket": "taskflow-files", "Endpoint": "" },
  "Logging": { "LogLevel": { "Default": "Information" } },
  "AllowedHosts": "*"
}
```

### `TaskFlow.API/Program.cs`

```csharp
using System.Text;
using System.Threading.RateLimiting;
using FluentValidation;
using FluentValidation.AspNetCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using TaskFlow.API.Middleware;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Application.Common.Mappings;
using TaskFlow.Domain.Entities;
using TaskFlow.Infrastructure.Identity;
using TaskFlow.Infrastructure.Persistence;
using TaskFlow.Infrastructure.Persistence.Repositories;
using TaskFlow.Infrastructure.Services;

var builder = WebApplication.CreateBuilder(args);
var config = builder.Configuration;

// ── 1. EF Core + PostgreSQL ─────────────────────────────────────
builder.Services.AddDbContext<TaskFlowDbContext>(opts =>
	opts.UseNpgsql(config.GetConnectionString("DefaultConnection"),
		npg => npg.MigrationsAssembly(typeof(TaskFlowDbContext).Assembly.FullName))
		.UseSnakeCaseNamingConvention());

// ── 2. ASP.NET Identity (Guid keys) ─────────────────────────────
builder.Services
	.AddIdentity<User, IdentityRole<Guid>>(o =>
	{
		o.Password.RequiredLength = 8;
		o.Password.RequireNonAlphanumeric = false;
		o.User.RequireUniqueEmail = true;
		o.Lockout.MaxFailedAccessAttempts = 5;
	})
	.AddEntityFrameworkStores<TaskFlowDbContext>()
	.AddDefaultTokenProviders();

// ── 3. JWT Authentication ───────────────────────────────────────
var jwt = config.GetSection("Jwt").Get<JwtSettings>()!;
builder.Services.AddSingleton(jwt);

var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt.SecretKey));
builder.Services
	.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
	.AddJwtBearer(o =>
	{
		o.TokenValidationParameters = new TokenValidationParameters
		{
			ValidateIssuer = true,
			ValidIssuer = jwt.Issuer,
			ValidateAudience = true,
			ValidAudience = jwt.Audience,
			ValidateLifetime = true,
			ValidateIssuerSigningKey = true,
			IssuerSigningKey = key,
			ClockSkew = TimeSpan.FromSeconds(30)
		};
	});

builder.Services.AddAuthorization();

// Refresh token notes:
//  - access token (15m) returned in body; client stores in memory.
//  - refresh token (7d) is a random 64-byte base64 string;
//    we store ONLY a SHA-256 hash in refresh_tokens table.
//  - /auth/refresh: lookup hash → validate IsActive → rotate (revoke + issue new).
//  - /auth/logout : revoke active refresh token for this user.

// ── 4. AutoMapper ───────────────────────────────────────────────
builder.Services.AddAutoMapper(cfg => cfg.AddProfile<MappingProfile>());

// ── 5. FluentValidation ─────────────────────────────────────────
builder.Services.AddFluentValidationAutoValidation();
builder.Services.AddFluentValidationClientsideAdapters();
builder.Services.AddValidatorsFromAssembly(typeof(MappingProfile).Assembly);

// ── 6. CORS (Flutter mobile / web) ──────────────────────────────
builder.Services.AddCors(o => o.AddPolicy("FlutterClient", p => p
	.WithOrigins(config.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? new[] { "*" })
	.AllowAnyMethod()
	.AllowAnyHeader()));

// ── 7. Swagger + JWT ────────────────────────────────────────────
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
	c.SwaggerDoc("v1", new OpenApiInfo { Title = "TaskFlow API", Version = "v1" });
	c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
	{
		In = ParameterLocation.Header,
		Description = "Enter: Bearer {your JWT}",
		Name = "Authorization",
		Type = SecuritySchemeType.ApiKey,
		Scheme = "Bearer"
	});
	c.AddSecurityRequirement(new OpenApiSecurityRequirement
	{
		{ new OpenApiSecurityScheme {
			Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
		}, Array.Empty<string>() }
	});
});

// ── 8. Rate Limiting ────────────────────────────────────────────
builder.Services.AddRateLimiter(o =>
{
	o.RejectionStatusCode = 429;
	o.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(ctx =>
		RateLimitPartition.GetFixedWindowLimiter(
			ctx.User.Identity?.Name ?? ctx.Connection.RemoteIpAddress?.ToString() ?? "anon",
			_ => new FixedWindowRateLimiterOptions
			{
				PermitLimit = 100,
				Window = TimeSpan.FromMinutes(1),
				QueueLimit = 0
			}));
	o.AddPolicy("auth", ctx =>
		RateLimitPartition.GetFixedWindowLimiter(
			ctx.Connection.RemoteIpAddress?.ToString() ?? "anon",
			_ => new FixedWindowRateLimiterOptions
			{ PermitLimit = 10, Window = TimeSpan.FromMinutes(1), QueueLimit = 0 }));
});

// ── 9. DI: Repositories + Services ──────────────────────────────
builder.Services.AddScoped(typeof(IGenericRepository<>), typeof(GenericRepository<>));
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IProjectRepository, ProjectRepository>();
builder.Services.AddScoped<ITaskRepository, TaskRepository>();
builder.Services.AddScoped<INotificationRepository, NotificationRepository>();
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();

builder.Services.AddScoped<IJwtTokenService, JwtTokenService>();
builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();
builder.Services.AddScoped<IEmailService, EmailService>();
builder.Services.AddScoped<IOtpService, OtpService>();
builder.Services.AddScoped<IFileStorageService, FileStorageService>();
builder.Services.AddScoped<IPushNotificationService, FcmPushNotificationService>();

builder.Services.AddHttpContextAccessor();
builder.Services.AddControllers();

var app = builder.Build();

// ── 10. Middleware Pipeline ─────────────────────────────────────
if (app.Environment.IsDevelopment())
{
	app.UseSwagger();
	app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseMiddleware<ExceptionHandlingMiddleware>();
app.UseCors("FlutterClient");
app.UseRateLimiter();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

// auto-migrate (dev only)
if (app.Environment.IsDevelopment())
{
	using var scope = app.Services.CreateScope();
	var db = scope.ServiceProvider.GetRequiredService<TaskFlowDbContext>();
	await db.Database.MigrateAsync();
}

app.Run();
```

### `TaskFlow.API/Middleware/ExceptionHandlingMiddleware.cs`

```csharp
using System.Net;
using System.Text.Json;
using FluentValidation;
using TaskFlow.Domain.Exceptions;
using TaskFlow.Shared.Wrappers;

namespace TaskFlow.API.Middleware;

public class ExceptionHandlingMiddleware
{
	private readonly RequestDelegate _next;
	private readonly ILogger<ExceptionHandlingMiddleware> _logger;

	public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
	{ _next = next; _logger = logger; }

	public async Task Invoke(HttpContext ctx)
	{
		try { await _next(ctx); }
		catch (ValidationException ex) { await Write(ctx, HttpStatusCode.BadRequest,
			"Validation failed", ex.Errors.Select(e => e.ErrorMessage).ToList()); }
		catch (NotFoundException ex)   { await Write(ctx, HttpStatusCode.NotFound, ex.Message); }
		catch (ForbiddenException ex)  { await Write(ctx, HttpStatusCode.Forbidden, ex.Message); }
		catch (UnauthorizedAccessException ex) { await Write(ctx, HttpStatusCode.Unauthorized, ex.Message); }
		catch (Exception ex)
		{
			_logger.LogError(ex, "Unhandled exception");
			await Write(ctx, HttpStatusCode.InternalServerError, "An unexpected error occurred.");
		}
	}

	private static Task Write(HttpContext ctx, HttpStatusCode code, string message, List<string>? errors = null)
	{
		ctx.Response.StatusCode = (int)code;
		ctx.Response.ContentType = "application/json";
		var body = ApiResponse<object>.Fail(message, errors);
		return ctx.Response.WriteAsync(JsonSerializer.Serialize(body,
			new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase }));
	}
}
```

---

## STEP 8 — 2-Hour Sprint Plan

| Time | Task | Files / Commands | Done |
| --- | --- | --- | --- |
| 0:00–0:10 | Create solution + 5 projects + project references | `dotnet new sln -n TaskFlow` · `dotnet new webapi -n TaskFlow.API` · `classlib` for Application/Domain/Infrastructure/Shared · `dotnet add reference` | ☐ |
| 0:20–0:25 | Wire `appsettings.json` (Supabase conn string, JWT secret) | appsettings.json, appsettings.Development.json | ☐ |
| 0:25–0:40 | Create BaseEntity, all enums, all entities | Domain/Common, Domain/Enums, Domain/Entities/*.cs | ☐ |
| ▶ Block 3 — Repos + DTOs + Identity (0:55 – 1:25) | 0:55–1:05 | Generic + specialized repositories + UnitOfWork | Application/Common/Interfaces/*, Infrastructure/Persistence/Repositories/*, UnitOfWork.cs |
| 1:05–1:15 | ApiResponse, PagedResult, Auth + User DTOs + validators | Shared/Wrappers/*, DTOs/Auth/*, DTOs/Users/*, Validators/Auth/* | ☐ |
| ▶ Block 4 — API Layer (1:25 – 1:50) | 1:25–1:35 | Program.cs (full DI + JWT + Swagger + CORS + RateLimit) | Program.cs, ExceptionHandlingMiddleware.cs |
| 1:35–1:45 | AuthController (Register + Login) | Controllers/V1/AuthController.cs + Auth use cases (Register, Login) | ☐ |
| ▶ Block 5 — Verify (1:50 – 2:00) | 1:50–1:55 | Run API + open Swagger | `dotnet run --project TaskFlow.API` → [https://localhost:5001/swagger](https://localhost:5001/swagger) |
| 1:55–2:00 | Test register → login → call protected endpoint with Bearer token | Swagger UI / Postman | ☐ |

### ✅ Definition of Done at 2:00

- [x]  API runs on `https://localhost:5001`
- [x]  Swagger UI at `/swagger` with the **Authorize 🔒** button
- [x]  `POST /api/v1/auth/register` creates a row in `users` (Supabase Postgres)
- [x]  `POST /api/v1/auth/login` returns `{ accessToken, refreshToken }`
- [x]  JWT validated on protected endpoints (`GET /api/v1/users/me` returns 200 with Bearer)
- [x]  EF migration applied to Supabase; all tables created with snake_case naming
- [x]  Global exception middleware wraps every error in `ApiResponse`

<aside>
⚡

**Quick install command (paste in terminal):**

`dotnet add TaskFlow.API package Microsoft.AspNetCore.Authentication.JwtBearer Swashbuckle.AspNetCore` and analogous adds for `Microsoft.EntityFrameworkCore.Design`, `Npgsql.EntityFrameworkCore.PostgreSQL`, `EFCore.NamingConventions`, `Microsoft.AspNetCore.Identity.EntityFrameworkCore`, `AutoMapper.Extensions.Microsoft.DependencyInjection`, `FluentValidation.AspNetCore` on the appropriate projects.

</aside>
# Task-Flow — .NET 8 Backend (Part 2: Implementation, Services & Controllers)

<aside>
🧩

**Part 2 of the Task-Flow backend.** This page completes the API: repository implementations, UnitOfWork, JWT + Identity services, OTP/Email/Storage/FCM, AutoMapper profile, FluentValidators, and the full set of Controllers + Use Cases for every endpoint group from Part 1.

Pair this with **Part 1** (Solution, Entities, DbContext, DTOs, Repos, Program.cs).

</aside>

## 1. Domain Exceptions

```csharp
namespace TaskFlow.Domain.Exceptions;

public class DomainException : Exception
{
	public DomainException(string message) : base(message) { }
}

public class NotFoundException : DomainException
{
	public NotFoundException(string entity, object key)
		: base($"{entity} with key '{key}' was not found.") { }
	public NotFoundException(string message) : base(message) { }
}

public class ForbiddenException : DomainException
{
	public ForbiddenException(string message = "You are not allowed to perform this action.")
		: base(message) { }
}

public class ConflictException : DomainException
{
	public ConflictException(string message) : base(message) { }
}
```

## 2. Application Interfaces & JwtSettings

### `Infrastructure/Identity/JwtSettings.cs`

```csharp
namespace TaskFlow.Infrastructure.Identity;

public class JwtSettings
{
	public string Issuer { get; set; } = default!;
	public string Audience { get; set; } = default!;
	public string SecretKey { get; set; } = default!;
	public int AccessTokenMinutes { get; set; } = 15;
	public int RefreshTokenDays { get; set; } = 7;
}
```

### `Application/Common/Interfaces/*.cs`

```csharp
using TaskFlow.Domain.Entities;

namespace TaskFlow.Application.Common.Interfaces;

public interface ICurrentUserService
{
	Guid? UserId { get; }
	string? Email { get; }
	bool IsAuthenticated { get; }
}

public interface IJwtTokenService
{
	(string AccessToken, DateTime ExpiresAt) GenerateAccessToken(User user, IList<string> roles);
	(string RawToken, string Hash, DateTime ExpiresAt) GenerateRefreshToken();
	string HashToken(string raw);
}

public interface IEmailService
{
	Task SendAsync(string to, string subject, string htmlBody, CancellationToken ct = default);
}

public interface IOtpService
{
	Task<string> CreateAsync(string email, string purpose, CancellationToken ct = default);
	Task<bool> VerifyAsync(string email, string code, string purpose, CancellationToken ct = default);
}

public interface IFileStorageService
{
	Task<(string Url, string FileName, string MimeType, long Size)> UploadAsync(
		Stream stream, string fileName, string contentType, CancellationToken ct = default);
	Task DeleteAsync(string url, CancellationToken ct = default);
}

public interface IPushNotificationService
{
	Task SendToUserAsync(Guid userId, string title, string body,
		IDictionary<string, string>? data = null, CancellationToken ct = default);
}
```

## 3. Repository Implementations

### `Persistence/Repositories/GenericRepository.cs`

```csharp
using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore;
using TaskFlow.Application.Common.Interfaces;

namespace TaskFlow.Infrastructure.Persistence.Repositories;

public class GenericRepository<T> : IGenericRepository<T> where T : class
{
	protected readonly TaskFlowDbContext Db;
	protected readonly DbSet<T> Set;

	public GenericRepository(TaskFlowDbContext db) { Db = db; Set = db.Set<T>(); }

	public IQueryable<T> Query() => Set.AsQueryable();

	public Task<T?> GetByIdAsync(Guid id, CancellationToken ct = default)
		=> Set.FindAsync(new object[] { id }, ct).AsTask();

	public async Task<IReadOnlyList<T>> GetAllAsync(CancellationToken ct = default)
		=> await Set.AsNoTracking().ToListAsync(ct);

	public async Task<IReadOnlyList<T>> FindAsync(Expression<Func<T, bool>> predicate, CancellationToken ct = default)
		=> await Set.AsNoTracking().Where(predicate).ToListAsync(ct);

	public Task AddAsync(T entity, CancellationToken ct = default) => Set.AddAsync(entity, ct).AsTask();
	public void Update(T entity) => Set.Update(entity);
	public void Delete(T entity) => Set.Remove(entity);

	public Task<bool> ExistsAsync(Expression<Func<T, bool>> predicate, CancellationToken ct = default)
		=> Set.AnyAsync(predicate, ct);
}
```

### `Persistence/Repositories/UserRepository.cs`

```csharp
using Microsoft.EntityFrameworkCore;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Infrastructure.Persistence.Repositories;

public class UserRepository : GenericRepository<User>, IUserRepository
{
	public UserRepository(TaskFlowDbContext db) : base(db) { }

	public Task<User?> GetByEmailAsync(string email, CancellationToken ct = default)
		=> Set.FirstOrDefaultAsync(u => u.NormalizedEmail == email.ToUpperInvariant(), ct);

	public async Task<IReadOnlyList<User>> SearchAsync(string query, int take, CancellationToken ct = default)
	{
		var q = (query ?? "").Trim().ToLower();
		return await Set.AsNoTracking()
			.Where(u => u.FullName.ToLower().Contains(q) || u.Email!.ToLower().Contains(q))
			.OrderBy(u => u.FullName).Take(take).ToListAsync(ct);
	}
}
```

### `Persistence/Repositories/ProjectRepository.cs`

```csharp
using Microsoft.EntityFrameworkCore;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Infrastructure.Persistence.Repositories;

public class ProjectRepository : GenericRepository<Project>, IProjectRepository
{
	public ProjectRepository(TaskFlowDbContext db) : base(db) { }

	public Task<Project?> GetWithMembersAsync(Guid id, CancellationToken ct = default)
		=> Set.Include(p => p.Members).ThenInclude(m => m.User)
			  .Include(p => p.Owner)
			  .FirstOrDefaultAsync(p => p.Id == id, ct);

	public async Task<IReadOnlyList<Project>> GetForUserAsync(
		Guid userId, int page, int pageSize, CancellationToken ct = default)
	{
		return await Set.AsNoTracking()
			.Where(p => p.OwnerId == userId || p.Members.Any(m => m.UserId == userId))
			.OrderByDescending(p => p.UpdatedAt)
			.Skip((page - 1) * pageSize).Take(pageSize)
			.ToListAsync(ct);
	}

	public Task<int> CountForUserAsync(Guid userId, CancellationToken ct = default)
		=> Set.CountAsync(p => p.OwnerId == userId || p.Members.Any(m => m.UserId == userId), ct);

	public Task<bool> IsMemberAsync(Guid projectId, Guid userId, CancellationToken ct = default)
		=> Set.AnyAsync(p => p.Id == projectId &&
			(p.OwnerId == userId || p.Members.Any(m => m.UserId == userId)), ct);
}
```

### `Persistence/Repositories/TaskRepository.cs`

```csharp
using Microsoft.EntityFrameworkCore;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Domain.Entities;
using DomainTaskStatus = TaskFlow.Domain.Enums.TaskStatus;

namespace TaskFlow.Infrastructure.Persistence.Repositories;

public class TaskRepository : GenericRepository<TaskItem>, ITaskRepository
{
	public TaskRepository(TaskFlowDbContext db) : base(db) { }

	public Task<TaskItem?> GetWithDetailsAsync(Guid id, CancellationToken ct = default)
		=> Set.Include(t => t.Subtasks)
			  .Include(t => t.TaskTags).ThenInclude(tt => tt.Tag)
			  .Include(t => t.Assignee)
			  .Include(t => t.CreatedBy)
			  .FirstOrDefaultAsync(t => t.Id == id, ct);

	public async Task<IReadOnlyList<TaskItem>> GetByProjectAsync(Guid projectId, CancellationToken ct = default)
		=> await Set.AsNoTracking().Include(t => t.Assignee).Include(t => t.Project)
			.Where(t => t.ProjectId == projectId)
			.OrderBy(t => t.Status).ThenBy(t => t.Position).ToListAsync(ct);

	public async Task<int> GetMaxPositionAsync(Guid projectId, DomainTaskStatus status, CancellationToken ct = default)
	{
		var max = await Set.Where(t => t.ProjectId == projectId && t.Status == status)
						   .Select(t => (int?)t.Position).MaxAsync(ct);
		return max ?? -1;
	}
}
```

### `Persistence/Repositories/NotificationRepository.cs`

```csharp
using Microsoft.EntityFrameworkCore;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Infrastructure.Persistence.Repositories;

public class NotificationRepository : GenericRepository<Notification>, INotificationRepository
{
	public NotificationRepository(TaskFlowDbContext db) : base(db) { }

	public Task<int> CountUnreadAsync(Guid userId, CancellationToken ct = default)
		=> Set.CountAsync(n => n.UserId == userId && !n.IsRead, ct);

	public async Task MarkAllReadAsync(Guid userId, CancellationToken ct = default)
	{
		var now = DateTime.UtcNow;
		await Set.Where(n => n.UserId == userId && !n.IsRead)
			.ExecuteUpdateAsync(s => s
				.SetProperty(n => n.IsRead, true)
				.SetProperty(n => n.ReadAt, now)
				.SetProperty(n => n.UpdatedAt, now), ct);
	}
}
```

### `Persistence/UnitOfWork.cs`

```csharp
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
}
```

## 4. Identity & Token Services

### `Identity/JwtTokenService.cs`

```csharp
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Infrastructure.Identity;

public class JwtTokenService : IJwtTokenService
{
	private readonly JwtSettings _s;
	public JwtTokenService(JwtSettings s) { _s = s; }

	public (string AccessToken, DateTime ExpiresAt) GenerateAccessToken(User user, IList<string> roles)
	{
		var claims = new List<Claim>
		{
			new(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
			new(JwtRegisteredClaimNames.Email, user.Email ?? ""),
			new("name", user.FullName),
			new("role", user.Role.ToString()),
			new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
		};
		claims.AddRange(roles.Select(r => new Claim(ClaimTypes.Role, r)));

		var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_s.SecretKey));
		var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
		var expires = DateTime.UtcNow.AddMinutes(_s.AccessTokenMinutes);

		var jwt = new JwtSecurityToken(
			issuer: _s.Issuer, audience: _s.Audience,
			claims: claims, expires: expires, signingCredentials: creds);

		return (new JwtSecurityTokenHandler().WriteToken(jwt), expires);
	}

	public (string RawToken, string Hash, DateTime ExpiresAt) GenerateRefreshToken()
	{
		var bytes = RandomNumberGenerator.GetBytes(64);
		var raw = Convert.ToBase64String(bytes);
		return (raw, HashToken(raw), DateTime.UtcNow.AddDays(_s.RefreshTokenDays));
	}

	public string HashToken(string raw)
	{
		using var sha = SHA256.Create();
		return Convert.ToHexString(sha.ComputeHash(Encoding.UTF8.GetBytes(raw)));
	}
}
```

### `Identity/CurrentUserService.cs`

```csharp
using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using TaskFlow.Application.Common.Interfaces;

namespace TaskFlow.Infrastructure.Identity;

public class CurrentUserService : ICurrentUserService
{
	private readonly IHttpContextAccessor _http;
	public CurrentUserService(IHttpContextAccessor http) { _http = http; }

	public Guid? UserId
	{
		get
		{
			var id = _http.HttpContext?.User.FindFirstValue(ClaimTypes.NameIdentifier)
				  ?? _http.HttpContext?.User.FindFirstValue("sub");
			return Guid.TryParse(id, out var g) ? g : null;
		}
	}

	public string? Email => _http.HttpContext?.User.FindFirstValue(ClaimTypes.Email);
	public bool IsAuthenticated => _http.HttpContext?.User.Identity?.IsAuthenticated ?? false;
}
```

## 5. OTP, Email, Storage, FCM

### `Services/OtpService.cs`

```csharp
using System.Security.Cryptography;
using System.Text;
using Microsoft.EntityFrameworkCore;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Domain.Entities;
using TaskFlow.Infrastructure.Persistence;

namespace TaskFlow.Infrastructure.Services;

public class OtpService : IOtpService
{
	private readonly TaskFlowDbContext _db;
	public OtpService(TaskFlowDbContext db) { _db = db; }

	public async Task<string> CreateAsync(string email, string purpose, CancellationToken ct = default)
	{
		var code = RandomNumberGenerator.GetInt32(100000, 999999).ToString();
		_db.OtpCodes.Add(new OtpCode
		{
			Email = email.ToLowerInvariant(), CodeHash = Hash(code),
			Purpose = purpose, ExpiresAt = DateTime.UtcNow.AddMinutes(10)
		});
		await _db.SaveChangesAsync(ct);
		return code;
	}

	public async Task<bool> VerifyAsync(string email, string code, string purpose, CancellationToken ct = default)
	{
		var hash = Hash(code);
		var otp = await _db.OtpCodes
			.Where(o => o.Email == email.ToLowerInvariant() && o.Purpose == purpose && !o.IsUsed)
			.OrderByDescending(o => o.CreatedAt).FirstOrDefaultAsync(ct);

		if (otp is null || otp.ExpiresAt < DateTime.UtcNow || otp.Attempts >= 5) return false;
		if (otp.CodeHash != hash) { otp.Attempts++; await _db.SaveChangesAsync(ct); return false; }

		otp.IsUsed = true;
		await _db.SaveChangesAsync(ct);
		return true;
	}

	private static string Hash(string code)
	{
		using var sha = SHA256.Create();
		return Convert.ToHexString(sha.ComputeHash(Encoding.UTF8.GetBytes(code)));
	}
}
```

### `Services/EmailService.cs`

```csharp
using System.Net;
using System.Net.Mail;
using Microsoft.Extensions.Configuration;
using TaskFlow.Application.Common.Interfaces;

namespace TaskFlow.Infrastructure.Services;

public class EmailService : IEmailService
{
	private readonly IConfiguration _cfg;
	public EmailService(IConfiguration cfg) { _cfg = cfg; }

	public async Task SendAsync(string to, string subject, string htmlBody, CancellationToken ct = default)
	{
		var host = _cfg["Smtp:Host"]!; var port = int.Parse(_cfg["Smtp:Port"] ?? "587");
		var user = _cfg["Smtp:User"]!; var pass = _cfg["Smtp:Password"]!;
		var from = _cfg["Smtp:From"] ?? user;

		using var client = new SmtpClient(host, port)
		{ Credentials = new NetworkCredential(user, pass), EnableSsl = true };

		using var msg = new MailMessage(from, to, subject, htmlBody) { IsBodyHtml = true };
		await client.SendMailAsync(msg, ct);
	}
}
```

### `Services/FileStorageService.cs` (Supabase Storage REST)

```csharp
using System.Net.Http.Headers;
using Microsoft.Extensions.Configuration;
using TaskFlow.Application.Common.Interfaces;

namespace TaskFlow.Infrastructure.Services;

public class FileStorageService : IFileStorageService
{
	private readonly HttpClient _http;
	private readonly string _bucket;
	private readonly string _baseUrl;
	private readonly string _apiKey;

	public FileStorageService(HttpClient http, IConfiguration cfg)
	{
		_http = http;
		_bucket = cfg["Storage:Bucket"]!;
		_baseUrl = cfg["Storage:Endpoint"]!.TrimEnd('/');
		_apiKey = cfg["Storage:ApiKey"]!;
	}

	public async Task<(string Url, string FileName, string MimeType, long Size)> UploadAsync(
		Stream stream, string fileName, string contentType, CancellationToken ct = default)
	{
		var safeName = $"{Guid.NewGuid()}_{Path.GetFileName(fileName)}";
		var uploadUrl = $"{_baseUrl}/object/{_bucket}/{safeName}";

		using var content = new StreamContent(stream);
		content.Headers.ContentType = new MediaTypeHeaderValue(contentType);

		using var req = new HttpRequestMessage(HttpMethod.Post, uploadUrl) { Content = content };
		req.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _apiKey);

		var resp = await _http.SendAsync(req, ct);
		resp.EnsureSuccessStatusCode();

		var publicUrl = $"{_baseUrl}/object/public/{_bucket}/{safeName}";
		return (publicUrl, safeName, contentType, stream.Length);
	}

	public async Task DeleteAsync(string url, CancellationToken ct = default)
	{
		var key = url.Split($"/{_bucket}/").Last();
		using var req = new HttpRequestMessage(HttpMethod.Delete, $"{_baseUrl}/object/{_bucket}/{key}");
		req.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _apiKey);
		(await _http.SendAsync(req, ct)).EnsureSuccessStatusCode();
	}
}
```

### `Services/FcmPushNotificationService.cs`

```csharp
using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Infrastructure.Persistence;

namespace TaskFlow.Infrastructure.Services;

public class FcmPushNotificationService : IPushNotificationService
{
	private readonly TaskFlowDbContext _db;
	private static readonly object _gate = new();

	public FcmPushNotificationService(TaskFlowDbContext db, IConfiguration cfg)
	{
		_db = db;
		lock (_gate)
		{
			if (FirebaseApp.DefaultInstance is null)
				FirebaseApp.Create(new AppOptions
				{ Credential = GoogleCredential.FromFile(cfg["Fcm:ServiceAccountJsonPath"]!) });
		}
	}

	public async Task SendToUserAsync(Guid userId, string title, string body,
		IDictionary<string, string>? data = null, CancellationToken ct = default)
	{
		var tokens = await _db.PushTokens.Where(t => t.UserId == userId)
										  .Select(t => t.Token).ToListAsync(ct);
		if (tokens.Count == 0) return;

		var message = new MulticastMessage
		{
			Tokens = tokens,
			Notification = new FirebaseAdmin.Messaging.Notification { Title = title, Body = body },
			Data = data?.ToDictionary(x => x.Key, x => x.Value)
		};
		await FirebaseMessaging.DefaultInstance.SendEachForMulticastAsync(message, ct);
	}
}
```

## 6. AutoMapper Profile

```csharp
using AutoMapper;
using TaskFlow.Application.DTOs.Auth;
using TaskFlow.Application.DTOs.Comments;
using TaskFlow.Application.DTOs.Notifications;
using TaskFlow.Application.DTOs.Projects;
using TaskFlow.Application.DTOs.Tags;
using TaskFlow.Application.DTOs.Tasks;
using TaskFlow.Application.DTOs.Users;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Application.Common.Mappings;

public class MappingProfile : Profile
{
	public MappingProfile()
	{
		CreateMap<User, UserResponse>()
			.ForCtorParam("Email", o => o.MapFrom(s => s.Email ?? ""))
			.ForCtorParam("Role", o => o.MapFrom(s => s.Role.ToString()));
		CreateMap<User, UserSummary>()
			.ForCtorParam("Email", o => o.MapFrom(s => s.Email ?? ""));

		CreateMap<Project, ProjectSummary>()
			.ForCtorParam("Status", o => o.MapFrom(s => s.Status.ToString()))
			.ForCtorParam("CompletionPercentage", o => o.MapFrom(s =>
				s.Tasks.Count == 0 ? 0d :
				s.Tasks.Count(t => t.Status == Domain.Enums.TaskStatus.Done) * 100d / s.Tasks.Count))
			.ForCtorParam("MemberCount", o => o.MapFrom(s => s.Members.Count))
			.ForCtorParam("TaskCount", o => o.MapFrom(s => s.Tasks.Count));

		CreateMap<Project, ProjectResponse>()
			.ForCtorParam("Status", o => o.MapFrom(s => s.Status.ToString()))
			.ForCtorParam("Priority", o => o.MapFrom(s => s.Priority.ToString()))
			.ForCtorParam("CompletionPercentage", o => o.MapFrom(s =>
				s.Tasks.Count == 0 ? 0d :
				s.Tasks.Count(t => t.Status == Domain.Enums.TaskStatus.Done) * 100d / s.Tasks.Count))
			.ForCtorParam("Members", o => o.MapFrom(s => s.Members));

		CreateMap<ProjectMember, ProjectMemberResponse>()
			.ForCtorParam("FullName", o => o.MapFrom(s => s.User.FullName))
			.ForCtorParam("AvatarUrl", o => o.MapFrom(s => s.User.AvatarUrl))
			.ForCtorParam("Role", o => o.MapFrom(s => s.Role.ToString()));

		CreateMap<TaskItem, TaskResponse>()
			.ForCtorParam("Status", o => o.MapFrom(s => s.Status.ToString()))
			.ForCtorParam("Priority", o => o.MapFrom(s => s.Priority.ToString()))
			.ForCtorParam("Assignee", o => o.MapFrom(s => s.Assignee == null ? null :
				new AssigneeBrief(s.Assignee.Id, s.Assignee.FullName, s.Assignee.AvatarUrl)));

		CreateMap<TaskItem, TaskSummary>()
			.ForCtorParam("Status", o => o.MapFrom(s => s.Status.ToString()))
			.ForCtorParam("Priority", o => o.MapFrom(s => s.Priority.ToString()))
			.ForCtorParam("AssigneeName", o => o.MapFrom(s => s.Assignee != null ? s.Assignee.FullName : null))
			.ForCtorParam("ProjectName", o => o.MapFrom(s => s.Project.Name));

		CreateMap<Subtask, SubtaskResponse>();
		CreateMap<Tag, TagResponse>();
		CreateMap<Tag, TagBrief>();

		CreateMap<Comment, CommentResponse>()
			.ForCtorParam("AuthorName", o => o.MapFrom(s => s.Author.FullName))
			.ForCtorParam("AuthorAvatar", o => o.MapFrom(s => s.Author.AvatarUrl));

		CreateMap<Notification, NotificationResponse>()
			.ForCtorParam("Type", o => o.MapFrom(s => s.Type.ToString()));
	}
}
```

## 7. FluentValidation — Request Validators

### `Validators/Auth/*.cs`

```csharp
using FluentValidation;
using TaskFlow.Application.DTOs.Auth;

namespace TaskFlow.Application.Validators.Auth;

public class RegisterRequestValidator : AbstractValidator<RegisterRequest>
{
	public RegisterRequestValidator()
	{
		RuleFor(x => x.FullName).NotEmpty().MaximumLength(150);
		RuleFor(x => x.Email).NotEmpty().EmailAddress();
		RuleFor(x => x.Password).NotEmpty().MinimumLength(8)
			.Matches("[A-Z]").WithMessage("Must contain an uppercase letter.")
			.Matches("[0-9]").WithMessage("Must contain a digit.");
	}
}

public class LoginRequestValidator : AbstractValidator<LoginRequest>
{
	public LoginRequestValidator()
	{
		RuleFor(x => x.Email).NotEmpty().EmailAddress();
		RuleFor(x => x.Password).NotEmpty();
	}
}

public class RefreshRequestValidator : AbstractValidator<RefreshRequest>
{ public RefreshRequestValidator() => RuleFor(x => x.RefreshToken).NotEmpty(); }

public class ForgotPasswordRequestValidator : AbstractValidator<ForgotPasswordRequest>
{ public ForgotPasswordRequestValidator() => RuleFor(x => x.Email).NotEmpty().EmailAddress(); }

public class VerifyOtpRequestValidator : AbstractValidator<VerifyOtpRequest>
{
	public VerifyOtpRequestValidator()
	{
		RuleFor(x => x.Email).NotEmpty().EmailAddress();
		RuleFor(x => x.Code).NotEmpty().Length(4, 6).Matches("^[0-9]+$");
	}
}

public class ResetPasswordRequestValidator : AbstractValidator<ResetPasswordRequest>
{
	public ResetPasswordRequestValidator()
	{
		RuleFor(x => x.Email).NotEmpty().EmailAddress();
		RuleFor(x => x.ResetToken).NotEmpty();
		RuleFor(x => x.NewPassword).NotEmpty().MinimumLength(8).Matches("[A-Z]").Matches("[0-9]");
	}
}
```

### `Validators/*.cs` — Projects, Tasks, Comments, Tags

```csharp
using FluentValidation;
using TaskFlow.Application.DTOs.Comments;
using TaskFlow.Application.DTOs.Projects;
using TaskFlow.Application.DTOs.Tags;
using TaskFlow.Application.DTOs.Tasks;

namespace TaskFlow.Application.Validators;

public class CreateProjectRequestValidator : AbstractValidator<CreateProjectRequest>
{
	public CreateProjectRequestValidator()
	{
		RuleFor(x => x.Name).NotEmpty().MaximumLength(100);
		RuleFor(x => x.Description).MaximumLength(2000);
		RuleFor(x => x.ColorLabel).Matches("^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$");
		RuleFor(x => x.Priority).Must(p => Enum.TryParse<Domain.Enums.TaskPriority>(p, true, out _));
		RuleFor(x => x).Must(x => !x.StartDate.HasValue || !x.DueDate.HasValue || x.DueDate >= x.StartDate)
			.WithMessage("DueDate must be after StartDate.");
	}
}

public class UpdateProjectRequestValidator : AbstractValidator<UpdateProjectRequest>
{
	public UpdateProjectRequestValidator()
	{
		RuleFor(x => x.Name).NotEmpty().MaximumLength(100);
		RuleFor(x => x.ColorLabel).Matches("^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$");
		RuleFor(x => x.Status).Must(s => Enum.TryParse<Domain.Enums.ProjectStatus>(s, true, out _));
		RuleFor(x => x.Priority).Must(p => Enum.TryParse<Domain.Enums.TaskPriority>(p, true, out _));
	}
}

public class InviteMemberRequestValidator : AbstractValidator<InviteMemberRequest>
{
	public InviteMemberRequestValidator()
	{
		RuleFor(x => x.UserId).NotEmpty();
		RuleFor(x => x.Role).Must(r => Enum.TryParse<Domain.Enums.ProjectMemberRole>(r, true, out _));
	}
}

public class CreateTaskRequestValidator : AbstractValidator<CreateTaskRequest>
{
	public CreateTaskRequestValidator()
	{
		RuleFor(x => x.Title).NotEmpty().MaximumLength(200);
		RuleFor(x => x.ProjectId).NotEmpty();
		RuleFor(x => x.Status).Must(s => Enum.TryParse<Domain.Enums.TaskStatus>(s, true, out _));
		RuleFor(x => x.Priority).Must(p => Enum.TryParse<Domain.Enums.TaskPriority>(p, true, out _));
		RuleFor(x => x.EstimatedHours).GreaterThan(0).When(x => x.EstimatedHours.HasValue);
	}
}

public class UpdateTaskRequestValidator : AbstractValidator<UpdateTaskRequest>
{
	public UpdateTaskRequestValidator()
	{
		RuleFor(x => x.Title).NotEmpty().MaximumLength(200);
		RuleFor(x => x.Status).Must(s => Enum.TryParse<Domain.Enums.TaskStatus>(s, true, out _));
		RuleFor(x => x.Priority).Must(p => Enum.TryParse<Domain.Enums.TaskPriority>(p, true, out _));
	}
}

public class ReorderTaskRequestValidator : AbstractValidator<ReorderTaskRequest>
{
	public ReorderTaskRequestValidator()
	{
		RuleFor(x => x.NewStatus).Must(s => Enum.TryParse<Domain.Enums.TaskStatus>(s, true, out _));
		RuleFor(x => x.NewPosition).GreaterThanOrEqualTo(0);
	}
}

public class CreateCommentRequestValidator : AbstractValidator<CreateCommentRequest>
{ public CreateCommentRequestValidator() => RuleFor(x => x.Content).NotEmpty().MaximumLength(4000); }

public class CreateTagRequestValidator : AbstractValidator<CreateTagRequest>
{
	public CreateTagRequestValidator()
	{
		RuleFor(x => x.Name).NotEmpty().MaximumLength(50);
		RuleFor(x => x.Color).Matches("^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$");
	}
}
```

## 8. Use Cases (Application Services)

### `UseCases/Auth/AuthService.cs`

```csharp
using AutoMapper;
using Microsoft.AspNetCore.Identity;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Application.DTOs.Auth;
using TaskFlow.Domain.Entities;
using TaskFlow.Domain.Exceptions;

namespace TaskFlow.Application.UseCases.Auth;

public interface IAuthService
{
	Task<AuthResponse> RegisterAsync(RegisterRequest req, CancellationToken ct);
	Task<AuthResponse> LoginAsync(LoginRequest req, string? ip, CancellationToken ct);
	Task<AuthResponse> RefreshAsync(RefreshRequest req, string? ip, CancellationToken ct);
	Task LogoutAsync(RefreshRequest req, CancellationToken ct);
	Task ForgotPasswordAsync(ForgotPasswordRequest req, CancellationToken ct);
	Task<OtpVerifiedResponse> VerifyOtpAsync(VerifyOtpRequest req, CancellationToken ct);
	Task ResetPasswordAsync(ResetPasswordRequest req, CancellationToken ct);
}

public class AuthService : IAuthService
{
	private readonly UserManager<User> _users;
	private readonly SignInManager<User> _signIn;
	private readonly IUnitOfWork _uow;
	private readonly IJwtTokenService _jwt;
	private readonly IOtpService _otp;
	private readonly IEmailService _email;
	private readonly IMapper _mapper;

	public AuthService(UserManager<User> users, SignInManager<User> signIn, IUnitOfWork uow,
		IJwtTokenService jwt, IOtpService otp, IEmailService email, IMapper mapper)
	{ _users = users; _signIn = signIn; _uow = uow; _jwt = jwt; _otp = otp; _email = email; _mapper = mapper; }

	public async Task<AuthResponse> RegisterAsync(RegisterRequest req, CancellationToken ct)
	{
		if (await _users.FindByEmailAsync(req.Email) is not null)
			throw new ConflictException("Email is already registered.");

		var user = new User
		{
			UserName = req.Email, Email = req.Email,
			FullName = req.FullName, AvatarUrl = req.AvatarUrl,
			EmailConfirmed = true
		};
		var res = await _users.CreateAsync(user, req.Password);
		if (!res.Succeeded) throw new DomainException(string.Join("; ", res.Errors.Select(e => e.Description)));

		return await IssueTokensAsync(user, null, ct);
	}

	public async Task<AuthResponse> LoginAsync(LoginRequest req, string? ip, CancellationToken ct)
	{
		var user = await _users.FindByEmailAsync(req.Email)
			?? throw new ForbiddenException("Invalid credentials.");
		var ok = await _signIn.CheckPasswordSignInAsync(user, req.Password, true);
		if (!ok.Succeeded) throw new ForbiddenException("Invalid credentials.");

		user.LastLoginAt = DateTime.UtcNow;
		await _users.UpdateAsync(user);
		return await IssueTokensAsync(user, ip, ct);
	}

	public async Task<AuthResponse> RefreshAsync(RefreshRequest req, string? ip, CancellationToken ct)
	{
		var hash = _jwt.HashToken(req.RefreshToken);
		var token = (await _uow.RefreshTokens.FindAsync(t => t.TokenHash == hash, ct)).FirstOrDefault()
			?? throw new ForbiddenException("Invalid refresh token.");
		if (!token.IsActive) throw new ForbiddenException("Refresh token is no longer active.");

		var user = await _users.FindByIdAsync(token.UserId.ToString())
			?? throw new NotFoundException(nameof(User), token.UserId);

		token.RevokedAt = DateTime.UtcNow;
		var fresh = await IssueTokensAsync(user, ip, ct);
		token.ReplacedByTokenHash = _jwt.HashToken(fresh.RefreshToken);
		_uow.RefreshTokens.Update(token);
		await _uow.SaveChangesAsync(ct);
		return fresh;
	}

	public async Task LogoutAsync(RefreshRequest req, CancellationToken ct)
	{
		var hash = _jwt.HashToken(req.RefreshToken);
		var token = (await _uow.RefreshTokens.FindAsync(t => t.TokenHash == hash, ct)).FirstOrDefault();
		if (token is null || !token.IsActive) return;
		token.RevokedAt = DateTime.UtcNow;
		_uow.RefreshTokens.Update(token);
		await _uow.SaveChangesAsync(ct);
	}

	public async Task ForgotPasswordAsync(ForgotPasswordRequest req, CancellationToken ct)
	{
		var user = await _users.FindByEmailAsync(req.Email);
		if (user is null) return; // do not leak existence
		var code = await _otp.CreateAsync(req.Email, "password_reset", ct);
		await _email.SendAsync(req.Email, "Task-Flow password reset",
			$"<p>Your verification code is <b>{code}</b>. It expires in 10 minutes.</p>", ct);
	}

	public async Task<OtpVerifiedResponse> VerifyOtpAsync(VerifyOtpRequest req, CancellationToken ct)
	{
		var ok = await _otp.VerifyAsync(req.Email, req.Code, "password_reset", ct);
		if (!ok) throw new ForbiddenException("Invalid or expired OTP.");

		var user = await _users.FindByEmailAsync(req.Email)
			?? throw new NotFoundException(nameof(User), req.Email);
		var resetToken = await _users.GeneratePasswordResetTokenAsync(user);
		return new OtpVerifiedResponse(resetToken);
	}

	public async Task ResetPasswordAsync(ResetPasswordRequest req, CancellationToken ct)
	{
		var user = await _users.FindByEmailAsync(req.Email)
			?? throw new NotFoundException(nameof(User), req.Email);
		var res = await _users.ResetPasswordAsync(user, req.ResetToken, req.NewPassword);
		if (!res.Succeeded) throw new DomainException(string.Join("; ", res.Errors.Select(e => e.Description)));
	}

	private async Task<AuthResponse> IssueTokensAsync(User user, string? ip, CancellationToken ct)
	{
		var roles = await _users.GetRolesAsync(user);
		var (access, accessExp) = _jwt.GenerateAccessToken(user, roles);
		var (raw, hash, refreshExp) = _jwt.GenerateRefreshToken();

		await _uow.RefreshTokens.AddAsync(new RefreshToken
		{ UserId = user.Id, TokenHash = hash, ExpiresAt = refreshExp, CreatedByIp = ip }, ct);
		await _uow.SaveChangesAsync(ct);

		return new AuthResponse(access, raw, accessExp, refreshExp, _mapper.Map<UserResponse>(user));
	}
}
```

### `UseCases/Projects/ProjectService.cs`

```csharp
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Application.DTOs.Projects;
using TaskFlow.Domain.Entities;
using TaskFlow.Domain.Enums;
using TaskFlow.Domain.Exceptions;
using TaskFlow.Shared.Wrappers;

namespace TaskFlow.Application.UseCases.Projects;

public interface IProjectService
{
	Task<PagedResult<ProjectSummary>> ListAsync(int page, int pageSize, CancellationToken ct);
	Task<ProjectResponse> CreateAsync(CreateProjectRequest req, CancellationToken ct);
	Task<ProjectResponse> GetAsync(Guid id, CancellationToken ct);
	Task<ProjectResponse> UpdateAsync(Guid id, UpdateProjectRequest req, CancellationToken ct);
	Task DeleteAsync(Guid id, CancellationToken ct);
	Task<ProjectStatsResponse> GetStatsAsync(Guid id, CancellationToken ct);
	Task<ProjectMemberResponse> InviteMemberAsync(Guid id, InviteMemberRequest req, CancellationToken ct);
	Task<ProjectMemberResponse> ChangeMemberRoleAsync(Guid id, Guid userId, ChangeMemberRoleRequest req, CancellationToken ct);
	Task RemoveMemberAsync(Guid id, Guid userId, CancellationToken ct);
}

public class ProjectService : IProjectService
{
	private readonly IUnitOfWork _uow;
	private readonly ICurrentUserService _current;
	private readonly IMapper _mapper;

	public ProjectService(IUnitOfWork uow, ICurrentUserService current, IMapper mapper)
	{ _uow = uow; _current = current; _mapper = mapper; }

	private Guid Me => _current.UserId ?? throw new UnauthorizedAccessException();

	public async Task<PagedResult<ProjectSummary>> ListAsync(int page, int pageSize, CancellationToken ct)
	{
		var items = await _uow.Projects.GetForUserAsync(Me, page, pageSize, ct);
		var total = await _uow.Projects.CountForUserAsync(Me, ct);
		return new PagedResult<ProjectSummary>
		{
			Items = _mapper.Map<List<ProjectSummary>>(items),
			Page = page, PageSize = pageSize, TotalCount = total
		};
	}

	public async Task<ProjectResponse> CreateAsync(CreateProjectRequest req, CancellationToken ct)
	{
		var p = new Project
		{
			Name = req.Name, Description = req.Description, ColorLabel = req.ColorLabel,
			Priority = Enum.Parse<TaskPriority>(req.Priority, true),
			StartDate = req.StartDate, DueDate = req.DueDate, OwnerId = Me
		};
		p.Members.Add(new ProjectMember { UserId = Me, Role = ProjectMemberRole.Owner });
		foreach (var uid in req.MemberIds ?? new())
			if (uid != Me) p.Members.Add(new ProjectMember { UserId = uid, Role = ProjectMemberRole.Editor });

		await _uow.Projects.AddAsync(p, ct);
		await _uow.SaveChangesAsync(ct);
		return _mapper.Map<ProjectResponse>(await _uow.Projects.GetWithMembersAsync(p.Id, ct));
	}

	public async Task<ProjectResponse> GetAsync(Guid id, CancellationToken ct)
	{
		await EnsureMemberAsync(id, ct);
		var p = await _uow.Projects.GetWithMembersAsync(id, ct)
			?? throw new NotFoundException(nameof(Project), id);
		return _mapper.Map<ProjectResponse>(p);
	}

	public async Task<ProjectResponse> UpdateAsync(Guid id, UpdateProjectRequest req, CancellationToken ct)
	{
		var p = await _uow.Projects.GetByIdAsync(id, ct) ?? throw new NotFoundException(nameof(Project), id);
		if (p.OwnerId != Me) throw new ForbiddenException();

		p.Name = req.Name; p.Description = req.Description; p.ColorLabel = req.ColorLabel;
		p.Status = Enum.Parse<ProjectStatus>(req.Status, true);
		p.Priority = Enum.Parse<TaskPriority>(req.Priority, true);
		p.StartDate = req.StartDate; p.DueDate = req.DueDate;

		_uow.Projects.Update(p);
		await _uow.SaveChangesAsync(ct);
		return _mapper.Map<ProjectResponse>(await _uow.Projects.GetWithMembersAsync(p.Id, ct));
	}

	public async Task DeleteAsync(Guid id, CancellationToken ct)
	{
		var p = await _uow.Projects.GetByIdAsync(id, ct) ?? throw new NotFoundException(nameof(Project), id);
		if (p.OwnerId != Me) throw new ForbiddenException();
		_uow.Projects.Delete(p);
		await _uow.SaveChangesAsync(ct);
	}

	public async Task<ProjectStatsResponse> GetStatsAsync(Guid id, CancellationToken ct)
	{
		await EnsureMemberAsync(id, ct);
		var groups = await _uow.Tasks.Query()
			.Where(t => t.ProjectId == id)
			.GroupBy(t => t.Status)
			.Select(g => new { g.Key, Count = g.Count() })
			.ToListAsync(ct);

		int Get(Domain.Enums.TaskStatus s) => groups.FirstOrDefault(g => g.Key == s)?.Count ?? 0;
		var total = groups.Sum(g => g.Count);
		var done = Get(Domain.Enums.TaskStatus.Done);
		return new ProjectStatsResponse(total,
			Get(Domain.Enums.TaskStatus.Todo), Get(Domain.Enums.TaskStatus.InProgress),
			Get(Domain.Enums.TaskStatus.Review), done,
			total == 0 ? 0 : (double)done * 100 / total);
	}

	public async Task<ProjectMemberResponse> InviteMemberAsync(Guid id, InviteMemberRequest req, CancellationToken ct)
	{
		var p = await _uow.Projects.GetByIdAsync(id, ct) ?? throw new NotFoundException(nameof(Project), id);
		if (p.OwnerId != Me) throw new ForbiddenException();
		if (await _uow.ProjectMembers.ExistsAsync(m => m.ProjectId == id && m.UserId == req.UserId, ct))
			throw new ConflictException("User is already a member.");

		var member = new ProjectMember
		{ ProjectId = id, UserId = req.UserId, Role = Enum.Parse<ProjectMemberRole>(req.Role, true) };
		await _uow.ProjectMembers.AddAsync(member, ct);
		await _uow.SaveChangesAsync(ct);

		var user = await _uow.Users.GetByIdAsync(req.UserId, ct)
			?? throw new NotFoundException(nameof(User), req.UserId);
		return new ProjectMemberResponse(user.Id, user.FullName, user.AvatarUrl, member.Role.ToString());
	}

	public async Task<ProjectMemberResponse> ChangeMemberRoleAsync(Guid id, Guid userId, ChangeMemberRoleRequest req, CancellationToken ct)
	{
		var p = await _uow.Projects.GetByIdAsync(id, ct) ?? throw new NotFoundException(nameof(Project), id);
		if (p.OwnerId != Me) throw new ForbiddenException();

		var m = (await _uow.ProjectMembers.FindAsync(x => x.ProjectId == id && x.UserId == userId, ct)).FirstOrDefault()
			?? throw new NotFoundException(nameof(ProjectMember), userId);
		m.Role = Enum.Parse<ProjectMemberRole>(req.Role, true);
		_uow.ProjectMembers.Update(m);
		await _uow.SaveChangesAsync(ct);

		var user = await _uow.Users.GetByIdAsync(userId, ct)!;
		return new ProjectMemberResponse(userId, user!.FullName, user.AvatarUrl, m.Role.ToString());
	}

	public async Task RemoveMemberAsync(Guid id, Guid userId, CancellationToken ct)
	{
		var p = await _uow.Projects.GetByIdAsync(id, ct) ?? throw new NotFoundException(nameof(Project), id);
		if (p.OwnerId != Me) throw new ForbiddenException();
		if (p.OwnerId == userId) throw new DomainException("Cannot remove project owner.");

		var m = (await _uow.ProjectMembers.FindAsync(x => x.ProjectId == id && x.UserId == userId, ct)).FirstOrDefault()
			?? throw new NotFoundException(nameof(ProjectMember), userId);
		_uow.ProjectMembers.Delete(m);
		await _uow.SaveChangesAsync(ct);
	}

	private async Task EnsureMemberAsync(Guid projectId, CancellationToken ct)
	{
		if (!await _uow.Projects.IsMemberAsync(projectId, Me, ct)) throw new ForbiddenException();
	}
}
```

### `UseCases/Tasks/TaskService.cs`

```csharp
using AutoMapper;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Application.DTOs.Tasks;
using TaskFlow.Domain.Entities;
using TaskFlow.Domain.Enums;
using TaskFlow.Domain.Exceptions;
using DomainTaskStatus = TaskFlow.Domain.Enums.TaskStatus;

namespace TaskFlow.Application.UseCases.Tasks;

public interface ITaskService
{
	Task<TaskDetailResponse> CreateAsync(CreateTaskRequest req, CancellationToken ct);
	Task<TaskDetailResponse> GetAsync(Guid id, CancellationToken ct);
	Task<TaskResponse> UpdateAsync(Guid id, UpdateTaskRequest req, CancellationToken ct);
	Task UpdateStatusAsync(Guid id, UpdateStatusRequest req, CancellationToken ct);
	Task ReorderAsync(Guid id, ReorderTaskRequest req, CancellationToken ct);
	Task DeleteAsync(Guid id, CancellationToken ct);
	Task<IReadOnlyList<TaskSummary>> ListByProjectAsync(Guid projectId, CancellationToken ct);
	Task<SubtaskResponse> AddSubtaskAsync(Guid taskId, CreateSubtaskRequest req, CancellationToken ct);
	Task<SubtaskResponse> UpdateSubtaskAsync(Guid taskId, Guid sid, UpdateSubtaskRequest req, CancellationToken ct);
	Task DeleteSubtaskAsync(Guid taskId, Guid sid, CancellationToken ct);
}

public class TaskService : ITaskService
{
	private readonly IUnitOfWork _uow;
	private readonly ICurrentUserService _current;
	private readonly IMapper _mapper;
	private readonly IPushNotificationService _push;

	public TaskService(IUnitOfWork uow, ICurrentUserService current, IMapper mapper, IPushNotificationService push)
	{ _uow = uow; _current = current; _mapper = mapper; _push = push; }

	private Guid Me => _current.UserId ?? throw new UnauthorizedAccessException();

	public async Task<TaskDetailResponse> CreateAsync(CreateTaskRequest req, CancellationToken ct)
	{
		if (!await _uow.Projects.IsMemberAsync(req.ProjectId, Me, ct)) throw new ForbiddenException();

		var status = Enum.Parse<DomainTaskStatus>(req.Status, true);
		var nextPos = await _uow.Tasks.GetMaxPositionAsync(req.ProjectId, status, ct) + 1;

		var task = new TaskItem
		{
			Title = req.Title, Description = req.Description,
			ProjectId = req.ProjectId, AssigneeId = req.AssigneeId,
			Status = status, Priority = Enum.Parse<TaskPriority>(req.Priority, true),
			DueDate = req.DueDate, EstimatedHours = req.EstimatedHours,
			CreatedById = Me, Position = nextPos
		};
		foreach (var s in req.Subtasks ?? new())
			task.Subtasks.Add(new Subtask { Title = s.Title, Position = s.Position });
		foreach (var tagId in req.TagIds ?? new())
			task.TaskTags.Add(new TaskTag { TagId = tagId });

		await _uow.Tasks.AddAsync(task, ct);
		await _uow.SaveChangesAsync(ct);

		if (task.AssigneeId.HasValue && task.AssigneeId != Me)
			await NotifyAsync(task.AssigneeId.Value, NotificationType.TaskAssigned,
				"Task assigned", $"You were assigned: {task.Title}", "task", task.Id, ct);

		return await BuildDetailAsync(task.Id, ct);
	}

	public Task<TaskDetailResponse> GetAsync(Guid id, CancellationToken ct) => BuildDetailAsync(id, ct);

	public async Task<TaskResponse> UpdateAsync(Guid id, UpdateTaskRequest req, CancellationToken ct)
	{
		var t = await _uow.Tasks.GetByIdAsync(id, ct) ?? throw new NotFoundException(nameof(TaskItem), id);
		if (!await _uow.Projects.IsMemberAsync(t.ProjectId, Me, ct)) throw new ForbiddenException();

		t.Title = req.Title; t.Description = req.Description; t.AssigneeId = req.AssigneeId;
		t.Status = Enum.Parse<DomainTaskStatus>(req.Status, true);
		t.Priority = Enum.Parse<TaskPriority>(req.Priority, true);
		t.DueDate = req.DueDate; t.EstimatedHours = req.EstimatedHours;
		if (t.Status == DomainTaskStatus.Done && t.CompletedAt is null) t.CompletedAt = DateTime.UtcNow;

		_uow.Tasks.Update(t);
		await _uow.SaveChangesAsync(ct);
		return _mapper.Map<TaskResponse>(t);
	}

	public async Task UpdateStatusAsync(Guid id, UpdateStatusRequest req, CancellationToken ct)
	{
		var t = await _uow.Tasks.GetByIdAsync(id, ct) ?? throw new NotFoundException(nameof(TaskItem), id);
		if (!await _uow.Projects.IsMemberAsync(t.ProjectId, Me, ct)) throw new ForbiddenException();
		t.Status = Enum.Parse<DomainTaskStatus>(req.Status, true);
		if (t.Status == DomainTaskStatus.Done && t.CompletedAt is null) t.CompletedAt = DateTime.UtcNow;
		await _uow.SaveChangesAsync(ct);
	}

	public async Task ReorderAsync(Guid id, ReorderTaskRequest req, CancellationToken ct)
	{
		var t = await _uow.Tasks.GetByIdAsync(id, ct) ?? throw new NotFoundException(nameof(TaskItem), id);
		if (!await _uow.Projects.IsMemberAsync(t.ProjectId, Me, ct)) throw new ForbiddenException();

		t.Status = Enum.Parse<DomainTaskStatus>(req.NewStatus, true);
		t.Position = req.NewPosition;
		await _uow.SaveChangesAsync(ct);
	}

	public async Task DeleteAsync(Guid id, CancellationToken ct)
	{
		var t = await _uow.Tasks.GetByIdAsync(id, ct) ?? throw new NotFoundException(nameof(TaskItem), id);
		if (!await _uow.Projects.IsMemberAsync(t.ProjectId, Me, ct)) throw new ForbiddenException();
		_uow.Tasks.Delete(t);
		await _uow.SaveChangesAsync(ct);
	}

	public async Task<IReadOnlyList<TaskSummary>> ListByProjectAsync(Guid projectId, CancellationToken ct)
	{
		if (!await _uow.Projects.IsMemberAsync(projectId, Me, ct)) throw new ForbiddenException();
		var items = await _uow.Tasks.GetByProjectAsync(projectId, ct);
		return _mapper.Map<List<TaskSummary>>(items);
	}

	public async Task<SubtaskResponse> AddSubtaskAsync(Guid taskId, CreateSubtaskRequest req, CancellationToken ct)
	{
		var t = await _uow.Tasks.GetByIdAsync(taskId, ct) ?? throw new NotFoundException(nameof(TaskItem), taskId);
		if (!await _uow.Projects.IsMemberAsync(t.ProjectId, Me, ct)) throw new ForbiddenException();

		var s = new Subtask { TaskId = taskId, Title = req.Title, Position = req.Position };
		await _uow.Subtasks.AddAsync(s, ct);
		await _uow.SaveChangesAsync(ct);
		return _mapper.Map<SubtaskResponse>(s);
	}

	public async Task<SubtaskResponse> UpdateSubtaskAsync(Guid taskId, Guid sid, UpdateSubtaskRequest req, CancellationToken ct)
	{
		var s = await _uow.Subtasks.GetByIdAsync(sid, ct) ?? throw new NotFoundException(nameof(Subtask), sid);
		if (s.TaskId != taskId) throw new NotFoundException(nameof(Subtask), sid);

		if (req.Title is not null) s.Title = req.Title;
		if (req.IsCompleted.HasValue) s.IsCompleted = req.IsCompleted.Value;
		if (req.Position.HasValue) s.Position = req.Position.Value;

		_uow.Subtasks.Update(s);
		await _uow.SaveChangesAsync(ct);
		return _mapper.Map<SubtaskResponse>(s);
	}

	public async Task DeleteSubtaskAsync(Guid taskId, Guid sid, CancellationToken ct)
	{
		var s = await _uow.Subtasks.GetByIdAsync(sid, ct) ?? throw new NotFoundException(nameof(Subtask), sid);
		if (s.TaskId != taskId) throw new NotFoundException(nameof(Subtask), sid);
		_uow.Subtasks.Delete(s);
		await _uow.SaveChangesAsync(ct);
	}

	private async Task<TaskDetailResponse> BuildDetailAsync(Guid id, CancellationToken ct)
	{
		var t = await _uow.Tasks.GetWithDetailsAsync(id, ct) ?? throw new NotFoundException(nameof(TaskItem), id);
		return new TaskDetailResponse(
			t.Id, t.Title, t.Description, t.Status.ToString(), t.Priority.ToString(),
			t.DueDate, t.EstimatedHours, t.ProjectId,
			t.Assignee == null ? null : new AssigneeBrief(t.Assignee.Id, t.Assignee.FullName, t.Assignee.AvatarUrl),
			new AssigneeBrief(t.CreatedBy.Id, t.CreatedBy.FullName, t.CreatedBy.AvatarUrl),
			t.Subtasks.OrderBy(s => s.Position).Select(s => new SubtaskResponse(s.Id, s.Title, s.IsCompleted, s.Position)).ToList(),
			t.TaskTags.Select(tt => new TagBrief(tt.Tag.Id, tt.Tag.Name, tt.Tag.Color)).ToList(),
			t.Comments.Count, t.Attachments.Count, t.CreatedAt, t.UpdatedAt);
	}

	private async Task NotifyAsync(Guid userId, NotificationType type, string title, string message,
		string relatedType, Guid relatedId, CancellationToken ct)
	{
		await _uow.Notifications.AddAsync(new Notification
		{
			UserId = userId, Type = type, Title = title, Message = message,
			RelatedEntityType = relatedType, RelatedEntityId = relatedId
		}, ct);
		await _uow.SaveChangesAsync(ct);
		await _push.SendToUserAsync(userId, title, message,
			new Dictionary<string, string> { ["entityType"] = relatedType, ["entityId"] = relatedId.ToString() }, ct);
	}
}
```

### `UseCases/CommentService.cs` · `TagService.cs` · `NotificationService.cs` · `UserService.cs`

```csharp
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Application.DTOs.Comments;
using TaskFlow.Application.DTOs.Notifications;
using TaskFlow.Application.DTOs.Tags;
using TaskFlow.Application.DTOs.Users;
using TaskFlow.Domain.Entities;
using TaskFlow.Domain.Exceptions;
using TaskFlow.Shared.Wrappers;

namespace TaskFlow.Application.UseCases;

public interface ICommentService
{
	Task<IReadOnlyList<CommentResponse>> ListAsync(Guid taskId, CancellationToken ct);
	Task<CommentResponse> CreateAsync(Guid taskId, CreateCommentRequest req, CancellationToken ct);
	Task DeleteAsync(Guid taskId, Guid commentId, CancellationToken ct);
}

public class CommentService : ICommentService
{
	private readonly IUnitOfWork _uow;
	private readonly ICurrentUserService _current;
	private readonly IMapper _mapper;
	public CommentService(IUnitOfWork u, ICurrentUserService c, IMapper m) { _uow = u; _current = c; _mapper = m; }

	public async Task<IReadOnlyList<CommentResponse>> ListAsync(Guid taskId, CancellationToken ct)
	{
		var items = await _uow.Comments.Query()
			.Include(c => c.Author)
			.Where(c => c.TaskId == taskId)
			.OrderBy(c => c.CreatedAt).ToListAsync(ct);
		return _mapper.Map<List<CommentResponse>>(items);
	}

	public async Task<CommentResponse> CreateAsync(Guid taskId, CreateCommentRequest req, CancellationToken ct)
	{
		var me = _current.UserId ?? throw new UnauthorizedAccessException();
		var c = new Comment { TaskId = taskId, AuthorId = me, Content = req.Content, ParentId = req.ParentId };
		await _uow.Comments.AddAsync(c, ct);
		await _uow.SaveChangesAsync(ct);
		return _mapper.Map<CommentResponse>(c);
	}

	public async Task DeleteAsync(Guid taskId, Guid commentId, CancellationToken ct)
	{
		var me = _current.UserId ?? throw new UnauthorizedAccessException();
		var c = await _uow.Comments.GetByIdAsync(commentId, ct) ?? throw new NotFoundException(nameof(Comment), commentId);
		if (c.TaskId != taskId || c.AuthorId != me) throw new ForbiddenException();
		_uow.Comments.Delete(c);
		await _uow.SaveChangesAsync(ct);
	}
}

public interface ITagService
{
	Task<IReadOnlyList<TagResponse>> ListAsync(CancellationToken ct);
	Task<TagResponse> CreateAsync(CreateTagRequest req, CancellationToken ct);
	Task DeleteAsync(Guid id, CancellationToken ct);
}

public class TagService : ITagService
{
	private readonly IUnitOfWork _uow; private readonly ICurrentUserService _current; private readonly IMapper _mapper;
	public TagService(IUnitOfWork u, ICurrentUserService c, IMapper m) { _uow = u; _current = c; _mapper = m; }
	private Guid Me => _current.UserId ?? throw new UnauthorizedAccessException();

	public async Task<IReadOnlyList<TagResponse>> ListAsync(CancellationToken ct)
		=> _mapper.Map<List<TagResponse>>(await _uow.Tags.FindAsync(t => t.CreatedById == Me, ct));

	public async Task<TagResponse> CreateAsync(CreateTagRequest req, CancellationToken ct)
	{
		var tag = new Tag { Name = req.Name, Color = req.Color, CreatedById = Me };
		await _uow.Tags.AddAsync(tag, ct);
		await _uow.SaveChangesAsync(ct);
		return _mapper.Map<TagResponse>(tag);
	}

	public async Task DeleteAsync(Guid id, CancellationToken ct)
	{
		var tag = await _uow.Tags.GetByIdAsync(id, ct) ?? throw new NotFoundException(nameof(Tag), id);
		if (tag.CreatedById != Me) throw new ForbiddenException();
		_uow.Tags.Delete(tag);
		await _uow.SaveChangesAsync(ct);
	}
}

public interface INotificationService
{
	Task<PagedResult<NotificationResponse>> ListAsync(int page, int pageSize, CancellationToken ct);
	Task MarkReadAsync(Guid id, CancellationToken ct);
	Task MarkAllReadAsync(CancellationToken ct);
	Task DeleteAsync(Guid id, CancellationToken ct);
	Task RegisterPushTokenAsync(RegisterPushTokenRequest req, CancellationToken ct);
}

public class NotificationService : INotificationService
{
	private readonly IUnitOfWork _uow; private readonly ICurrentUserService _current; private readonly IMapper _mapper;
	public NotificationService(IUnitOfWork u, ICurrentUserService c, IMapper m) { _uow = u; _current = c; _mapper = m; }
	private Guid Me => _current.UserId ?? throw new UnauthorizedAccessException();

	public async Task<PagedResult<NotificationResponse>> ListAsync(int page, int pageSize, CancellationToken ct)
	{
		var q = _uow.Notifications.Query().Where(n => n.UserId == Me).OrderByDescending(n => n.CreatedAt);
		var total = await q.CountAsync(ct);
		var items = await q.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync(ct);
		return new PagedResult<NotificationResponse>
		{
			Items = _mapper.Map<List<NotificationResponse>>(items),
			Page = page, PageSize = pageSize, TotalCount = total
		};
	}

	public async Task MarkReadAsync(Guid id, CancellationToken ct)
	{
		var n = await _uow.Notifications.GetByIdAsync(id, ct) ?? throw new NotFoundException(nameof(Notification), id);
		if (n.UserId != Me) throw new ForbiddenException();
		n.IsRead = true; n.ReadAt = DateTime.UtcNow;
		_uow.Notifications.Update(n);
		await _uow.SaveChangesAsync(ct);
	}

	public Task MarkAllReadAsync(CancellationToken ct) => _uow.Notifications.MarkAllReadAsync(Me, ct);

	public async Task DeleteAsync(Guid id, CancellationToken ct)
	{
		var n = await _uow.Notifications.GetByIdAsync(id, ct) ?? throw new NotFoundException(nameof(Notification), id);
		if (n.UserId != Me) throw new ForbiddenException();
		_uow.Notifications.Delete(n);
		await _uow.SaveChangesAsync(ct);
	}

	public async Task RegisterPushTokenAsync(RegisterPushTokenRequest req, CancellationToken ct)
	{
		var existing = (await _uow.PushTokens.FindAsync(t => t.UserId == Me && t.Token == req.Token, ct)).FirstOrDefault();
		if (existing is not null) return;
		await _uow.PushTokens.AddAsync(new PushToken
		{ UserId = Me, Token = req.Token, Platform = req.Platform, DeviceId = req.DeviceId }, ct);
		await _uow.SaveChangesAsync(ct);
	}
}

public interface IUserService
{
	Task<UserResponse> GetMeAsync(CancellationToken ct);
	Task<UserResponse> UpdateMeAsync(UpdateUserRequest req, CancellationToken ct);
	Task<UserStatsResponse> GetMyStatsAsync(CancellationToken ct);
	Task<IReadOnlyList<UserSummary>> SearchAsync(string q, CancellationToken ct);
	Task<AvatarResponse> UploadAvatarAsync(Stream s, string fileName, string contentType, CancellationToken ct);
}

public class UserService : IUserService
{
	private readonly IUnitOfWork _uow;
	private readonly ICurrentUserService _current;
	private readonly IMapper _mapper;
	private readonly IFileStorageService _storage;
	public UserService(IUnitOfWork u, ICurrentUserService c, IMapper m, IFileStorageService s)
	{ _uow = u; _current = c; _mapper = m; _storage = s; }
	private Guid Me => _current.UserId ?? throw new UnauthorizedAccessException();

	public async Task<UserResponse> GetMeAsync(CancellationToken ct)
		=> _mapper.Map<UserResponse>(await _uow.Users.GetByIdAsync(Me, ct));

	public async Task<UserResponse> UpdateMeAsync(UpdateUserRequest req, CancellationToken ct)
	{
		var u = await _uow.Users.GetByIdAsync(Me, ct) ?? throw new NotFoundException(nameof(User), Me);
		u.FullName = req.FullName; u.AvatarUrl = req.AvatarUrl;
		_uow.Users.Update(u);
		await _uow.SaveChangesAsync(ct);
		return _mapper.Map<UserResponse>(u);
	}

	public async Task<UserStatsResponse> GetMyStatsAsync(CancellationToken ct)
	{
		var tasksQ = _uow.Tasks.Query().Where(t => t.AssigneeId == Me);
		var total = await tasksQ.CountAsync(ct);
		var done = await tasksQ.CountAsync(t => t.Status == Domain.Enums.TaskStatus.Done, ct);
		var projects = await _uow.Projects.CountForUserAsync(Me, ct);
		return new UserStatsResponse(done, total, total == 0 ? 0 : (double)done * 100 / total, projects, 0);
	}

	public async Task<IReadOnlyList<UserSummary>> SearchAsync(string q, CancellationToken ct)
		=> _mapper.Map<List<UserSummary>>(await _uow.Users.SearchAsync(q, 20, ct));

	public async Task<AvatarResponse> UploadAvatarAsync(Stream s, string fileName, string contentType, CancellationToken ct)
	{
		var (url, _, _, _) = await _storage.UploadAsync(s, fileName, contentType, ct);
		var u = await _uow.Users.GetByIdAsync(Me, ct) ?? throw new NotFoundException(nameof(User), Me);
		u.AvatarUrl = url;
		_uow.Users.Update(u);
		await _uow.SaveChangesAsync(ct);
		return new AvatarResponse(url);
	}
}
```

## 9. Controllers (`TaskFlow.API/Controllers/V1`)

### `AuthController.cs`

```csharp
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using TaskFlow.Application.DTOs.Auth;
using TaskFlow.Application.UseCases.Auth;
using TaskFlow.Shared.Wrappers;

namespace TaskFlow.API.Controllers.V1;

[ApiController]
[Route("api/v1/auth")]
[EnableRateLimiting("auth")]
public class AuthController : ControllerBase
{
	private readonly IAuthService _auth;
	public AuthController(IAuthService auth) { _auth = auth; }
	private string? Ip => HttpContext.Connection.RemoteIpAddress?.ToString();

	[HttpPost("register")]
	public async Task<ActionResult<ApiResponse<AuthResponse>>> Register([FromBody] RegisterRequest req, CancellationToken ct)
		=> Ok(ApiResponse<AuthResponse>.Ok(await _auth.RegisterAsync(req, ct)));

	[HttpPost("login")]
	public async Task<ActionResult<ApiResponse<AuthResponse>>> Login([FromBody] LoginRequest req, CancellationToken ct)
		=> Ok(ApiResponse<AuthResponse>.Ok(await _auth.LoginAsync(req, Ip, ct)));

	[HttpPost("refresh")]
	public async Task<ActionResult<ApiResponse<AuthResponse>>> Refresh([FromBody] RefreshRequest req, CancellationToken ct)
		=> Ok(ApiResponse<AuthResponse>.Ok(await _auth.RefreshAsync(req, Ip, ct)));

	[Authorize] [HttpPost("logout")]
	public async Task<ActionResult<ApiResponse<object>>> Logout([FromBody] RefreshRequest req, CancellationToken ct)
	{ await _auth.LogoutAsync(req, ct); return Ok(ApiResponse<object>.Ok(new { }, "Logged out.")); }

	[HttpPost("forgot-password")]
	public async Task<ActionResult<ApiResponse<object>>> Forgot([FromBody] ForgotPasswordRequest req, CancellationToken ct)
	{ await _auth.ForgotPasswordAsync(req, ct); return Ok(ApiResponse<object>.Ok(new { }, "OTP sent if email exists.")); }

	[HttpPost("verify-otp")]
	public async Task<ActionResult<ApiResponse<OtpVerifiedResponse>>> Verify([FromBody] VerifyOtpRequest req, CancellationToken ct)
		=> Ok(ApiResponse<OtpVerifiedResponse>.Ok(await _auth.VerifyOtpAsync(req, ct)));

	[HttpPost("reset-password")]
	public async Task<ActionResult<ApiResponse<object>>> Reset([FromBody] ResetPasswordRequest req, CancellationToken ct)
	{ await _auth.ResetPasswordAsync(req, ct); return Ok(ApiResponse<object>.Ok(new { }, "Password reset.")); }
}
```

### `UsersController.cs`

```csharp
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TaskFlow.Application.DTOs.Users;
using TaskFlow.Application.UseCases;
using TaskFlow.Shared.Wrappers;

namespace TaskFlow.API.Controllers.V1;

[ApiController] [Authorize]
[Route("api/v1/users")]
public class UsersController : ControllerBase
{
	private readonly IUserService _users;
	public UsersController(IUserService users) { _users = users; }

	[HttpGet("me")]
	public async Task<ActionResult<ApiResponse<UserResponse>>> Me(CancellationToken ct)
		=> Ok(ApiResponse<UserResponse>.Ok(await _users.GetMeAsync(ct)));

	[HttpPut("me")]
	public async Task<ActionResult<ApiResponse<UserResponse>>> Update([FromBody] UpdateUserRequest req, CancellationToken ct)
		=> Ok(ApiResponse<UserResponse>.Ok(await _users.UpdateMeAsync(req, ct)));

	[HttpGet("me/stats")]
	public async Task<ActionResult<ApiResponse<UserStatsResponse>>> Stats(CancellationToken ct)
		=> Ok(ApiResponse<UserStatsResponse>.Ok(await _users.GetMyStatsAsync(ct)));

	[HttpPost("me/avatar")]
	public async Task<ActionResult<ApiResponse<AvatarResponse>>> Avatar(IFormFile file, CancellationToken ct)
	{
		if (file is null || file.Length == 0) return BadRequest(ApiResponse<AvatarResponse>.Fail("File required."));
		await using var s = file.OpenReadStream();
		return Ok(ApiResponse<AvatarResponse>.Ok(await _users.UploadAvatarAsync(s, file.FileName, file.ContentType, ct)));
	}

	[HttpGet("search")]
	public async Task<ActionResult<ApiResponse<IReadOnlyList<UserSummary>>>> Search([FromQuery] string q, CancellationToken ct)
		=> Ok(ApiResponse<IReadOnlyList<UserSummary>>.Ok(await _users.SearchAsync(q, ct)));
}
```

### `ProjectsController.cs`

```csharp
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TaskFlow.Application.DTOs.Projects;
using TaskFlow.Application.UseCases.Projects;
using TaskFlow.Shared.Wrappers;

namespace TaskFlow.API.Controllers.V1;

[ApiController] [Authorize]
[Route("api/v1/projects")]
public class ProjectsController : ControllerBase
{
	private readonly IProjectService _svc;
	public ProjectsController(IProjectService svc) { _svc = svc; }

	[HttpGet]
	public async Task<ActionResult<ApiResponse<PagedResult<ProjectSummary>>>> List(
		[FromQuery] int page = 1, [FromQuery] int pageSize = 20, CancellationToken ct = default)
		=> Ok(ApiResponse<PagedResult<ProjectSummary>>.Ok(await _svc.ListAsync(page, pageSize, ct)));

	[HttpPost]
	public async Task<ActionResult<ApiResponse<ProjectResponse>>> Create([FromBody] CreateProjectRequest req, CancellationToken ct)
		=> Ok(ApiResponse<ProjectResponse>.Ok(await _svc.CreateAsync(req, ct)));

	[HttpGet("{id:guid}")]
	public async Task<ActionResult<ApiResponse<ProjectResponse>>> Get(Guid id, CancellationToken ct)
		=> Ok(ApiResponse<ProjectResponse>.Ok(await _svc.GetAsync(id, ct)));

	[HttpPut("{id:guid}")]
	public async Task<ActionResult<ApiResponse<ProjectResponse>>> Update(Guid id, [FromBody] UpdateProjectRequest req, CancellationToken ct)
		=> Ok(ApiResponse<ProjectResponse>.Ok(await _svc.UpdateAsync(id, req, ct)));

	[HttpDelete("{id:guid}")]
	public async Task<ActionResult<ApiResponse<object>>> Delete(Guid id, CancellationToken ct)
	{ await _svc.DeleteAsync(id, ct); return Ok(ApiResponse<object>.Ok(new { })); }

	[HttpGet("{id:guid}/stats")]
	public async Task<ActionResult<ApiResponse<ProjectStatsResponse>>> Stats(Guid id, CancellationToken ct)
		=> Ok(ApiResponse<ProjectStatsResponse>.Ok(await _svc.GetStatsAsync(id, ct)));

	[HttpPost("{id:guid}/members")]
	public async Task<ActionResult<ApiResponse<ProjectMemberResponse>>> Invite(Guid id, [FromBody] InviteMemberRequest req, CancellationToken ct)
		=> Ok(ApiResponse<ProjectMemberResponse>.Ok(await _svc.InviteMemberAsync(id, req, ct)));

	[HttpPatch("{id:guid}/members/{userId:guid}")]
	public async Task<ActionResult<ApiResponse<ProjectMemberResponse>>> ChangeRole(
		Guid id, Guid userId, [FromBody] ChangeMemberRoleRequest req, CancellationToken ct)
		=> Ok(ApiResponse<ProjectMemberResponse>.Ok(await _svc.ChangeMemberRoleAsync(id, userId, req, ct)));

	[HttpDelete("{id:guid}/members/{userId:guid}")]
	public async Task<ActionResult<ApiResponse<object>>> RemoveMember(Guid id, Guid userId, CancellationToken ct)
	{ await _svc.RemoveMemberAsync(id, userId, ct); return Ok(ApiResponse<object>.Ok(new { })); }
}
```

### `TasksController.cs`

```csharp
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TaskFlow.Application.DTOs.Tasks;
using TaskFlow.Application.UseCases.Tasks;
using TaskFlow.Shared.Wrappers;

namespace TaskFlow.API.Controllers.V1;

[ApiController] [Authorize]
[Route("api/v1")]
public class TasksController : ControllerBase
{
	private readonly ITaskService _svc;
	public TasksController(ITaskService svc) { _svc = svc; }

	[HttpGet("projects/{projectId:guid}/tasks")]
	public async Task<ActionResult<ApiResponse<IReadOnlyList<TaskSummary>>>> List(Guid projectId, CancellationToken ct)
		=> Ok(ApiResponse<IReadOnlyList<TaskSummary>>.Ok(await _svc.ListByProjectAsync(projectId, ct)));

	[HttpPost("tasks")]
	public async Task<ActionResult<ApiResponse<TaskDetailResponse>>> Create([FromBody] CreateTaskRequest req, CancellationToken ct)
		=> Ok(ApiResponse<TaskDetailResponse>.Ok(await _svc.CreateAsync(req, ct)));

	[HttpGet("tasks/{id:guid}")]
	public async Task<ActionResult<ApiResponse<TaskDetailResponse>>> Get(Guid id, CancellationToken ct)
		=> Ok(ApiResponse<TaskDetailResponse>.Ok(await _svc.GetAsync(id, ct)));

	[HttpPut("tasks/{id:guid}")]
	public async Task<ActionResult<ApiResponse<TaskResponse>>> Update(Guid id, [FromBody] UpdateTaskRequest req, CancellationToken ct)
		=> Ok(ApiResponse<TaskResponse>.Ok(await _svc.UpdateAsync(id, req, ct)));

	[HttpPatch("tasks/{id:guid}/status")]
	public async Task<ActionResult<ApiResponse<object>>> Status(Guid id, [FromBody] UpdateStatusRequest req, CancellationToken ct)
	{ await _svc.UpdateStatusAsync(id, req, ct); return Ok(ApiResponse<object>.Ok(new { })); }

	[HttpPatch("tasks/{id:guid}/position")]
	public async Task<ActionResult<ApiResponse<object>>> Reorder(Guid id, [FromBody] ReorderTaskRequest req, CancellationToken ct)
	{ await _svc.ReorderAsync(id, req, ct); return Ok(ApiResponse<object>.Ok(new { })); }

	[HttpDelete("tasks/{id:guid}")]
	public async Task<ActionResult<ApiResponse<object>>> Delete(Guid id, CancellationToken ct)
	{ await _svc.DeleteAsync(id, ct); return Ok(ApiResponse<object>.Ok(new { })); }

	[HttpPost("tasks/{id:guid}/subtasks")]
	public async Task<ActionResult<ApiResponse<SubtaskResponse>>> AddSubtask(Guid id, [FromBody] CreateSubtaskRequest req, CancellationToken ct)
		=> Ok(ApiResponse<SubtaskResponse>.Ok(await _svc.AddSubtaskAsync(id, req, ct)));

	[HttpPatch("tasks/{id:guid}/subtasks/{sid:guid}")]
	public async Task<ActionResult<ApiResponse<SubtaskResponse>>> UpdateSubtask(Guid id, Guid sid, [FromBody] UpdateSubtaskRequest req, CancellationToken ct)
		=> Ok(ApiResponse<SubtaskResponse>.Ok(await _svc.UpdateSubtaskAsync(id, sid, req, ct)));

	[HttpDelete("tasks/{id:guid}/subtasks/{sid:guid}")]
	public async Task<ActionResult<ApiResponse<object>>> DeleteSubtask(Guid id, Guid sid, CancellationToken ct)
	{ await _svc.DeleteSubtaskAsync(id, sid, ct); return Ok(ApiResponse<object>.Ok(new { })); }
}
```

### `CommentsController.cs`

```csharp
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TaskFlow.Application.DTOs.Comments;
using TaskFlow.Application.UseCases;
using TaskFlow.Shared.Wrappers;

namespace TaskFlow.API.Controllers.V1;

[ApiController] [Authorize]
[Route("api/v1/tasks/{taskId:guid}/comments")]
public class CommentsController : ControllerBase
{
	private readonly ICommentService _svc;
	public CommentsController(ICommentService svc) { _svc = svc; }

	[HttpGet]
	public async Task<ActionResult<ApiResponse<IReadOnlyList<CommentResponse>>>> List(Guid taskId, CancellationToken ct)
		=> Ok(ApiResponse<IReadOnlyList<CommentResponse>>.Ok(await _svc.ListAsync(taskId, ct)));

	[HttpPost]
	public async Task<ActionResult<ApiResponse<CommentResponse>>> Create(Guid taskId, [FromBody] CreateCommentRequest req, CancellationToken ct)
		=> Ok(ApiResponse<CommentResponse>.Ok(await _svc.CreateAsync(taskId, req, ct)));

	[HttpDelete("{cid:guid}")]
	public async Task<ActionResult<ApiResponse<object>>> Delete(Guid taskId, Guid cid, CancellationToken ct)
	{ await _svc.DeleteAsync(taskId, cid, ct); return Ok(ApiResponse<object>.Ok(new { })); }
}
```

### `TagsController.cs` & `NotificationsController.cs`

```csharp
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TaskFlow.Application.DTOs.Notifications;
using TaskFlow.Application.DTOs.Tags;
using TaskFlow.Application.UseCases;
using TaskFlow.Shared.Wrappers;

namespace TaskFlow.API.Controllers.V1;

[ApiController] [Authorize]
[Route("api/v1/tags")]
public class TagsController : ControllerBase
{
	private readonly ITagService _svc;
	public TagsController(ITagService svc) { _svc = svc; }

	[HttpGet]
	public async Task<ActionResult<ApiResponse<IReadOnlyList<TagResponse>>>> List(CancellationToken ct)
		=> Ok(ApiResponse<IReadOnlyList<TagResponse>>.Ok(await _svc.ListAsync(ct)));

	[HttpPost]
	public async Task<ActionResult<ApiResponse<TagResponse>>> Create([FromBody] CreateTagRequest req, CancellationToken ct)
		=> Ok(ApiResponse<TagResponse>.Ok(await _svc.CreateAsync(req, ct)));

	[HttpDelete("{id:guid}")]
	public async Task<ActionResult<ApiResponse<object>>> Delete(Guid id, CancellationToken ct)
	{ await _svc.DeleteAsync(id, ct); return Ok(ApiResponse<object>.Ok(new { })); }
}

[ApiController] [Authorize]
[Route("api/v1/notifications")]
public class NotificationsController : ControllerBase
{
	private readonly INotificationService _svc;
	public NotificationsController(INotificationService svc) { _svc = svc; }

	[HttpGet]
	public async Task<ActionResult<ApiResponse<PagedResult<NotificationResponse>>>> List(
		[FromQuery] int page = 1, [FromQuery] int pageSize = 20, CancellationToken ct = default)
		=> Ok(ApiResponse<PagedResult<NotificationResponse>>.Ok(await _svc.ListAsync(page, pageSize, ct)));

	[HttpPatch("{id:guid}/read")]
	public async Task<ActionResult<ApiResponse<object>>> Read(Guid id, CancellationToken ct)
	{ await _svc.MarkReadAsync(id, ct); return Ok(ApiResponse<object>.Ok(new { })); }

	[HttpPost("read-all")]
	public async Task<ActionResult<ApiResponse<object>>> ReadAll(CancellationToken ct)
	{ await _svc.MarkAllReadAsync(ct); return Ok(ApiResponse<object>.Ok(new { })); }

	[HttpDelete("{id:guid}")]
	public async Task<ActionResult<ApiResponse<object>>> Delete(Guid id, CancellationToken ct)
	{ await _svc.DeleteAsync(id, ct); return Ok(ApiResponse<object>.Ok(new { })); }

	[HttpPost("push-token")]
	public async Task<ActionResult<ApiResponse<object>>> Register([FromBody] RegisterPushTokenRequest req, CancellationToken ct)
	{ await _svc.RegisterPushTokenAsync(req, ct); return Ok(ApiResponse<object>.Ok(new { }, "Token registered.")); }
}
```

### `AttachmentsController.cs`

```csharp
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Application.DTOs.Attachments;
using TaskFlow.Domain.Entities;
using TaskFlow.Domain.Enums;
using TaskFlow.Domain.Exceptions;
using TaskFlow.Shared.Wrappers;

namespace TaskFlow.API.Controllers.V1;

[ApiController] [Authorize]
[Route("api/v1")]
public class AttachmentsController : ControllerBase
{
	private readonly IUnitOfWork _uow;
	private readonly IFileStorageService _storage;
	private readonly ICurrentUserService _current;

	public AttachmentsController(IUnitOfWork uow, IFileStorageService storage, ICurrentUserService current)
	{ _uow = uow; _storage = storage; _current = current; }

	private Guid Me => _current.UserId ?? throw new UnauthorizedAccessException();

	[HttpGet("projects/{projectId:guid}/attachments")]
	public async Task<ActionResult<ApiResponse<IReadOnlyList<AttachmentResponse>>>> ListProject(Guid projectId, CancellationToken ct)
	{
		if (!await _uow.Projects.IsMemberAsync(projectId, Me, ct)) throw new ForbiddenException();
		var items = await _uow.Attachments.FindAsync(
			a => a.EntityType == AttachmentEntityType.Project && a.EntityId == projectId, ct);
		return Ok(ApiResponse<IReadOnlyList<AttachmentResponse>>.Ok(items.Select(Map).ToList()));
	}

	[HttpPost("projects/{projectId:guid}/attachments")]
	public Task<ActionResult<ApiResponse<AttachmentResponse>>> UploadProject(Guid projectId, IFormFile file, CancellationToken ct)
		=> UploadAsync(AttachmentEntityType.Project, projectId, file, ct);

	[HttpGet("tasks/{taskId:guid}/attachments")]
	public async Task<ActionResult<ApiResponse<IReadOnlyList<AttachmentResponse>>>> ListTask(Guid taskId, CancellationToken ct)
	{
		var items = await _uow.Attachments.FindAsync(
			a => a.EntityType == AttachmentEntityType.Task && a.EntityId == taskId, ct);
		return Ok(ApiResponse<IReadOnlyList<AttachmentResponse>>.Ok(items.Select(Map).ToList()));
	}

	[HttpPost("tasks/{taskId:guid}/attachments")]
	public Task<ActionResult<ApiResponse<AttachmentResponse>>> UploadTask(Guid taskId, IFormFile file, CancellationToken ct)
		=> UploadAsync(AttachmentEntityType.Task, taskId, file, ct);

	[HttpDelete("tasks/{taskId:guid}/attachments/{aid:guid}")]
	public async Task<ActionResult<ApiResponse<object>>> Delete(Guid taskId, Guid aid, CancellationToken ct)
	{
		var a = await _uow.Attachments.GetByIdAsync(aid, ct) ?? throw new NotFoundException(nameof(Attachment), aid);
		if (a.UploadedById != Me) throw new ForbiddenException();
		await _storage.DeleteAsync(a.FileUrl, ct);
		_uow.Attachments.Delete(a);
		await _uow.SaveChangesAsync(ct);
		return Ok(ApiResponse<object>.Ok(new { }));
	}

	private async Task<ActionResult<ApiResponse<AttachmentResponse>>> UploadAsync(
		AttachmentEntityType type, Guid entityId, IFormFile file, CancellationToken ct)
	{
		if (file is null || file.Length == 0)
			return BadRequest(ApiResponse<AttachmentResponse>.Fail("File required."));

		await using var s = file.OpenReadStream();
		var (url, name, mime, size) = await _storage.UploadAsync(s, file.FileName, file.ContentType, ct);

		var att = new Attachment
		{
			EntityType = type, EntityId = entityId, UploadedById = Me,
			FileName = name, FileUrl = url, FileSize = size, MimeType = mime
		};
		await _uow.Attachments.AddAsync(att, ct);
		await _uow.SaveChangesAsync(ct);
		return Ok(ApiResponse<AttachmentResponse>.Ok(Map(att)));
	}

	private static AttachmentResponse Map(Attachment a) => new(
		a.Id, a.FileName, a.FileUrl, a.FileSize, a.MimeType, a.UploadedById, a.CreatedAt);
}
```

## 10. Infrastructure DI Module

### `Infrastructure/DependencyInjection.cs`

```csharp
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Infrastructure.Identity;
using TaskFlow.Infrastructure.Persistence;
using TaskFlow.Infrastructure.Persistence.Repositories;
using TaskFlow.Infrastructure.Services;

namespace TaskFlow.Infrastructure;

public static class DependencyInjection
{
	public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration cfg)
	{
		services.AddDbContext<TaskFlowDbContext>(o =>
			o.UseNpgsql(cfg.GetConnectionString("DefaultConnection"))
			 .UseSnakeCaseNamingConvention());

		services.AddScoped(typeof(IGenericRepository<>), typeof(GenericRepository<>));
		services.AddScoped<IUserRepository, UserRepository>();
		services.AddScoped<IProjectRepository, ProjectRepository>();
		services.AddScoped<ITaskRepository, TaskRepository>();
		services.AddScoped<INotificationRepository, NotificationRepository>();
		services.AddScoped<IUnitOfWork, UnitOfWork>();

		services.AddScoped<IJwtTokenService, JwtTokenService>();
		services.AddScoped<ICurrentUserService, CurrentUserService>();
		services.AddScoped<IEmailService, EmailService>();
		services.AddScoped<IOtpService, OtpService>();
		services.AddHttpClient<IFileStorageService, FileStorageService>();
		services.AddScoped<IPushNotificationService, FcmPushNotificationService>();
		return services;
	}
}
```

## 11. NuGet Packages (per project)

```bash
# TaskFlow.API
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add package Microsoft.AspNetCore.Identity.EntityFrameworkCore
dotnet add package Swashbuckle.AspNetCore
dotnet add package FluentValidation.AspNetCore

# TaskFlow.Application
dotnet add package AutoMapper.Extensions.Microsoft.DependencyInjection
dotnet add package FluentValidation
dotnet add package Microsoft.AspNetCore.Identity

# TaskFlow.Infrastructure
dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add package EFCore.NamingConventions
dotnet add package Microsoft.AspNetCore.Identity.EntityFrameworkCore
dotnet add package FirebaseAdmin
```

## 12. First Migration & Run

```bash
# from solution root
dotnet ef migrations add InitialCreate \
	--project src/TaskFlow.Infrastructure \
	--startup-project src/TaskFlow.API \
	--output-dir Persistence/Migrations

dotnet ef database update \
	--project src/TaskFlow.Infrastructure \
	--startup-project src/TaskFlow.API

dotnet run --project src/TaskFlow.API
# → https://localhost:5001/swagger
```

<aside>
✅

**API surface complete.** Auth (register/login/refresh/logout/forgot/verify-otp/reset), Users (me/stats/avatar/search), Projects (CRUD + members + stats + attachments), Tasks (CRUD + status + reorder + subtasks), Comments (list/create/delete), Tags (list/create/delete), Notifications (list/read/read-all/delete/push-token), and Attachments (project + task upload/list/delete) are all wired through Controllers → Services → UnitOfWork → EF Core.

</aside>
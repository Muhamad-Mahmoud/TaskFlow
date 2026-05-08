using AutoMapper;
using Microsoft.EntityFrameworkCore;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Application.DTOs.Users;
using TaskFlow.Domain.Entities;
using TaskFlow.Domain.Exceptions;

namespace TaskFlow.Application.UseCases;

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
		var tasksQ = _uow.Tasks.Query().Where(t => t.AssigneeId == Me || t.CreatedById == Me);
		var total = await tasksQ.CountAsync(ct);
		var done = await tasksQ.CountAsync(t => t.Status == Domain.Enums.TaskStatus.Done, ct);
		var inProgress = await tasksQ.CountAsync(t => t.Status == Domain.Enums.TaskStatus.InProgress, ct);
		var review = await tasksQ.CountAsync(t => t.Status == Domain.Enums.TaskStatus.Review, ct);
		var blocked = await tasksQ.CountAsync(t => t.Status == Domain.Enums.TaskStatus.Blocked, ct);
		var todo = await tasksQ.CountAsync(t => t.Status == Domain.Enums.TaskStatus.Todo, ct);
		
		var projects = await _uow.Projects.CountForUserAsync(Me, ct);
		
		double completionPercentage = total == 0 ? 0 : (double)done * 100 / total;

		return new UserStatsResponse(
			total, 
			done, 
			inProgress, 
			review, 
			blocked, 
			todo, 
			projects, 
			completionPercentage);
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

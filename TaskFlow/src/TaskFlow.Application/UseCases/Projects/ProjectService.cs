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
			PageNumber = page, PageSize = pageSize, TotalCount = total
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

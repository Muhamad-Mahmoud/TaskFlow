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
			.ForCtorParam("Id", o => o.MapFrom(s => s.UserId))
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

namespace TaskFlow.Application.DTOs.Projects;

public record ChangeMemberRoleRequest(Guid MemberId, string Role);

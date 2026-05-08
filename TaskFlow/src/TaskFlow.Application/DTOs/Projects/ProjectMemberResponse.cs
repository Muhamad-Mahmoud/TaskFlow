namespace TaskFlow.Application.DTOs.Projects;

public record ProjectMemberResponse(
    Guid Id,
    string FullName,
    string? AvatarUrl,
    string Role);

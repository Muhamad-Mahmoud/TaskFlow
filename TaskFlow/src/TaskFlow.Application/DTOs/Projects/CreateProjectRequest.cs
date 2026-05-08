namespace TaskFlow.Application.DTOs.Projects;

public record CreateProjectRequest(
    string Name,
    string? Description,
    string? ColorLabel,
    DateTime? StartDate,
    DateTime? DueDate,
    string? Priority,
    List<Guid>? MemberIds);

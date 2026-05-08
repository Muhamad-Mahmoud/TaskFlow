namespace TaskFlow.Application.DTOs.Projects;

public record ProjectResponse(
    Guid Id,
    string Name,
    string? Description,
    string Status,
    string Priority,
    double CompletionPercentage,
    string ColorLabel,
    DateTime? StartDate,
    DateTime? DueDate,
    IEnumerable<ProjectMemberResponse> Members,
    DateTime CreatedAt,
    DateTime UpdatedAt);

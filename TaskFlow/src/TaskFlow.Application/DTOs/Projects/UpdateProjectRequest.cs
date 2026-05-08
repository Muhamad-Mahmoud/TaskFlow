namespace TaskFlow.Application.DTOs.Projects;

public record UpdateProjectRequest(
    string Name,
    string? Description,
    string? ColorLabel,
    DateTime? StartDate,
    DateTime? DueDate,
    string? Status,
    string? Priority);

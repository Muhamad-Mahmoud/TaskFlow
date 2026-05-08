namespace TaskFlow.Application.DTOs.Tasks;

public record TaskResponse(
    Guid Id,
    string Title,
    string? Description,
    string Status,
    string Priority,
    DateTime? DueDate,
    double? EstimatedHours,
    AssigneeBrief? Assignee,
    DateTime CreatedAt,
    DateTime UpdatedAt);

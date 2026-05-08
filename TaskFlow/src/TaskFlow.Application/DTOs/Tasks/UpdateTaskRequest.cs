namespace TaskFlow.Application.DTOs.Tasks;

public record UpdateTaskRequest(
    string Title,
    string? Description,
    string Status,
    string? Priority,
    DateTime? DueDate,
    double? EstimatedHours,
    Guid? AssigneeId);

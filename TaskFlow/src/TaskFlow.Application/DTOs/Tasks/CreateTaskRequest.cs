namespace TaskFlow.Application.DTOs.Tasks;

public record CreateTaskRequest(
    Guid ProjectId,
    string Title,
    string? Description,
    string Status,
    string? Priority,
    DateTime? DueDate,
    double? EstimatedHours,
    Guid? AssigneeId,
    List<CreateSubtaskRequest>? Subtasks,
    List<Guid>? TagIds);

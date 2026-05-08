namespace TaskFlow.Application.DTOs.Tasks;

public record CreateTaskRequest(
    Guid ProjectId,
    string Title,
    string? Description,
    string Status,
    string? Priority,
    DateTime? DueDate,
    double? EstimatedHours,
    string? AssigneeEmailOrPhone,
    List<CreateSubtaskRequest>? Subtasks,
    List<Guid>? TagIds);

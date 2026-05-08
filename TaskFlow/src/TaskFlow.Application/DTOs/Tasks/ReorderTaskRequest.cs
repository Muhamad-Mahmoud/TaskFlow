namespace TaskFlow.Application.DTOs.Tasks;

public record ReorderTaskRequest(Guid TaskId, int NewPosition, string NewStatus);

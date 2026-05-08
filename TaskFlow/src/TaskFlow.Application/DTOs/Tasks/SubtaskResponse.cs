namespace TaskFlow.Application.DTOs.Tasks;

public record SubtaskResponse(
    Guid Id,
    string Title,
    bool IsCompleted,
    int Position);

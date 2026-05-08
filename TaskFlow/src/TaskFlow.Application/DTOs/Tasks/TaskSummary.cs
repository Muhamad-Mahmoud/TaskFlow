namespace TaskFlow.Application.DTOs.Tasks;

public record TaskSummary(
    Guid Id,
    string Title,
    string Status,
    string Priority,
    string? AssigneeName,
    string ProjectName,
    DateTime? DueDate);

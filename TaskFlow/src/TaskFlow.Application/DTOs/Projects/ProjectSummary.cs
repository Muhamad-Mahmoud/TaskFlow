namespace TaskFlow.Application.DTOs.Projects;

public record ProjectSummary(
    Guid Id,
    string Name,
    string Status,
    double CompletionPercentage,
    int MemberCount,
    int TaskCount);

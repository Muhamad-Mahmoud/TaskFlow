namespace TaskFlow.Application.DTOs.Users;

public record UserStatsResponse(
    int TotalTasks,
    int CompletedCount,
    int InProgressCount,
    int ReviewCount,
    int BlockedCount,
    int TodoCount,
    int TotalProjects,
    double CompletionPercentage);

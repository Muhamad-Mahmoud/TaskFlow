namespace TaskFlow.Application.DTOs.Projects;

public record ProjectStatsResponse(
    int TotalTasks,
    int TodoTasks,
    int InProgressTasks,
    int ReviewTasks,
    int CompletedTasks,
    double CompletionPercentage);

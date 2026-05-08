using TaskFlow.Application.DTOs.Tags;

namespace TaskFlow.Application.DTOs.Tasks;

public record TaskDetailResponse(
    Guid Id,
    string Title,
    string? Description,
    string Status,
    string Priority,
    DateTime? DueDate,
    double? EstimatedHours,
    Guid ProjectId,
    AssigneeBrief? Assignee,
    AssigneeBrief CreatedBy,
    IEnumerable<SubtaskResponse> Subtasks,
    IEnumerable<TagBrief> Tags,
    int CommentsCount,
    int AttachmentsCount,
    DateTime CreatedAt,
    DateTime UpdatedAt);

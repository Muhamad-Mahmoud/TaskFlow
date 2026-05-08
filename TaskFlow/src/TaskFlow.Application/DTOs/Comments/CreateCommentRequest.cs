namespace TaskFlow.Application.DTOs.Comments;

public record CreateCommentRequest(
    Guid TaskId,
    string Content,
    Guid? ParentId);

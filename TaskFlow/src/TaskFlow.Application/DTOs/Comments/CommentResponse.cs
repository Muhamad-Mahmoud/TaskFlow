namespace TaskFlow.Application.DTOs.Comments;

public record CommentResponse(
    Guid Id,
    string Content,
    string AuthorName,
    string? AuthorAvatar,
    DateTime CreatedAt,
    DateTime UpdatedAt);

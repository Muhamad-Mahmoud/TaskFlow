namespace TaskFlow.Application.DTOs.Attachments;

public record AttachmentResponse(Guid Id, string FileName, string FileUrl,
	long FileSize, string MimeType, Guid UploadedById, DateTime CreatedAt);

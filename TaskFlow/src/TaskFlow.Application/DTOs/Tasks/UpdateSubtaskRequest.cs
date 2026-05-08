namespace TaskFlow.Application.DTOs.Tasks;

public record UpdateSubtaskRequest(string Title, int? Position, bool? IsCompleted);

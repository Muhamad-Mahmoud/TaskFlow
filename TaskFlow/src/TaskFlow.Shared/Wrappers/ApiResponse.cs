namespace TaskFlow.Shared.Wrappers;

public class ApiResponse<T>
{
    public bool Succeeded { get; set; }
    public string? Message { get; set; }
    public List<string>? Errors { get; set; }
    public T? Data { get; set; }

    public ApiResponse() { }

    public ApiResponse(T data, string? message = null)
    {
        Succeeded = true;
        Message = message;
        Data = data;
    }

    public static ApiResponse<T> Success(T data, string? message = null) => new(data, message);
    public static ApiResponse<T> Ok(T data, string? message = null) => new(data, message);
    public static ApiResponse<T> Fail(string message) => new() { Succeeded = false, Message = message };
    public static ApiResponse<T> Fail(List<string> errors) => new() { Succeeded = false, Errors = errors };
}

using TaskFlow.Domain.Common;

namespace TaskFlow.Domain.Entities;

public class PushToken : BaseEntity
{
    public Guid UserId { get; set; }
    public virtual User User { get; set; } = default!;
    public string Token { get; set; } = default!;
    public string Platform { get; set; } = "android";  // android | ios | web
    public string? DeviceId { get; set; }
}

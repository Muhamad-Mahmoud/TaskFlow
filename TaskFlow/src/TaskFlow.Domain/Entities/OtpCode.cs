using TaskFlow.Domain.Common;

namespace TaskFlow.Domain.Entities;

public class OtpCode : BaseEntity
{
    public string Email { get; set; } = default!;
    public string CodeHash { get; set; } = default!;
    public string Purpose { get; set; } = "password_reset";
    public DateTime ExpiresAt { get; set; }
    public bool IsUsed { get; set; }
    public int Attempts { get; set; }
}

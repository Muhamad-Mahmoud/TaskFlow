using Microsoft.EntityFrameworkCore;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Infrastructure.Persistence.Repositories;

public class UserRepository : GenericRepository<User>, IUserRepository
{
	public UserRepository(TaskFlowDbContext db) : base(db) { }

	public Task<User?> GetByEmailAsync(string email, CancellationToken ct = default)
		=> Set.FirstOrDefaultAsync(u => u.NormalizedEmail == email.ToUpperInvariant(), ct);

	public Task<User?> GetByEmailOrPhoneAsync(string emailOrPhone, CancellationToken ct = default)
	{
		var val = emailOrPhone.Trim();
		var upperVal = val.ToUpperInvariant();
		return Set.FirstOrDefaultAsync(u => u.NormalizedEmail == upperVal || u.PhoneNumber == val, ct);
	}

	public async Task<IReadOnlyList<User>> SearchAsync(string query, int take, CancellationToken ct = default)
	{
		var q = (query ?? "").Trim().ToLower();
		return await Set.AsNoTracking()
			.Where(u => u.FullName.ToLower().Contains(q) || u.Email!.ToLower().Contains(q))
			.OrderBy(u => u.FullName).Take(take).ToListAsync(ct);
	}
}

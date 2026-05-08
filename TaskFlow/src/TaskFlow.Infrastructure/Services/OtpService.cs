using System.Security.Cryptography;
using System.Text;
using Microsoft.EntityFrameworkCore;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Domain.Entities;
using TaskFlow.Infrastructure.Persistence;

namespace TaskFlow.Infrastructure.Services;

public class OtpService : IOtpService
{
	private readonly TaskFlowDbContext _db;
	public OtpService(TaskFlowDbContext db) { _db = db; }

	public async Task<string> CreateAsync(string email, string purpose, CancellationToken ct = default)
	{
		var code = RandomNumberGenerator.GetInt32(100000, 999999).ToString();
		_db.OtpCodes.Add(new OtpCode
		{
			Email = email.ToLowerInvariant(), CodeHash = Hash(code),
			Purpose = purpose, ExpiresAt = DateTime.UtcNow.AddMinutes(10)
		});
		await _db.SaveChangesAsync(ct);
		return code;
	}

	public async Task<bool> VerifyAsync(string email, string code, string purpose, CancellationToken ct = default)
	{
		var hash = Hash(code);
		var otp = await _db.OtpCodes
			.Where(o => o.Email == email.ToLowerInvariant() && o.Purpose == purpose && !o.IsUsed)
			.OrderByDescending(o => o.CreatedAt).FirstOrDefaultAsync(ct);

		if (otp is null || otp.ExpiresAt < DateTime.UtcNow || otp.Attempts >= 5) return false;
		if (otp.CodeHash != hash) { otp.Attempts++; await _db.SaveChangesAsync(ct); return false; }

		otp.IsUsed = true;
		await _db.SaveChangesAsync(ct);
		return true;
	}

	private static string Hash(string code)
	{
		using var sha = SHA256.Create();
		return Convert.ToHexString(sha.ComputeHash(Encoding.UTF8.GetBytes(code)));
	}
}

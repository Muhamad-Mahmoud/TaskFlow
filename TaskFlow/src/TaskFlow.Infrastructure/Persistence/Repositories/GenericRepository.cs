using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore;
using TaskFlow.Application.Common.Interfaces;
using TaskFlow.Infrastructure.Persistence;

namespace TaskFlow.Infrastructure.Persistence.Repositories;

public class GenericRepository<T> : IGenericRepository<T> where T : class
{
	protected readonly TaskFlowDbContext Db;
	protected readonly DbSet<T> Set;

	public GenericRepository(TaskFlowDbContext db) { Db = db; Set = db.Set<T>(); }

	public IQueryable<T> Query() => Set.AsQueryable();

	public Task<T?> GetByIdAsync(Guid id, CancellationToken ct = default)
		=> Set.FindAsync(new object[] { id }, ct).AsTask();

	public async Task<IReadOnlyList<T>> GetAllAsync(CancellationToken ct = default)
		=> await Set.AsNoTracking().ToListAsync(ct);

	public async Task<IReadOnlyList<T>> FindAsync(Expression<Func<T, bool>> predicate, CancellationToken ct = default)
		=> await Set.AsNoTracking().Where(predicate).ToListAsync(ct);

	public Task AddAsync(T entity, CancellationToken ct = default) => Set.AddAsync(entity, ct).AsTask();
	public void Update(T entity) => Set.Update(entity);
	public void Delete(T entity) => Set.Remove(entity);
	public void Remove(T entity) => Set.Remove(entity);

	public Task<bool> ExistsAsync(Expression<Func<T, bool>> predicate, CancellationToken ct = default)
		=> Set.AnyAsync(predicate, ct);
}

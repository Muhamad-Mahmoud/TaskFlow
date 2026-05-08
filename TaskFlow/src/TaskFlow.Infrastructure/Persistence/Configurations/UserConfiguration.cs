using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Infrastructure.Persistence.Configurations;

public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> b)
    {
        b.Property(x => x.FullName).IsRequired().HasMaxLength(150);
        b.Property(x => x.AvatarUrl).HasMaxLength(500);
        b.Property(x => x.Role).HasConversion<string>().HasMaxLength(20);
        b.HasIndex(x => x.Email).IsUnique();
        b.HasIndex(x => x.NormalizedEmail).IsUnique();
    }
}

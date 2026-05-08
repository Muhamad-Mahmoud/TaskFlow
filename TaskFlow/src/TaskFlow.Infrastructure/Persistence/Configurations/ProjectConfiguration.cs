using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Infrastructure.Persistence.Configurations;

public class ProjectConfiguration : IEntityTypeConfiguration<Project>
{
    public void Configure(EntityTypeBuilder<Project> b)
    {
        b.ToTable("projects");
        b.HasKey(x => x.Id);
        b.Property(x => x.Name).IsRequired().HasMaxLength(100);
        b.Property(x => x.Description).HasMaxLength(2000);
        b.Property(x => x.ColorLabel).IsRequired().HasMaxLength(9);
        b.Property(x => x.Status).HasConversion<string>().HasMaxLength(20);
        b.Property(x => x.Priority).HasConversion<string>().HasMaxLength(20);

        b.HasOne(x => x.Owner)
         .WithMany(u => u.OwnedProjects)
         .HasForeignKey(x => x.OwnerId)
         .OnDelete(DeleteBehavior.Restrict);

        b.HasIndex(x => x.OwnerId);
        b.HasIndex(x => x.Status);
    }
}

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Infrastructure.Persistence.Configurations;

public class ProjectMemberConfiguration : IEntityTypeConfiguration<ProjectMember>
{
    public void Configure(EntityTypeBuilder<ProjectMember> b)
    {
        b.ToTable("project_members");
        b.HasKey(x => new { x.ProjectId, x.UserId });
        b.Property(x => x.Role).HasConversion<string>().HasMaxLength(20);

        b.HasOne(x => x.Project)
         .WithMany(p => p.Members)
         .HasForeignKey(x => x.ProjectId)
         .OnDelete(DeleteBehavior.Cascade);

        b.HasOne(x => x.User)
         .WithMany(u => u.ProjectMemberships)
         .HasForeignKey(x => x.UserId)
         .OnDelete(DeleteBehavior.Cascade);
    }
}

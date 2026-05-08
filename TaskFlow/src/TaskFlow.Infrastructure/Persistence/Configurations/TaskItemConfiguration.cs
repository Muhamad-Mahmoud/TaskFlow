using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Infrastructure.Persistence.Configurations;

public class TaskItemConfiguration : IEntityTypeConfiguration<TaskItem>
{
    public void Configure(EntityTypeBuilder<TaskItem> b)
    {
        b.ToTable("tasks");
        b.HasKey(x => x.Id);
        b.Property(x => x.Title).IsRequired().HasMaxLength(200);
        b.Property(x => x.Description).HasMaxLength(5000);
        b.Property(x => x.Status).HasConversion<string>().HasMaxLength(20);
        b.Property(x => x.Priority).HasConversion<string>().HasMaxLength(20);

        b.HasOne(x => x.Project).WithMany(p => p.Tasks)
         .HasForeignKey(x => x.ProjectId).OnDelete(DeleteBehavior.Cascade);

        b.HasOne(x => x.CreatedBy).WithMany(u => u.CreatedTasks)
         .HasForeignKey(x => x.CreatedById).OnDelete(DeleteBehavior.Restrict);

        b.HasOne(x => x.Assignee).WithMany(u => u.AssignedTasks)
         .HasForeignKey(x => x.AssigneeId).OnDelete(DeleteBehavior.SetNull);

        b.HasIndex(x => new { x.ProjectId, x.Status });
        b.HasIndex(x => x.AssigneeId);
        b.HasIndex(x => x.DueDate);
    }
}

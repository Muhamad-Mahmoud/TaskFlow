using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Infrastructure.Persistence.Configurations;

public class SubtaskConfiguration : IEntityTypeConfiguration<Subtask>
{
    public void Configure(EntityTypeBuilder<Subtask> b)
    {
        b.ToTable("subtasks");
        b.HasKey(x => x.Id);
        b.Property(x => x.Title).IsRequired().HasMaxLength(200);
        b.HasOne(x => x.Task).WithMany(t => t.Subtasks)
         .HasForeignKey(x => x.TaskId).OnDelete(DeleteBehavior.Cascade);
        b.HasIndex(x => x.TaskId);
    }
}

public class CommentConfiguration : IEntityTypeConfiguration<Comment>
{
    public void Configure(EntityTypeBuilder<Comment> b)
    {
        b.ToTable("comments");
        b.HasKey(x => x.Id);
        b.Property(x => x.Content).IsRequired().HasMaxLength(4000);

        b.HasOne(x => x.Task).WithMany(t => t.Comments)
         .HasForeignKey(x => x.TaskId).OnDelete(DeleteBehavior.Cascade);

        b.HasOne(x => x.Author).WithMany(u => u.Comments)
         .HasForeignKey(x => x.AuthorId).OnDelete(DeleteBehavior.Restrict);

        b.HasOne(x => x.Parent).WithMany(c => c.Replies)
         .HasForeignKey(x => x.ParentId).OnDelete(DeleteBehavior.Restrict);

        b.HasIndex(x => x.TaskId);
    }
}

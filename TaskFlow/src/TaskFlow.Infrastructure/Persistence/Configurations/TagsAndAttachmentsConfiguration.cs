using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TaskFlow.Domain.Entities;

namespace TaskFlow.Infrastructure.Persistence.Configurations;

public class AttachmentConfiguration : IEntityTypeConfiguration<Attachment>
{
    public void Configure(EntityTypeBuilder<Attachment> b)
    {
        b.ToTable("attachments");
        b.HasKey(x => x.Id);
        b.Property(x => x.EntityType).HasConversion<string>().HasMaxLength(20);
        b.Property(x => x.FileName).IsRequired().HasMaxLength(255);
        b.Property(x => x.FileUrl).IsRequired().HasMaxLength(1000);
        b.Property(x => x.MimeType).IsRequired().HasMaxLength(100);
        b.HasIndex(x => new { x.EntityType, x.EntityId });
    }
}

public class TagConfiguration : IEntityTypeConfiguration<Tag>
{
    public void Configure(EntityTypeBuilder<Tag> b)
    {
        b.ToTable("tags");
        b.HasKey(x => x.Id);
        b.Property(x => x.Name).IsRequired().HasMaxLength(50);
        b.Property(x => x.Color).IsRequired().HasMaxLength(9);
        b.HasIndex(x => new { x.CreatedById, x.Name }).IsUnique();
    }
}

public class TaskTagConfiguration : IEntityTypeConfiguration<TaskTag>
{
    public void Configure(EntityTypeBuilder<TaskTag> b)
    {
        b.ToTable("task_tags");
        b.HasKey(x => new { x.TaskId, x.TagId });

        b.HasOne(x => x.Task).WithMany(t => t.TaskTags)
         .HasForeignKey(x => x.TaskId).OnDelete(DeleteBehavior.Cascade);

        b.HasOne(x => x.Tag).WithMany(t => t.TaskTags)
         .HasForeignKey(x => x.TagId).OnDelete(DeleteBehavior.Cascade);
    }
}

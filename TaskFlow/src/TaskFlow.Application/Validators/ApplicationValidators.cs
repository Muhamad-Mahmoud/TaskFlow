using FluentValidation;
using TaskFlow.Application.DTOs.Comments;
using TaskFlow.Application.DTOs.Projects;
using TaskFlow.Application.DTOs.Tags;
using TaskFlow.Application.DTOs.Tasks;

namespace TaskFlow.Application.Validators;

public class CreateProjectRequestValidator : AbstractValidator<CreateProjectRequest>
{
	public CreateProjectRequestValidator()
	{
		RuleFor(x => x.Name).NotEmpty().MaximumLength(100);
		RuleFor(x => x.Description).MaximumLength(2000);
		RuleFor(x => x.ColorLabel).Matches("^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$");
		RuleFor(x => x.Priority).Must(p => Enum.TryParse<Domain.Enums.TaskPriority>(p, true, out _));
		RuleFor(x => x).Must(x => !x.StartDate.HasValue || !x.DueDate.HasValue || x.DueDate >= x.StartDate)
			.WithMessage("DueDate must be after StartDate.");
	}
}

public class UpdateProjectRequestValidator : AbstractValidator<UpdateProjectRequest>
{
	public UpdateProjectRequestValidator()
	{
		RuleFor(x => x.Name).NotEmpty().MaximumLength(100);
		RuleFor(x => x.ColorLabel).Matches("^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$");
		RuleFor(x => x.Status).Must(s => Enum.TryParse<Domain.Enums.ProjectStatus>(s, true, out _));
		RuleFor(x => x.Priority).Must(p => Enum.TryParse<Domain.Enums.TaskPriority>(p, true, out _));
	}
}

public class InviteMemberRequestValidator : AbstractValidator<InviteMemberRequest>
{
	public InviteMemberRequestValidator()
	{
		RuleFor(x => x.UserId).NotEmpty();
		RuleFor(x => x.Role).Must(r => Enum.TryParse<Domain.Enums.ProjectMemberRole>(r, true, out _));
	}
}

public class CreateTaskRequestValidator : AbstractValidator<CreateTaskRequest>
{
	public CreateTaskRequestValidator()
	{
		RuleFor(x => x.Title).NotEmpty().MaximumLength(200);
		RuleFor(x => x.ProjectId).NotEmpty();
		RuleFor(x => x.Status).Must(s => Enum.TryParse<Domain.Enums.TaskStatus>(s, true, out _));
		RuleFor(x => x.Priority).Must(p => Enum.TryParse<Domain.Enums.TaskPriority>(p, true, out _));
		RuleFor(x => x.EstimatedHours).GreaterThan(0).When(x => x.EstimatedHours.HasValue);
	}
}

public class UpdateTaskRequestValidator : AbstractValidator<UpdateTaskRequest>
{
	public UpdateTaskRequestValidator()
	{
		RuleFor(x => x.Title).NotEmpty().MaximumLength(200);
		RuleFor(x => x.Status).Must(s => Enum.TryParse<Domain.Enums.TaskStatus>(s, true, out _));
		RuleFor(x => x.Priority).Must(p => Enum.TryParse<Domain.Enums.TaskPriority>(p, true, out _));
	}
}

public class ReorderTaskRequestValidator : AbstractValidator<ReorderTaskRequest>
{
	public ReorderTaskRequestValidator()
	{
		RuleFor(x => x.NewStatus).Must(s => Enum.TryParse<Domain.Enums.TaskStatus>(s, true, out _));
		RuleFor(x => x.NewPosition).GreaterThanOrEqualTo(0);
	}
}

public class CreateCommentRequestValidator : AbstractValidator<CreateCommentRequest>
{ public CreateCommentRequestValidator() => RuleFor(x => x.Content).NotEmpty().MaximumLength(4000); }

public class CreateTagRequestValidator : AbstractValidator<CreateTagRequest>
{
	public CreateTagRequestValidator()
	{
		RuleFor(x => x.Name).NotEmpty().MaximumLength(50);
		RuleFor(x => x.Color).Matches("^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$");
	}
}

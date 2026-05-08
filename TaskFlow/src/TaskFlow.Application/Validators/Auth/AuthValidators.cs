using FluentValidation;
using TaskFlow.Application.DTOs.Auth;

namespace TaskFlow.Application.Validators.Auth;

public class RegisterRequestValidator : AbstractValidator<RegisterRequest>
{
	public RegisterRequestValidator()
	{
		RuleFor(x => x.FullName).NotEmpty().MaximumLength(150);
		RuleFor(x => x.Email).NotEmpty().EmailAddress();
		RuleFor(x => x.Password).NotEmpty().MinimumLength(8)
			.Matches("[A-Z]").WithMessage("Must contain an uppercase letter.")
			.Matches("[0-9]").WithMessage("Must contain a digit.");
	}
}

public class LoginRequestValidator : AbstractValidator<LoginRequest>
{
	public LoginRequestValidator()
	{
		RuleFor(x => x.Email).NotEmpty().EmailAddress();
		RuleFor(x => x.Password).NotEmpty();
	}
}

public class RefreshRequestValidator : AbstractValidator<RefreshRequest>
{ public RefreshRequestValidator() => RuleFor(x => x.RefreshToken).NotEmpty(); }

public class ForgotPasswordRequestValidator : AbstractValidator<ForgotPasswordRequest>
{ public ForgotPasswordRequestValidator() => RuleFor(x => x.Email).NotEmpty().EmailAddress(); }

public class VerifyOtpRequestValidator : AbstractValidator<VerifyOtpRequest>
{
	public VerifyOtpRequestValidator()
	{
		RuleFor(x => x.Email).NotEmpty().EmailAddress();
		RuleFor(x => x.Code).NotEmpty().Length(4, 6).Matches("^[0-9]+$");
	}
}

public class ResetPasswordRequestValidator : AbstractValidator<ResetPasswordRequest>
{
	public ResetPasswordRequestValidator()
	{
		RuleFor(x => x.Email).NotEmpty().EmailAddress();
		RuleFor(x => x.ResetToken).NotEmpty();
		RuleFor(x => x.NewPassword).NotEmpty().MinimumLength(8).Matches("[A-Z]").Matches("[0-9]");
	}
}

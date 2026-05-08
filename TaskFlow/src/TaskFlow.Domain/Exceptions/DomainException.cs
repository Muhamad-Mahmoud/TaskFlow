namespace TaskFlow.Domain.Exceptions;

public class DomainException : Exception
{
	public DomainException(string message) : base(message) { }
}

public class NotFoundException : DomainException
{
	public NotFoundException(string entity, object key)
		: base($"{entity} with key '{key}' was not found.") { }
	public NotFoundException(string message) : base(message) { }
}

public class ForbiddenException : DomainException
{
	public ForbiddenException(string message = "You are not allowed to perform this action.")
		: base(message) { }
}

public class ConflictException : DomainException
{
	public ConflictException(string message) : base(message) { }
}

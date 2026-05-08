using System.Reflection;
using FluentValidation;
using Microsoft.Extensions.DependencyInjection;
using TaskFlow.Application.UseCases;
using TaskFlow.Application.UseCases.Auth;
using TaskFlow.Application.UseCases.Projects;
using TaskFlow.Application.UseCases.Tasks;

namespace TaskFlow.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddAutoMapper(Assembly.GetExecutingAssembly());
        services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly());
        
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<IProjectService, ProjectService>();
        services.AddScoped<ITaskService, TaskService>();
        services.AddScoped<ICommentService, CommentService>();
        services.AddScoped<ITagService, TagService>();
        services.AddScoped<INotificationService, NotificationService>();
        services.AddScoped<IUserService, UserService>();
        
        return services;
    }
}

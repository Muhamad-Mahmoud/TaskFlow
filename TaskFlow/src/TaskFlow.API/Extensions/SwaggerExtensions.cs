using Microsoft.Extensions.DependencyInjection;
using Microsoft.OpenApi.Models;

namespace TaskFlow.API.Extensions;

public static class SwaggerExtensions
{
	public static IServiceCollection AddSwaggerDocumentation(this IServiceCollection services)
	{
		services.AddSwaggerGen(c =>
		{
			c.SwaggerDoc("v1", new OpenApiInfo
			{
				Title = "TaskFlow API",
				Version = "v1",
				Description = "Collaborative task management backend."
			});

			c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
			{
				Description = "JWT Authorization header using the Bearer scheme. Example: \"Authorization: Bearer {token}\"",
				Name = "Authorization",
				In = ParameterLocation.Header,
				Type = SecuritySchemeType.ApiKey,
				Scheme = "Bearer"
			});

			c.AddSecurityRequirement(new OpenApiSecurityRequirement
			{
				{
					new OpenApiSecurityScheme
					{
						Reference = new OpenApiReference
						{
							Type = ReferenceType.SecurityScheme,
							Id = "Bearer"
						},
						Scheme = "Bearer",
						Name = "Bearer",
						In = ParameterLocation.Header
					},
					new List<string>()
				}
			});
		});

		return services;
	}
}

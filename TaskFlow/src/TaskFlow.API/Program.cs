using TaskFlow.API.Extensions;
using TaskFlow.API.Middleware;
using TaskFlow.Application;
using TaskFlow.Infrastructure;
using Microsoft.EntityFrameworkCore;
using TaskFlow.Infrastructure.Persistence;

// Fix for Npgsql 6+: allow DateTime with Kind=Unspecified (from JSON / date pickers)
AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", true);

var builder = WebApplication.CreateBuilder(args);

// Add layers
builder.Services.AddApplication();
builder.Services.AddInfrastructure(builder.Configuration);

// Add API services
builder.Services.AddJwtAuthentication(builder.Configuration);
builder.Services.AddSwaggerDocumentation();
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        builder =>
        {
            builder.AllowAnyOrigin()
                   .AllowAnyMethod()
                   .AllowAnyHeader();
        });
});

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.UseMiddleware<ExceptionHandlingMiddleware>();

app.UseHttpsRedirection();

app.UseCors("AllowAll");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

// Auto migration
try
{
    using (var scope = app.Services.CreateScope())
    {
        var dbContext = scope.ServiceProvider.GetRequiredService<TaskFlow.Infrastructure.Persistence.TaskFlowDbContext>();
        dbContext.Database.Migrate();
    }
}
catch (Exception ex)
{
    Console.WriteLine($"Migration failed: {ex.Message}");
}

app.Run();

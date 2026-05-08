// using Microsoft.EntityFrameworkCore;
// using Microsoft.Extensions.Configuration;
// using TaskFlow.Application.Common.Interfaces;
// using TaskFlow.Infrastructure.Persistence;

// namespace TaskFlow.Infrastructure.Services;

// public class FcmPushNotificationService : IPushNotificationService
// {
// 	private readonly TaskFlowDbContext _db;
// 	private static readonly object _gate = new();

// 	public FcmPushNotificationService(TaskFlowDbContext db, IConfiguration cfg)
// 	{
// 		_db = db;
// 		lock (_gate)
// 		{
// 			if (FirebaseApp.DefaultInstance is null)
// 				FirebaseApp.Create(new AppOptions
// 				{ Credential = GoogleCredential.FromFile(cfg["Fcm:ServiceAccountJsonPath"]!) });
// 		}
// 	}

// 	public async Task SendToUserAsync(Guid userId, string title, string body,
// 		IDictionary<string, string>? data = null, CancellationToken ct = default)
// 	{
// 		var tokens = await _db.PushTokens.Where(t => t.UserId == userId)
// 										  .Select(t => t.Token).ToListAsync(ct);
// 		if (tokens.Count == 0) return;

// 		var message = new MulticastMessage
// 		{
// 			Tokens = tokens,
// 			Notification = new FirebaseAdmin.Messaging.Notification { Title = title, Body = body },
// 			Data = data?.ToDictionary(x => x.Key, x => x.Value)
// 		};
// 		await FirebaseMessaging.DefaultInstance.SendEachForMulticastAsync(message, ct);
// 	}
// }

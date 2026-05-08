using System.Net;
using System.Net.Mail;
using Microsoft.Extensions.Configuration;
using TaskFlow.Application.Common.Interfaces;

namespace TaskFlow.Infrastructure.Services;

public class EmailService : IEmailService
{
	private readonly IConfiguration _cfg;
	public EmailService(IConfiguration cfg) { _cfg = cfg; }

	public async Task SendAsync(string to, string subject, string htmlBody, CancellationToken ct = default)
	{
		var host = _cfg["Smtp:Host"]!; var port = int.Parse(_cfg["Smtp:Port"] ?? "587");
		var user = _cfg["Smtp:User"]!; var pass = _cfg["Smtp:Password"]!;
		var from = _cfg["Smtp:From"] ?? user;

		using var client = new SmtpClient(host, port)
		{ Credentials = new NetworkCredential(user, pass), EnableSsl = true };

		using var msg = new MailMessage(from, to, subject, htmlBody) { IsBodyHtml = true };
		await client.SendMailAsync(msg, ct);
	}
}

using System.Net.Http.Headers;
using Microsoft.Extensions.Configuration;
using TaskFlow.Application.Common.Interfaces;

namespace TaskFlow.Infrastructure.Services;

public class FileStorageService : IFileStorageService
{
	private readonly HttpClient _http;
	private readonly string _bucket;
	private readonly string _baseUrl;
	private readonly string _apiKey;

	public FileStorageService(HttpClient http, IConfiguration cfg)
	{
		_http = http;
		_bucket = cfg["Storage:Bucket"] ?? string.Empty;
		_baseUrl = (cfg["Storage:Endpoint"] ?? string.Empty).TrimEnd('/');
		_apiKey = cfg["Storage:ApiKey"] ?? string.Empty;
	}

	public async Task<(string Url, string FileName, string MimeType, long Size)> UploadAsync(
		Stream stream, string fileName, string contentType, CancellationToken ct = default)
	{
		var safeName = $"{Guid.NewGuid()}_{Path.GetFileName(fileName)}";
		var uploadUrl = $"{_baseUrl}/object/{_bucket}/{safeName}";

		using var content = new StreamContent(stream);
		content.Headers.ContentType = new MediaTypeHeaderValue(contentType);

		using var req = new HttpRequestMessage(HttpMethod.Post, uploadUrl) { Content = content };
		req.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _apiKey);

		var resp = await _http.SendAsync(req, ct);
		resp.EnsureSuccessStatusCode();

		var publicUrl = $"{_baseUrl}/object/public/{_bucket}/{safeName}";
		return (publicUrl, safeName, contentType, stream.Length);
	}

	public async Task DeleteAsync(string url, CancellationToken ct = default)
	{
		var key = url.Split($"/{_bucket}/").Last();
		using var req = new HttpRequestMessage(HttpMethod.Delete, $"{_baseUrl}/object/{_bucket}/{key}");
		req.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _apiKey);
		(await _http.SendAsync(req, ct)).EnsureSuccessStatusCode();
	}
}

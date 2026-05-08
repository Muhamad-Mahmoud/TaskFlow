class AppConfig {
  final String baseUrl;
  final bool enableLogs;

  const AppConfig({
    required this.baseUrl,
    required this.enableLogs,
  });

  factory AppConfig.dev() {
    return const AppConfig(
      baseUrl: 'http://localhost:5299', // Updated to user's local API
      enableLogs: true,
    );
  }

  factory AppConfig.prod() {
    return const AppConfig(
      baseUrl: 'https://api.taskflow.com',
      enableLogs: false,
    );
  }
}


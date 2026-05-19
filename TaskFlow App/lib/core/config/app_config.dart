class AppConfig {
  final String baseUrl;
  final bool enableLogs;

  const AppConfig({
    required this.baseUrl,
    required this.enableLogs,
  });

  factory AppConfig.dev() {
    return const AppConfig(
      baseUrl: 'https://task-flowapi.runasp.net',
      enableLogs: true,
    );
  }

  factory AppConfig.prod() {
    return const AppConfig(
      baseUrl: 'https://task-flowapi.runasp.net',
      enableLogs: true,
    );
  }
}


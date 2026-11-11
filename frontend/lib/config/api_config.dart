class ApiConfig {
  // Para Flutter Web local: http://localhost:8080
  // Para emulador Android: http://10.0.2.2:8080
  // Também é possível informar em tempo de execução:
  // flutter run -d chrome --dart-define=API_URL=http://.../
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8080',
  );
}

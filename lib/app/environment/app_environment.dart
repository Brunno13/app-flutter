enum AppEnvironment {
  production,
  staging;

  static AppEnvironment fromFlavor(String? flavor) {
    return switch (flavor) {
      'production' => AppEnvironment.production,
      'staging' => AppEnvironment.staging,
      _ => throw StateError('Unsupported or missing Flutter flavor: $flavor'),
    };
  }
}

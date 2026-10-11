import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    required this.isDarkMode,
    required this.onDarkModeChanged,
    super.key,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Foundation ready'),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Dark theme'),
              subtitle: Text(
                isDarkMode ? 'Dark mode enabled' : 'Light mode enabled',
              ),
              secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
              value: isDarkMode,
              onChanged: onDarkModeChanged,
            ),
          ],
        ),
      ),
    );
  }
}

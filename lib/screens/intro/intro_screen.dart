import 'package:flutter/material.dart';
import '../../core/constants.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  void _goToSignup(BuildContext context, String role) {
    Navigator.pushNamed(context, '/signup', arguments: role);
  }

  void _goToLogin(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('FaithConnect')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppConstants.appName,
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              AppConstants.tagline,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _goToSignup(context, 'worshiper'),
                child: const Text('Continue as Worshiper'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _goToSignup(context, 'leader'),
                child: const Text('Continue as Religious Leader'),
              ),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => _goToLogin(context),
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/intro/intro_screen.dart';
import '../screens/leader/dashboard_screen.dart';
import '../screens/worshiper/home_screen.dart';
import '../services/auth_service.dart';

/// Root gate that decides what to show based on:
/// - Auth state
/// - User role (leader / worshiper)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // 1. Waiting for Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Not logged in -> Intro
        if (!snapshot.hasData) {
          return const IntroScreen();
        }

        // 3. Logged in -> load role
        final user = snapshot.data!;
        return FutureBuilder<String>(
          future: authService.getUserRole(user.uid),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snap.hasData) {
              return const Scaffold(
                body: Center(child: Text('Unable to load user role')),
              );
            }

            final role = snap.data;
            if (role == 'leader') {
              return const DashboardScreen();
            } else {
              return const HomeScreen();
            }
          },
        );
      },
    );
  }
}
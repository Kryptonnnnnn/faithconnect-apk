import 'package:flutter/material.dart';

import 'core/auth_gate.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/leader/create_post_screen.dart';
import 'screens/leader/create_reel_screen.dart';
import 'screens/leader/dashboard_screen.dart';
import 'screens/leader/messages_screen.dart';
import 'screens/worshiper/home_screen.dart';
import 'screens/worshiper/leaders_list_screen.dart';
import 'screens/worshiper/my_leaders_screen.dart';
import 'screens/worshiper/leader_profile_screen.dart';
import 'screens/chat/chat_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const AuthGate());

      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/signup':
        final role = settings.arguments as String? ?? 'worshiper';
        return MaterialPageRoute(
          builder: (_) => SignupScreen(role: role),
        );

      case '/leaderDashboard':
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case '/worshiperHome':
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case '/createPost':
        return MaterialPageRoute(builder: (_) => const CreatePostScreen());

      case '/createReel':
        return MaterialPageRoute(builder: (_) => const CreateReelScreen());

      case '/leaders':
        return MaterialPageRoute(builder: (_) => const LeadersListScreen());

      case '/myLeaders':
        return MaterialPageRoute(builder: (_) => const MyLeadersScreen());

      case '/leaderProfile':
        final leaderId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => LeaderProfileScreen(leaderId: leaderId),
        );

      case '/messages':
        return MaterialPageRoute(builder: (_) => const MessagesScreen());

      case '/chat':
        final otherUserId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(otherUserId: otherUserId),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('404 - Page not found')),
          ),
        );
    }
  }
}
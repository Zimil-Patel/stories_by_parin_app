import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show WatchContext;
import 'package:stories_by_parin/screens/auth%20screen/login_screen.dart';
import 'package:stories_by_parin/screens/dashboard%20screen/dashboard_screen.dart';
import 'package:stories_by_parin/screens/project%20screen/project_screen.dart';
import 'package:stories_by_parin/widgets/app_background.dart';

import '../../providers/auth_provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {

    final authProvider = context.watch<AuthProvider>();

    if(authProvider.isInitializing) {
      return Scaffold(
        body: AppBackground(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if(authProvider.isLoggedIn){
      return DashboardScreen();
    }

    return LoginScreen();
  }
}

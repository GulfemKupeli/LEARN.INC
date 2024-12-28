import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:learn_inc/screens/user_screen.dart';
import 'package:learn_inc/screens/welcome_screen.dart';
import 'package:learn_inc/screens/login_screen.dart';
import 'package:learn_inc/screens/registration_screen.dart';
import 'package:learn_inc/screens/dashboards/dashboard_screen.dart';

import 'package:learn_inc/providers/user_provider.dart';

import 'firebase_options.dart'; // Import Firebase configuration file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final userProvider = UserProvider();
            if (user != null) {
              userProvider.loadUserData(user.uid);
            }
            return userProvider;
          },
        ),
      ],
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          // Use MaterialApp at all times to ensure Directionality is available.
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: _buildHome(userProvider, user),
            initialRoute: '/',
            routes: {
              '/login': (context) => LoginScreen(),
              '/register': (context) => RegistrationScreen(),
              '/dashboard_screen': (context) =>
                  DashboardScreen(role: userProvider.user?.role ?? 'member'),
              '/settings': (context) => UserScreen(),
            },
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  body: Center(
                    child: Text('Route ${settings.name} not found!'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper method to decide the home widget.
  Widget _buildHome(UserProvider userProvider, User? user) {
    if (userProvider.user == null && user != null) {
      // Show a loading state while user data is being fetched
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Check user's role or authentication state
    final role = userProvider.user?.role ?? 'member';
    return user == null ? WelcomeScreen() : DashboardScreen(role: role);
  }
}
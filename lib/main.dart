import 'package:finspere_calculator/Screens/Admin%20Section/admin-panel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Screens/Login-Signin/login-screen.dart';
import 'Screens/finanace-dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // The StreamBuilder listens to Firebase.
      // If a user is logged in, snapshot.hasData will be true.
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. If Firebase is still checking the connection
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: Color(0xFF00D09C))),
            );
          }

          // 2. If a user is already logged in, go straight to Dashboard
          if (snapshot.hasData) {
            return const FinanceDashboard();
          }

          // 3. If no user is logged in, show the Login Screen
          return const LoginScreen();
        },
      ),
    );
  }
}
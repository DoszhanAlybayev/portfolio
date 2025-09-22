import 'package:finnapp/screens/login_page.dart';
import 'package:finnapp/screens/portfolio_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Пока идёт проверка
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Если юзер авторизован → HomePage
        if (snapshot.hasData) {
          return const PortfolioScreen();
        }
        // Если нет → LoginPage
        return const LoginPage();
      },
    );
  }
}

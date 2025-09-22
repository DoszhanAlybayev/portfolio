import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final emailController = TextEditingController();
  final auth = FirebaseAuth.instance;

  Future<void> resetPassword() async {
    try {
      await auth.sendPasswordResetEmail(email: emailController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📩 Письмо для сброса отправлено")),
      );

      Navigator.pop(context); // вернуться на LoginPage
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Ошибка: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Восстановить пароль")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Введите Email"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: resetPassword,
              child: const Text("Сбросить пароль"),
            ),
          ],
        ),
      ),
    );
  }
}

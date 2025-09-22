import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  Future<void> register() async {
    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Пароли не совпадают")),
      );
      return;
    }

    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Создаем документ пользователя в Firestore
      final uid = userCredential.user!.uid;
      await firestore.collection('users').doc(uid).set({
        'email': emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Аккаунт создан")),
      );

      Navigator.pop(context); // возвращаемся на LoginPage
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Ошибка: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Регистрация")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Пароль"),
            ),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Подтвердите пароль"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: register,
              child: const Text("Зарегистрироваться"),
            ),
          ],
        ),
      ),
    );
  }
}

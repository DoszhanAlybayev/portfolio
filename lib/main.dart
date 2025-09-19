import 'package:flutter/material.dart';
import 'screens/portfolio_screen.dart';

void main() {
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
        return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Портфель',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: PortfolioScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const CodeMentorApp());
}

class CodeMentorApp extends StatelessWidget {
  const CodeMentorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodeMentor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(
          0xFFF7F9FC,
        ), // background-secondary
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo)
            .copyWith(
              secondary: const Color(0xFF059669), // success green
            ),
        fontFamily: 'Roboto', // Default sans-serif look
      ),
      home: const LoginScreen(),
    );
  }
}

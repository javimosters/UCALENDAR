import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Asegúrate de que la ruta sea correcta

void main() {
  runApp(const UniCalendarApp());
}

class UniCalendarApp extends StatelessWidget {
  const UniCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Quita la etiqueta DEBUG
      title: 'UniCalendar',
      theme: ThemeData(
        primaryColor: const Color(0xFF145DA0),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF145DA0)),
        useMaterial3: true,
      ),
      home: const LoginScreen(), // Aquí inicia con tu login
    );
  }
}
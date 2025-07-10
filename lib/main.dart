import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SoloLevelingWorkoutApp());
}

class SoloLevelingWorkoutApp extends StatelessWidget {
  const SoloLevelingWorkoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solo Leveling Workout',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Tema oscuro base
        brightness: Brightness.dark,

        // Fuente principal estilo Solo Leveling
        fontFamily: GoogleFonts.inter().fontFamily,

        // Colores primarios estilo Solo Leveling
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1a1a2e), // Azul muy oscuro
        // Esquema de colores personalizado
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4f46e5), // Azul eléctrico/morado
          secondary: Color(0xFF06b6d4), // Cian
          surface: Color(0xFF16213e), // Negro azulado
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
        ),

        // Tema del AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1a1a2e),
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        // Tema de las cards
        cardTheme: const CardTheme(
          color: Color(0xFF16213e),
          elevation: 8,
          margin: EdgeInsets.all(8),
        ),

        // Tema de los botones elevados
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4f46e5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

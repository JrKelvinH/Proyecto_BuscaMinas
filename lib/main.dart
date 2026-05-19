import 'package:flutter/material.dart';
import 'screens/game_screen.dart'; // Importas tu pantalla de juego

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buscaminas Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark, // Puedes probar el tema oscuro por defecto
        primarySwatch: Colors.blueGrey,
      ),
      home: const GameScreen(
        rows: 8,   // Configuración intermedia inicial
        cols: 8,
        mines: 20,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'screens/game_screen.dart';

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
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
      ),
      home: const MenuScreen(),
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  void _goToGame(BuildContext context, int rows, int cols, int mines) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(rows: rows, cols: cols, mines: mines),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscaminas Clásico'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.brightness_7, size: 80, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Selecciona Dificultad',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              
              _buildMenuButton(
                context: context,
                label: 'FÁCIL (8x8 - 10 Minas)',
                color: Colors.green,
                onPressed: () => _goToGame(context, 8, 8, 10),
              ),
              const SizedBox(height: 16),
              
              _buildMenuButton(
                context: context,
                label: 'MEDIO (12x12 - 25 Minas)',
                color: Colors.orange,
                onPressed: () => _goToGame(context, 12, 12, 25),
              ),
              const SizedBox(height: 16),
              
              _buildMenuButton(
                context: context,
                label: 'DIFÍCIL (16x16 - 40 Minas)',
                color: Colors.red,
                onPressed: () => _goToGame(context, 16, 16, 40),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 280,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.2),
          side: BorderSide(color: color, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

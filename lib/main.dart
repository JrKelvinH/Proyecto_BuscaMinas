import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  Map<String, Map<String, dynamic>> highScores = {};

  @override
  void initState() {
    super.initState();
    _loadHighScores(); 
  }

  Future<void> _loadHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    final difficulties = ['facil', 'medio', 'dificil'];
    Map<String, Map<String, dynamic>> loadedScores = {};

    for (var diff in difficulties) {
      final String? jsonString = prefs.getString('high_score_$diff');
      if (jsonString != null) {
        try {
          loadedScores[diff] = jsonDecode(jsonString);
        } catch (e) {
          // Evita caídas si el JSON está vacío o dañado
        }
      }
    }

    setState(() {
      highScores = loadedScores;
    });
  }

  void _goToGame(BuildContext context, int rows, int cols, int mines, String diffName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(rows: rows, cols: cols, mines: mines, difficultyName: diffName),
      ),
    ).then((_) => _loadHighScores()); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscaminas Clásico'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.workspace_premium, size: 70, color: Colors.amber),
                const SizedBox(height: 8),
                const Text(
                  'Selecciona Dificultad',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                
                _buildMenuSection('facil', 'FÁCIL (8x8 - 10 Minas)', Colors.green, () => _goToGame(context, 8, 8, 10, 'facil')),
                const SizedBox(height: 20),
                _buildMenuSection('medio', 'MEDIO (12x12 - 25 Minas)', Colors.orange, () => _goToGame(context, 12, 12, 25, 'medio')),
                const SizedBox(height: 20),
                _buildMenuSection('dificil', 'DIFÍCIL (16x16 - 40 Minas)', Colors.red, () => _goToGame(context, 16, 16, 40, 'dificil')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(String key, String title, Color color, VoidCallback onTap) {
    final score = highScores[key];

    return Container(
      width: 310,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color.withOpacity(0.15),
              side: BorderSide(color: color, width: 1.5),
              minimumSize: const Size(280, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: onTap,
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(height: 8),
          if (score != null) ...[
            Text(
              '⏱️ Récord: ${score['bestTime']}s  |  🎯 Intentos: ${score['fewestAttempts']}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade300, fontWeight: FontWeight.w500),
            ),
            Text(
              '📅 Fecha: ${score['date']}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ] else
            const Text(
              'Sin récords guardados aún',
              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }
}


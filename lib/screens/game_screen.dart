import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../logic/minesweeper_engine.dart';

class GameScreen extends StatefulWidget {
  final int rows;
  final int cols;
  final int mines;
  final String difficultyName;

  const GameScreen({
    super.key, 
    required this.rows,  
    required this.cols, 
    required this.mines,
    required this.difficultyName,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late MinesweeperEngine game;
  Timer? _timer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsElapsed = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!game.isGameOver && !game.isWon && !game.isFirstMove) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  void _startNewGame() {
    setState(() {
      game = MinesweeperEngine(
        rows: widget.rows,
        cols: widget.cols,
        totalMines: widget.mines,
      );
      _secondsElapsed = 0;
    });
    _startTimer();
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    final String key = 'high_score_${widget.difficultyName}';
    final String? cachedData = prefs.getString(key);
    bool shouldUpdate = false;

    final newScore = {
      'bestTime': _secondsElapsed,
      'fewestAttempts': game.attempts,
      'date': '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'
    };

    if (cachedData != null) {
      try {
        final Map<String, dynamic> oldScore = jsonDecode(cachedData);
        if (_secondsElapsed < oldScore['bestTime'] || game.attempts < oldScore['fewestAttempts']) {
          shouldUpdate = true;
        }
      } catch (e) {
        shouldUpdate = true;
      }
    } else {
      shouldUpdate = true;
    }

    if (shouldUpdate) {
      await prefs.setString(key, jsonEncode(newScore));
    }
  }

  void _handleCellTap(int r, int c) {
    if (game.isGameOver || game.isWon) return;

    setState(() {
      game.revealCell(r, c);
    });

    if (game.isWon) {
      _timer?.cancel();
      _saveHighScore(); 
    } else if (game.isGameOver) {
      _timer?.cancel();
    }
  }

  Color _getNumberColor(int number) {
    switch (number) {
      case 1: return Colors.blue;
      case 2: return Colors.green;
      case 3: return Colors.red;
      case 4: return Colors.purple;
      case 5: return Colors.brown;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tablero ${widget.rows}x${widget.cols}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), 
          tooltip: 'Volver al menú',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startNewGame,
            tooltip: 'Reiniciar partida',
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Minas: ${widget.mines}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '⏱️ Tiempo: ${_secondsElapsed}s',
                    style: const TextStyle(fontSize: 16, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '🎯 Intentos: ${game.attempts}',
                    style: const TextStyle(fontSize: 16, color: Colors.amber, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Center(
                child: game.isWon
                    ? const Text('¡GANASTE! 🎉', style: TextStyle(color: Colors.green, fontSize: 22, fontWeight: FontWeight.bold))
                    : game.isGameOver
                        ? const Text('GAME OVER 💥', style: TextStyle(color: Colors.red, fontSize: 22, fontWeight: FontWeight.bold))
                        : const Text('En juego 🎮', style: TextStyle(fontSize: 16, color: Colors.grey)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double cellSize = (constraints.maxWidth / game.cols) < (constraints.maxHeight / game.rows)
                        ? (constraints.maxWidth / game.cols)
                        : (constraints.maxHeight / game.rows);

                    return Center(
                      child: SizedBox(
                        width: cellSize * game.cols,
                        height: cellSize * game.rows,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(game.rows, (r) {
                            return Expanded(
                              child: Row(
                                children: List.generate(game.cols, (c) {
                                  BoardCell cell = game.board[r][c];

                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () => _handleCellTap(r, c),
                                      onLongPress: () {
                                        setState(() {
                                          game.toggleFlag(r, c);
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 150),
                                        margin: const EdgeInsets.all(1.5),
                                        decoration: BoxDecoration(
                                          color: cell.state == CellState.revealed
                                              ? (cell.isMine ? Colors.red.shade300 : Colors.grey.shade300)
                                              : Colors.blueGrey.shade700,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Center(
                                          child: _buildCellContent(cell),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            );
                          }),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCellContent(BoardCell cell) {
    if (cell.state == CellState.flagged) {
      return const Icon(Icons.flag, color: Colors.orange, size: 16);
    }
    
    if (cell.state == CellState.revealed) {
      if (cell.isMine) {
        return const Icon(Icons.brightness_7, color: Colors.black, size: 16);
      }
      if (cell.adjacentMines > 0) {
        return Text(
          '${cell.adjacentMines}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: _getNumberColor(cell.adjacentMines),
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }
}


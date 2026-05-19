import 'package:flutter/material.dart';
import '../logic/minesweeper_engine.dart';

class GameScreen extends StatefulWidget {
  final int rows;
  final int cols;
  final int mines;

  const GameScreen({
    super.key, 
    required this.rows,  
    required this.cols, 
    required this.mines,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Se mantiene el late por el que consultabas, pero inicializado correctamente
  late MinesweeperEngine game;

  @override
  void initState() {
    super.initState();
    // Inicialización directa en el nacimiento para evitar bloqueos Web
    game = MinesweeperEngine(
      rows: widget.rows,
      cols: widget.cols,
      totalMines: widget.mines,
    );
  }

  void _startNewGame() {
    setState(() {
      game = MinesweeperEngine(
        rows: widget.rows,
        cols: widget.cols,
        totalMines: widget.mines,
      );
    });
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
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (game.isWon)
                    const Text('¡GANASTE! 🎉', style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold))
                  else if (game.isGameOver)
                    const Text('GAME OVER 💥', style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold))
                  else
                    const Text('En juego 🎮', style: TextStyle(fontSize: 18)),
                ],
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
                                      onTap: () {
                                        setState(() {
                                          game.revealCell(r, c);
                                        });
                                      },
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

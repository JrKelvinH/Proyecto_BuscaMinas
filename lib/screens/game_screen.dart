import 'package:flutter/material.dart';
import '../logic/minesweeper_engine.dart';


class GameScreen extends StatefulWidget {
  final int rows;
  final int cols;
  final int mines;

  const GameScreen({
    super.key, 
    this.rows = 8,  // Configuración "Medio" por defecto
    this.cols = 8, 
    this.mines = 20,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late MinesweeperEngine game;

  @override
  void initState() {
    super.initState() {
      _startNewGame();
    }
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

  // Retorna el color del número basado en el estilo Clásico exigido
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
        title: const Text('Buscaminas - Modo Juego'),
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
            // Panel de Estado Superior
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
            
            // Tablero Adaptable (Responsive)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calcula el tamaño máximo que puede tener cada celda de forma proporcional
                    final double cellSize = (constraints.maxWidth / game.cols) < (constraints.maxHeight / game.rows)
                        ? (constraints.maxWidth / game.cols)
                        : (constraints.maxHeight / game.rows);

                    return Center(
                      child: SizedBox(
                        width: cellSize * game.cols,
                        height: cellSize * game.rows,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: game.rows * game.cols,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: game.cols,
                          ),
                          itemBuilder: (context, index) {
                            int r = index ~/ game.cols;
                            int c = index % game.cols;
                            BoardCell cell = game.board[r][c];

                            return GestureDetector(
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
                                duration: const Duration(milliseconds: 200), // Animación sutil de revelado
                                margin: const EdgeInsets.all(1.0),
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
                          },
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
      return const Icon(Icons.flag, color: Colors.orange, size: 18);
    }
    
    if (cell.state == CellState.revealed) {
      if (cell.isMine) {
        return const Icon(Icons.brightness_7, color: Colors.black, size: 18); // Representación de Mina
      }
      if (cell.adjacentMines > 0) {
        return Text(
          '${cell.adjacentMines}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getNumberColor(cell.adjacentMines),
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }
}
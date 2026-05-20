import 'dart:math';

enum CellState { hidden, revealed, flagged }

class BoardCell {
  final int row;
  final int col;
  bool isMine;
  int adjacentMines;
  CellState state;

  BoardCell({
    required this.row,
    required this.col,
    this.isMine = false,
    this.adjacentMines = 0,
    this.state = CellState.hidden,
  });
}

class MinesweeperEngine {
  final int rows;
  final int cols;
  final int totalMines;
  
  late List<List<BoardCell>> board;
  bool isFirstMove = true;
  bool isGameOver = false;
  bool isWon = false;
  int attempts = 0; 

  MinesweeperEngine({
    required this.rows,
    required this.cols,
    required this.totalMines,
  }) {
    _initializeBoard();
  }

  void _initializeBoard() {
    board = List.generate(
      rows,
      (r) => List.generate(cols, (c) => BoardCell(row: r, col: c)),
    );
    isFirstMove = true;
    isGameOver = false;
    isWon = false;
    attempts = 0;
  }

  void _generateMines(int startRow, int startCol) {
    final random = Random();
    int minesPlaced = 0;

    while (minesPlaced < totalMines) {
      int r = random.nextInt(rows);
      int c = random.nextInt(cols);

      if ((r == startRow && c == startCol) || board[r][c].isMine) {
        continue;
      }

      board[r][c].isMine = true;
      minesPlaced++;
    }

    _calculateAdjacentMines();
  }

  void _calculateAdjacentMines() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (board[r][c].isMine) continue;

        int count = 0;
        for (int i = -1; i <= 1; i++) {
          for (int j = -1; j <= 1; j++) {
            int nr = r + i;
            int nc = c + j;
            if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) {
              if (board[nr][nc].isMine) count++;
            }
          }
        }
        board[r][c].adjacentMines = count;
      }
    }
  }

  void revealCell(int r, int c) {
    if (isGameOver || isWon || board[r][c].state != CellState.hidden) return;

    attempts++; 

    if (isFirstMove) {
      isFirstMove = false;
      _generateMines(r, c);
    }

    if (board[r][c].isMine) {
      _revealAllMines();
      isGameOver = true;
      return;
    }

    _floodFill(r, c);
    _checkVictory();
  }

  void _floodFill(int r, int c) {
    if (r < 0 || r >= rows || c < 0 || c >= cols) return;
    if (board[r][c].state != CellState.hidden || board[r][c].isMine) return;

    board[r][c].state = CellState.revealed;

    if (board[r][c].adjacentMines == 0) {
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          _floodFill(r + i, c + j);
        }
      }
    }
  }

  void toggleFlag(int r, int c) {
    if (isGameOver || isWon || board[r][c].state == CellState.revealed) return;

    if (board[r][c].state == CellState.hidden) {
      board[r][c].state = CellState.flagged;
    } else if (board[r][c].state == CellState.flagged) {
      board[r][c].state = CellState.hidden;
    }
  }

  void _revealAllMines() {
    for (var row in board) {
      for (var cell in row) {
        if (cell.isMine) {
          cell.state = CellState.revealed;
        }
      }
    }
  }

  void _checkVictory() {
    bool won = true;
    for (var row in board) {
      for (var cell in row) {
        if (!cell.isMine && cell.state != CellState.revealed) {
          won = false;
          break;
        }
      }
    }
    if (won) {
      isWon = true;
    }
  }
}

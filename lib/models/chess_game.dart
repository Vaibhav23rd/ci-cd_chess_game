import 'package:chess/models/piece.dart';
import 'package:chess/helper/helper_methods.dart';
import 'package:flutter/material.dart';
import '../values/constants.dart';


class ChessGame {
  List<List<ChessPiece?>> board;
  ChessPiece? selectedPiece;
  int selectedRow = -1;
  int selectedColumn = -1;
  List<List<int>> validMoves = [];
  List<ChessPiece> whitePiecesTaken = [];
  List<ChessPiece> blackPiecesTaken = [];
  bool isWhiteTurn = true;
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;
  bool whiteKingMoved = false;
  bool blackKingMoved = false;
  Map<int, bool> whiteRooksMoved = {0: false, 7: false};
  Map<int, bool> blackRooksMoved = {0: false, 7: false};
  List<int>? lastDoublePawnMove;

  ChessGame() : board = List.generate(8, (_) => List.generate(8, (_) => null)) {
    _initializeBoard();
  }

  void _initializeBoard() {
    // Place pawns
    for (int i = 0; i < 8; i++) {
      board[1][i] = ChessPiece(
        type: PieceType.pawn,
        color: PieceColor.black,
        imagePath: blackPieceImages[PieceType.pawn]!,
      );
      board[6][i] = ChessPiece(
        type: PieceType.pawn,
        color: PieceColor.white,
        imagePath: whitePieceImages[PieceType.pawn]!,
      );
    }

    // Place rooks
    board[0][0] = ChessPiece(type: PieceType.rook, color: PieceColor.black, imagePath: blackPieceImages[PieceType.rook]!);
    board[0][7] = ChessPiece(type: PieceType.rook, color: PieceColor.black, imagePath: blackPieceImages[PieceType.rook]!);
    board[7][0] = ChessPiece(type: PieceType.rook, color: PieceColor.white, imagePath: whitePieceImages[PieceType.rook]!);
    board[7][7] = ChessPiece(type: PieceType.rook, color: PieceColor.white, imagePath: whitePieceImages[PieceType.rook]!);

    // Place knights
    board[0][1] = ChessPiece(type: PieceType.knight, color: PieceColor.black, imagePath: blackPieceImages[PieceType.knight]!);
    board[0][6] = ChessPiece(type: PieceType.knight, color: PieceColor.black, imagePath: blackPieceImages[PieceType.knight]!);
    board[7][1] = ChessPiece(type: PieceType.knight, color: PieceColor.white, imagePath: whitePieceImages[PieceType.knight]!);
    board[7][6] = ChessPiece(type: PieceType.knight, color: PieceColor.white, imagePath: whitePieceImages[PieceType.knight]!);

    // Place bishops
    board[0][2] = ChessPiece(type: PieceType.bishop, color: PieceColor.black, imagePath: blackPieceImages[PieceType.bishop]!);
    board[0][5] = ChessPiece(type: PieceType.bishop, color: PieceColor.black, imagePath: blackPieceImages[PieceType.bishop]!);
    board[7][2] = ChessPiece(type: PieceType.bishop, color: PieceColor.white, imagePath: whitePieceImages[PieceType.bishop]!);
    board[7][5] = ChessPiece(type: PieceType.bishop, color: PieceColor.white, imagePath: whitePieceImages[PieceType.bishop]!);

    // Place queens
    board[0][3] = ChessPiece(type: PieceType.queen, color: PieceColor.black, imagePath: blackPieceImages[PieceType.queen]!);
    board[7][3] = ChessPiece(type: PieceType.queen, color: PieceColor.white, imagePath: whitePieceImages[PieceType.queen]!);

    // Place kings
    board[0][4] = ChessPiece(type: PieceType.king, color: PieceColor.black, imagePath: blackPieceImages[PieceType.king]!);
    board[7][4] = ChessPiece(type: PieceType.king, color: PieceColor.white, imagePath: whitePieceImages[PieceType.king]!);
  }

  void pieceSelected(int row, int col, BuildContext context) {
    if (selectedPiece == null && board[row][col] != null) {
      if (board[row][col]!.color == (isWhiteTurn ? PieceColor.white : PieceColor.black)) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedColumn = col;
      }
    } else if (board[row][col] != null && board[row][col]!.color == selectedPiece!.color) {
      selectedPiece = board[row][col];
      selectedRow = row;
      selectedColumn = col;
    } else if (selectedPiece != null && validMoves.any((move) => move[0] == row && move[1] == col)) {
      movePiece(row, col, context);
    }
    validMoves = calculateRealValidMoves(selectedRow, selectedColumn, selectedPiece, true);
  }

  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];
    if (piece == null) return [];

    int direction = piece.color == PieceColor.white ? -1 : 1;

    switch (piece.type) {
      case PieceType.pawn:
        if (isInBoard(row + direction, col) && board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }
        if ((row == 1 && piece.color == PieceColor.black) || (row == 6 && piece.color == PieceColor.white)) {
          if (isInBoard(row + 2 * direction, col) && board[row + 2 * direction][col] == null && board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }
        if (isInBoard(row + direction, col - 1) && board[row + direction][col - 1] != null && board[row + direction][col - 1]!.color != piece.color) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) && board[row + direction][col + 1] != null && board[row + direction][col + 1]!.color != piece.color) {
          candidateMoves.add([row + direction, col + 1]);
        }
        if (lastDoublePawnMove != null) {
          int pawnRow = lastDoublePawnMove![0];
          int pawnCol = lastDoublePawnMove![1];
          if ((row == 3 && piece.color == PieceColor.white) || (row == 4 && piece.color == PieceColor.black)) {
            if (pawnRow == row && (pawnCol == col - 1 || pawnCol == col + 1)) {
              candidateMoves.add([row + direction, pawnCol]);
            }
          }
        }
        break;
      case PieceType.rook:
        var directions = [
          [-1, 0], [1, 0], [0, -1], [0, 1]
        ];
        for (var dir in directions) {
          for (int i = 1; i < 8; i++) {
            var newRow = row + i * dir[0];
            var newCol = col + i * dir[1];
            if (!isInBoard(newRow, newCol)) break;
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.color != piece.color) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
          }
        }
        break;
      case PieceType.knight:
        var moves = [
          [-2, -1], [-2, 1], [-1, -2], [-1, 2],
          [1, -2], [1, 2], [2, -1], [2, 1]
        ];
        for (var move in moves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) continue;
          if (board[newRow][newCol] != null && board[newRow][newCol]!.color == piece.color) continue;
          candidateMoves.add([newRow, newCol]);
        }
        break;
      case PieceType.bishop:
        var directions = [
          [-1, -1], [-1, 1], [1, -1], [1, 1]
        ];
        for (var dir in directions) {
          for (int i = 1; i < 8; i++) {
            var newRow = row + i * dir[0];
            var newCol = col + i * dir[1];
            if (!isInBoard(newRow, newCol)) break;
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.color != piece.color) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
          }
        }
        break;
      case PieceType.queen:
        var directions = [
          [-1, 0], [1, 0], [0, -1], [0, 1],
          [-1, -1], [-1, 1], [1, -1], [1, 1]
        ];
        for (var dir in directions) {
          for (int i = 1; i < 8; i++) {
            var newRow = row + i * dir[0];
            var newCol = col + i * dir[1];
            if (!isInBoard(newRow, newCol)) break;
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.color != piece.color) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
          }
        }
        break;
      case PieceType.king:
        var directions = [
          [-1, 0], [1, 0], [0, -1], [0, 1],
          [-1, -1], [-1, 1], [1, -1], [1, 1]
        ];
        for (var dir in directions) {
          var newRow = row + dir[0];
          var newCol = col + dir[1];
          if (!isInBoard(newRow, newCol)) continue;
          if (board[newRow][newCol] != null && board[newRow][newCol]!.color == piece.color) continue;
          candidateMoves.add([newRow, newCol]);
        }
        if (piece.color == PieceColor.white && !whiteKingMoved && row == 7 && col == 4) {
          if (!whiteRooksMoved[7]! && board[7][5] == null && board[7][6] == null) {
            if (simulateMoveIsSafe(piece, row, col, 7, 5)) {
              candidateMoves.add([7, 5]);
            }
          }
          if (!whiteRooksMoved[0]! && board[7][1] == null && board[7][2] == null && board[7][3] == null) {
            if (simulateMoveIsSafe(piece, row, col, 7, 2)) {
              candidateMoves.add([7, 2]);
            }
          }
        } else if (piece.color == PieceColor.black && !blackKingMoved && row == 0 && col == 4) {
          if (!blackRooksMoved[7]! && board[0][5] == null && board[0][6] == null) {
            if (simulateMoveIsSafe(piece, row, col, 0, 5)) {
              candidateMoves.add([0, 5]);
            }
          }
          if (!blackRooksMoved[0]! && board[0][1] == null && board[0][2] == null && board[0][3] == null) {
            if (simulateMoveIsSafe(piece, row, col, 0, 2)) {
              candidateMoves.add([0, 2]);
            }
          }
        }
        break;
    }
    return candidateMoves;
  }

  List<List<int>> calculateRealValidMoves(int row, int col, ChessPiece? piece, bool checkSimulation) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);
    if (checkSimulation) {
      for (var move in candidateMoves) {
        if (simulateMoveIsSafe(piece!, row, col, move[0], move[1])) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = candidateMoves;
    }
    return realValidMoves;
  }

  void movePiece(int newRow, int newCol, BuildContext context) {
    bool isCastling = selectedPiece!.type == PieceType.king && (newCol - selectedColumn).abs() == 2;
    ChessPiece? capturedPiece = board[newRow][newCol];

    if (capturedPiece != null) {
      if (capturedPiece.color == PieceColor.white) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }

    if (selectedPiece!.type == PieceType.pawn && (newRow - selectedRow).abs() == 2) {
      lastDoublePawnMove = [newRow, newCol];
    } else {
      lastDoublePawnMove = null;
    }

    if (selectedPiece!.type == PieceType.pawn && lastDoublePawnMove != null &&
        newCol == lastDoublePawnMove![1] && newRow == lastDoublePawnMove![0] + (selectedPiece!.color == PieceColor.white ? 1 : -1)) {
      board[lastDoublePawnMove![0]][lastDoublePawnMove![1]] = null;
      if (selectedPiece!.color == PieceColor.white) {
        whitePiecesTaken.add(ChessPiece(type: PieceType.pawn, color: PieceColor.black, imagePath: blackPieceImages[PieceType.pawn]!));
      } else {
        blackPiecesTaken.add(ChessPiece(type: PieceType.pawn, color: PieceColor.white, imagePath: whitePieceImages[PieceType.pawn]!));
      }
    }

    if (selectedPiece!.type == PieceType.king) {
      if (selectedPiece!.color == PieceColor.white) {
        whiteKingPosition = [newRow, newCol];
        whiteKingMoved = true;
      } else {
        blackKingPosition = [newRow, newCol];
        blackKingMoved = true;
      }
      if (isCastling) {
        if (newCol == 6) {
          board[newRow][5] = board[newRow][7];
          board[newRow][7] = null;
          if (selectedPiece!.color == PieceColor.white) whiteRooksMoved[7] = true;
          else blackRooksMoved[7] = true;
        } else if (newCol == 2) {
          board[newRow][3] = board[newRow][0];
          board[newRow][0] = null;
          if (selectedPiece!.color == PieceColor.white) whiteRooksMoved[0] = true;
          else blackRooksMoved[0] = true;
        }
      }
    } else if (selectedPiece!.type == PieceType.rook) {
      if (selectedPiece!.color == PieceColor.white) {
        if (selectedRow == 7 && selectedColumn == 0) whiteRooksMoved[0] = true;
        else if (selectedRow == 7 && selectedColumn == 7) whiteRooksMoved[7] = true;
      } else {
        if (selectedRow == 0 && selectedColumn == 0) blackRooksMoved[0] = true;
        else if (selectedRow == 0 && selectedColumn == 7) blackRooksMoved[7] = true;
      }
    }

    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedColumn] = null;

    if (selectedPiece!.type == PieceType.pawn &&
        ((newRow == 0 && selectedPiece!.color == PieceColor.white) ||
            (newRow == 7 && selectedPiece!.color == PieceColor.black))) {
      _showPromotionDialog(context, newRow, newCol);
      return;
    }

    bool isWhiteKingInCheck = isKingInCheck(true);
    bool isBlackKingInCheck = isKingInCheck(false);
    bool hasMoves = hasValidMoves(!isWhiteTurn);

    if (isWhiteKingInCheck && !hasMoves) {
      checkStatus = true;
      _showGameOverDialog(context, "Black wins by checkmate!");
    } else if (isBlackKingInCheck && !hasMoves) {
      checkStatus = true;
      _showGameOverDialog(context, "White wins by checkmate!");
    } else if (!hasMoves) {
      _showGameOverDialog(context, "Stalemate!");
    } else {
      checkStatus = isWhiteKingInCheck || isBlackKingInCheck;
    }

    selectedPiece = null;
    selectedRow = -1;
    selectedColumn = -1;
    validMoves = [];
    isWhiteTurn = !isWhiteTurn;
  }

  bool isKingInCheck(bool isWhiteKing) {
    List<int> kingPosition = isWhiteKing ? whiteKingPosition : blackKingPosition;
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == null || board[i][j]!.color == (isWhiteKing ? PieceColor.white : PieceColor.black)) continue;
        List<List<int>> pieceValidMoves = calculateRealValidMoves(i, j, board[i][j], false);
        if (pieceValidMoves.any((move) => move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }
    return false;
  }

  bool simulateMoveIsSafe(ChessPiece piece, int startRow, int startCol, int endRow, int endCol) {
    ChessPiece? originalDestinationPiece = board[endRow][endCol];
    List<int>? originalKingPosition;
    if (piece.type == PieceType.king) {
      originalKingPosition = piece.color == PieceColor.white ? whiteKingPosition : blackKingPosition;
      if (piece.color == PieceColor.white) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;
    bool kingInCheck = isKingInCheck(piece.color == PieceColor.white);
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;
    if (piece.type == PieceType.king) {
      if (piece.color == PieceColor.white) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }
    return !kingInCheck;
  }

  bool hasValidMoves(bool isWhite) {
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] != null && board[i][j]!.color == (isWhite ? PieceColor.white : PieceColor.black)) {
          var moves = calculateRealValidMoves(i, j, board[i][j], true);
          if (moves.isNotEmpty) return true;
        }
      }
    }
    return false;
  }

  void _showPromotionDialog(BuildContext context, int row, int col) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Promote Pawn"),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () => _promotePawn(context, row, col, PieceType.queen),
              child: Image.asset(selectedPiece!.color == PieceColor.white ? whitePieceImages[PieceType.queen]! : blackPieceImages[PieceType.queen]!),
            ),
            GestureDetector(
              onTap: () => _promotePawn(context, row, col, PieceType.rook),
              child: Image.asset(selectedPiece!.color == PieceColor.white ? whitePieceImages[PieceType.rook]! : blackPieceImages[PieceType.rook]!),
            ),
            GestureDetector(
              onTap: () => _promotePawn(context, row, col, PieceType.knight),
              child: Image.asset(selectedPiece!.color == PieceColor.white ? whitePieceImages[PieceType.knight]! : blackPieceImages[PieceType.knight]!),
            ),
            GestureDetector(
              onTap: () => _promotePawn(context, row, col, PieceType.bishop),
              child: Image.asset(selectedPiece!.color == PieceColor.white ? whitePieceImages[PieceType.bishop]! : blackPieceImages[PieceType.bishop]!),
            ),
          ],
        ),
      ),
    );
  }

  void _promotePawn(BuildContext context, int row, int col, PieceType type) {
    board[row][col] = ChessPiece(
      type: type,
      color: selectedPiece!.color,
      imagePath: selectedPiece!.color == PieceColor.white ? whitePieceImages[type]! : blackPieceImages[type]!,
    );
    Navigator.of(context).pop();

    bool isWhiteKingInCheck = isKingInCheck(true);
    bool isBlackKingInCheck = isKingInCheck(false);
    bool hasMoves = hasValidMoves(!isWhiteTurn);

    if (isWhiteKingInCheck && !hasMoves) {
      checkStatus = true;
      _showGameOverDialog(context, "Black wins by checkmate!");
    } else if (isBlackKingInCheck && !hasMoves) {
      checkStatus = true;
      _showGameOverDialog(context, "White wins by checkmate!");
    } else if (!hasMoves) {
      _showGameOverDialog(context, "Stalemate!");
    } else {
      checkStatus = isWhiteKingInCheck || isBlackKingInCheck;
    }

    selectedPiece = null;
    selectedRow = -1;
    selectedColumn = -1;
    validMoves = [];
    isWhiteTurn = !isWhiteTurn;
  }

  void _showGameOverDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Game Over"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              reset();
            },
            child: const Text("New Game"),
          ),
        ],
      ),
    );
  }

  void reset() {
    board = List.generate(8, (_) => List.generate(8, (_) => null));
    _initializeBoard();
    selectedPiece = null;
    selectedRow = -1;
    selectedColumn = -1;
    validMoves = [];
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    isWhiteTurn = true;
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    checkStatus = false;
    whiteKingMoved = false;
    blackKingMoved = false;
    whiteRooksMoved = {0: false, 7: false};
    blackRooksMoved = {0: false, 7: false};
    lastDoublePawnMove = null;
  }
}
import 'package:chess/components/dead_piece.dart';
import 'package:chess/components/square.dart';
import 'package:chess/models/chess_game.dart';
import 'package:chess/values/colors.dart';
import 'package:chess/values/constants.dart';
import 'package:flutter/material.dart';

import '../helper/helper_methods.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late ChessGame game;
  bool _imagesPrecached = false;

  @override
  void initState() {
    super.initState();
    game = ChessGame();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPrecached) {
      _precacheImages();
      _imagesPrecached = true;
    }
  }

  void _precacheImages() {
    for (var image in [...whitePieceImages.values, ...blackPieceImages.values]) {
      precacheImage(AssetImage(image), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chess"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                game.reset();
              });
            },
            tooltip: 'New Game',
          ),
        ],
      ),
      body: Column(
        children: [
          // Turn Indicator
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              game.isWhiteTurn ? "White's Turn" : "Black's Turn",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          // White Pieces Taken
          SizedBox(
            height: 40, // Fixed height to prevent taking too much space
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: game.whitePiecesTaken.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: game.whitePiecesTaken[index].imagePath,
                isWhite: true,
              ),
            ),
          ),
          // Game Status
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              game.checkStatus ? "CHECK!" : "",
              style: const TextStyle(fontSize: 24, color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
          // Chess Board
          Expanded(
            flex: 8, // Increased flex to prioritize board visibility
            child: AspectRatio(
              aspectRatio: 1.0, // Ensures the board is square
              child: Container(
                color: boardColor,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 8 * 8,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    childAspectRatio: 1, // Ensures each square is square
                  ),
                  itemBuilder: (context, index) {
                    int row = index ~/ 8;
                    int col = index % 8;
                    bool isSelected = game.selectedRow == row && game.selectedColumn == col;
                    bool isValidMove = game.validMoves.any((move) => move[0] == row && move[1] == col);
                    bool isCaptureMove = isValidMove && game.board[row][col] != null && game.board[row][col]!.color != game.selectedPiece?.color;

                    return Square(
                      isWhite: isWhite(index),
                      piece: game.board[row][col],
                      isSelected: isSelected,
                      isValidMove: isValidMove,
                      isCaptureMove: isCaptureMove,
                      onTap: () => setState(() => game.pieceSelected(row, col, context)),
                    );
                  },
                ),
              ),
            ),
          ),
          // Black Pieces Taken
          SizedBox(
            height: 40, // Fixed height to prevent taking too much space
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: game.blackPiecesTaken.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: game.blackPiecesTaken[index].imagePath,
                isWhite: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
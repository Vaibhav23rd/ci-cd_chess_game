import 'package:chess/models/piece.dart';
import 'package:chess/values/colors.dart';
import 'package:flutter/material.dart';

class Square extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isValidMove;
  final bool isCaptureMove;
  final void Function()? onTap;

  const Square({
    super.key,
    required this.isWhite,
    required this.piece,
    required this.isSelected,
    required this.isValidMove,
    required this.isCaptureMove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color? squareColor;
    if (isSelected) {
      squareColor = Colors.green;
    } else if (isCaptureMove) {
      squareColor = Colors.red[200];
    } else if (isValidMove) {
      squareColor = Colors.green[200];
    } else {
      squareColor = isWhite ? foregroundColor : backgroundColor;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: squareColor,
        margin: EdgeInsets.all(isValidMove || isCaptureMove ? 5 : 0),
        child: piece != null
            ? Image.asset(
          piece!.imagePath,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
        )
            : null,
      ),
    );
  }
}
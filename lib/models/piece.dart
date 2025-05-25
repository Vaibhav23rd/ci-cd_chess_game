enum PieceType { pawn, rook, knight, bishop, queen, king }
enum PieceColor { white, black }

class ChessPiece {
  final PieceType type;
  final PieceColor color;
  final String imagePath;

  ChessPiece({
    required this.type,
    required this.color,
    required this.imagePath,
  });
}
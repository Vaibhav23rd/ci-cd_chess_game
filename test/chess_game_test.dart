import 'package:chess/components/square.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chess/models/chess_game.dart';
import 'package:chess/models/piece.dart';

void main() {
  group('ChessGame', () {
    late ChessGame game;

    setUp(() {
      game = ChessGame();
    });

    test('Pawn moves one or two squares forward from initial position', () {
      // White pawn at (6, 0) should have valid moves to (5, 0) and (4, 0)
      final validMoves = game.calculateRealValidMoves(6, 0, game.board[6][0], true);
      expect(validMoves, containsAll([[5, 0], [4, 0]]));
    });

    test('Pawn cannot move forward if blocked', () {
      // Place a black pawn at (5, 0) to block white pawn at (6, 0)
      game.board[5][0] = ChessPiece(
        type: PieceType.pawn,
        color: PieceColor.black,
        imagePath: 'assets/images/b_pawn.png',
      );
      final validMoves = game.calculateRealValidMoves(6, 0, game.board[6][0], true);
      expect(validMoves, isNot(contains([5, 0])));
      expect(validMoves, isNot(contains([4, 0])));
    });
  });

  group('Square Widget', () {
    testWidgets('Square renders piece image when piece is present', (WidgetTester tester) async {
      final piece = ChessPiece(
        type: PieceType.pawn,
        color: PieceColor.white,
        imagePath: 'assets/images/w_pawn.png',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Square(
              isWhite: true,
              piece: piece,
              isSelected: false,
              isValidMove: false,
              isCaptureMove: false,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('Square is empty when no piece is present', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Square(
              isWhite: true,
              piece: null,
              isSelected: false,
              isValidMove: false,
              isCaptureMove: false,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.byType(Image), findsNothing);
    });
  });
}
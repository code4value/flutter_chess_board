import 'package:flutter/material.dart';
import 'package:flutter_chess_board/src/board_model.dart';
import 'package:flutter_chess_board/src/board_rank.dart';
import 'package:scoped_model/scoped_model.dart';
import 'chess_board_controller.dart';

var whiteSquareList = [
  [
    "a8",
    "b8",
    "c8",
    "d8",
    "e8",
    "f8",
    "g8",
    "h8",
  ],
  [
    "a7",
    "b7",
    "c7",
    "d7",
    "e7",
    "f7",
    "g7",
    "h7",
  ],
  [
    "a6",
    "b6",
    "c6",
    "d6",
    "e6",
    "f6",
    "g6",
    "h6",
  ],
  [
    "a5",
    "b5",
    "c5",
    "d5",
    "e5",
    "f5",
    "g5",
    "h5",
  ],
  [
    "a4",
    "b4",
    "c4",
    "d4",
    "e4",
    "f4",
    "g4",
    "h4",
  ],
  [
    "a3",
    "b3",
    "c3",
    "d3",
    "e3",
    "f3",
    "g3",
    "h3",
  ],
  [
    "a2",
    "b2",
    "c2",
    "d2",
    "e2",
    "f2",
    "g2",
    "h2",
  ],
  [
    "a1",
    "b1",
    "c1",
    "d1",
    "e1",
    "f1",
    "g1",
    "h1",
  ],
];

/// Enum which stores board types
enum BoardType {
  brown,
  darkBrown,
  orange,
  green,
  darkGreen,
  blue,
}

const Map<BoardType, List<Color>> COLOR_MAP = const {
  BoardType.brown: [Color.fromARGB(255, 238, 222, 190), Color.fromARGB(255, 181, 135, 99)],
  BoardType.darkBrown: [Color.fromARGB(255, 238, 222, 190), Color.fromARGB(255, 126, 108, 98)],
  BoardType.orange: [Color.fromARGB(255, 238, 222, 190), Color.fromARGB(255, 204, 114, 58)],
  BoardType.green: [Color.fromARGB(255, 238, 238, 210), Color.fromARGB(255, 118, 150, 86)],
  BoardType.darkGreen: [Color.fromARGB(255, 238, 238, 210), Color.fromARGB(255, 47, 109, 18)],
  BoardType.blue: [Color.fromARGB(255, 238, 238, 210), Color.fromARGB(255, 113, 134, 184)]
};

const Color HIGHLIGHT_COLOR = Color.fromRGBO(255, 195, 0, 0.6);
const Color HIGHLIGHT_COLOR_2 = Color.fromRGBO(255, 215, 0, 0.5);

/// The Chessboard Widget
class ChessBoard extends StatefulWidget {
  /// Size of chessboard
  final double size;

  /// Callback for when move is made
  final MoveCallback onMove;

  /// Callback for when a player is checkmated
  final CheckMateCallback onCheckMate;

  /// Callback for when a player is in check
  final CheckCallback onCheck;

  /// Callback for when the game is a draw
  final VoidCallback onDraw;

  /// A boolean which notes if white board side is towards users
  final bool whiteSideTowardsUser;

  /// A controller to programmatically control the chess board
  final ChessBoardController chessBoardController;

  /// A boolean which checks if the user should be allowed to make moves
  final bool enableUserMoves;

  /// The color type of the board
  final BoardType boardType;

  /// The background color of the square piece selected
  final Color bgColorPieceSelected;

  /// The background color of the square piece moved from
  final Color bgColorPieceFrom;

  /// The background color of the square piece moved to
  final Color bgColorPieceTo;

  /// The color type of the board
  final bool showPosition;

  ChessBoard({
    this.size = 200.0,
    this.whiteSideTowardsUser = true,
    @required this.onMove,
    @required this.onCheckMate,
    @required this.onCheck,
    @required this.onDraw,
    this.chessBoardController,
    this.enableUserMoves = true,
    this.boardType = BoardType.darkGreen,
    this.bgColorPieceSelected = HIGHLIGHT_COLOR,
    this.bgColorPieceFrom = HIGHLIGHT_COLOR_2,
    this.bgColorPieceTo = HIGHLIGHT_COLOR_2,
    this.showPosition = true,
  });

  @override
  _ChessBoardState createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  @override
  Widget build(BuildContext context) {

    BoardModel model = BoardModel(
        widget.size,
        widget.onMove,
        widget.onCheckMate,
        widget.onCheck,
        widget.onDraw,
        widget.whiteSideTowardsUser,
        widget.chessBoardController,
        widget.enableUserMoves,
        widget.bgColorPieceSelected,
        widget.bgColorPieceFrom,
        widget.bgColorPieceTo,
      );

    return ScopedModel(
      model: model,
      child: Container(
        height: widget.size,
        width: widget.size,
        child: Stack(
          children: <Widget>[
            Container(
              height: widget.size,
              width: widget.size,
              child: _getBoardWidget(),
            ),
            //Overlaying draggables/ dragTargets onto the squares
            Center(
              child: Container(
                height: widget.size,
                width: widget.size,
                child: buildChessBoard(),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Builds the board
  Widget buildChessBoard() {
    return Column(
      children: widget.whiteSideTowardsUser
          ? whiteSquareList.map((row) {
              return ChessBoardRank(
                children: row,
              );
            }).toList()
          : whiteSquareList.reversed.map((row) {
              return ChessBoardRank(
                children: row.reversed.toList(),
              );
            }).toList(),
    );
  }

  Widget _getSquareLabel(int row, int column) {
    Widget label1;
    if ( column == 7 ) {
      label1 = Text((8-row).toString(),
          style: TextStyle(
            color: row % 2 == 0? COLOR_MAP[widget.boardType][0] : COLOR_MAP[widget.boardType][1]
          ),
          textAlign: TextAlign.right
      );
    }
    Widget label2;
    if ( row == 7 ) {
      int c = "a".codeUnitAt(0);
      label2 = Align(
          alignment: Alignment.bottomLeft,
          child: Text(new String.fromCharCode(c + column),
            style: TextStyle(
              color: column % 2 == 0? COLOR_MAP[widget.boardType][0] : COLOR_MAP[widget.boardType][1],
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.left
          )
      );
    }
    Widget label;
    if ( label1!=null && label2!=null ) {
      double squareSize = widget.size/8;
      label = Stack(children: [
        Container(
          height: squareSize,
          width: squareSize,
          child: label1,
        )
        , label2]);
    }
    else if ( label1!=null ) {
      label = label1;
    }
    else {
      label = label2;
    }
    return label;
  }

  Widget _getBoardWidget() {
    double squareSize = widget.size/8;

    List<Widget> rows = List();
    for (var i=0; i<8; i++) {
      List<Widget> boardSquares = List();
      for (var j=0; j<8; j++) {
        Color squareColor = i % 2 == j % 2? COLOR_MAP[widget.boardType][0] : COLOR_MAP[widget.boardType][1];
        Widget label = widget.showPosition &&(i==7 || j==7)? _getSquareLabel(i, j) : null;

        Container square;
        if ( label == null ) {
          square = Container(
            color: squareColor,
            width: squareSize,
            height: squareSize
          );
        }
        else {
          square = Container(
            color: squareColor,
            width: squareSize,
            height: squareSize,
            child: label
          );
        }
        boardSquares.add(square);
      }
      Row row = Row(
        children: boardSquares,
      );
      rows.add(row);
    }
    if ( widget.showPosition ) {
      List<Widget> labels = List();
      int c = "a".codeUnitAt(0);
      for (int column=0; column<8; column++) {
        labels.add(Text(new String.fromCharCode(c + column), textDirection: TextDirection.rtl));
      }
    }
    Widget board = Column(
      children: rows,
    );
    return board;
  }

  Widget _getBoardImage() {
    switch (widget.boardType) {
      case BoardType.brown:
        return Image.asset(
          "images/brown_board.png",
          // package: 'flutter_chess_board',
          fit: BoxFit.cover,
        );
      case BoardType.darkBrown:
        return Image.asset(
          "images/dark_brown_board.png",
          package: 'flutter_chess_board',
          fit: BoxFit.cover,
        );
      case BoardType.green:
        return Image.asset(
          "images/green_board.png",
          package: 'flutter_chess_board',
          fit: BoxFit.cover,
        );
      case BoardType.orange:
        return Image.asset(
          "images/orange_board.png",
          package: 'flutter_chess_board',
          fit: BoxFit.cover,
        );
      default:
        return null;
    }
  }
}

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

enum PositionLabelOption {
  none,
  leftBottomInner,
  leftBottomOuter,
  rightBottomInner,
  rightBottomOuter,
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

  /// The option of position labels
  final PositionLabelOption positionLabelOption;

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
    this.positionLabelOption = PositionLabelOption.leftBottomInner,
  });

  @override
  _ChessBoardState createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  @override
  Widget build(BuildContext context) {
    double boardSize = widget.size;
    if ( widget.positionLabelOption == PositionLabelOption.leftBottomOuter ||
         widget.positionLabelOption == PositionLabelOption.rightBottomOuter ) {
      boardSize = widget.size - widget.size/16;  // half of square size
    }

    BoardModel model = BoardModel(
        boardSize,
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

    Widget boardContainer = ScopedModel(
      model: model,
      child: Container (
        height: boardSize,
        width: boardSize,
        child: Stack(
          children: <Widget>[
            Container(
              height: boardSize,
              width: boardSize,
              child: _getBoardWidget(boardSize),
            ),
            // Overlaying draggables/ dragTargets onto the squares
            Center(
              child: Container(
                height: boardSize,
                width: boardSize,
                child: buildChessBoard(),
              ),
            )
          ],
        )
      )
    );


    Widget boardWidget;
    if ( widget.positionLabelOption == PositionLabelOption.leftBottomOuter ||
      widget.positionLabelOption == PositionLabelOption.rightBottomOuter ) {

      double squareSize = boardSize/8;
      Widget labels18 = _buildOuterSquareLabels18(squareSize);
      Widget labelsAH = _buildOuterSquareLabelsAH(squareSize);

      var row1 = widget.positionLabelOption == PositionLabelOption.leftBottomOuter?
        <Widget>[ labels18, boardContainer ]: <Widget>[ boardContainer, labels18 ];
      var row2 = widget.positionLabelOption == PositionLabelOption.leftBottomOuter?
        <Widget>[Container(width: squareSize/2, height: squareSize/2), labelsAH]:
        <Widget>[labelsAH, Container(width: squareSize/2, height: squareSize/2)];

      boardWidget = Container(
        width: widget.size,
        // height: widget.size,
        child: ListView (
          shrinkWrap: true,
          children: <Widget>[
            Container(
              height: boardSize,
              child: ListView (
                scrollDirection: Axis.horizontal,
                children: row1
              )
            ),
            Container(
              height: squareSize/2,
              child: ListView (
                scrollDirection: Axis.horizontal,
                children: row2
              )
            )
          ]
        )
      );
    }
    else {
      boardWidget = boardContainer;
    }

    return boardWidget;
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

  Widget _buildOuterSquareLabels18(double squareSize) {
    return Container(
      width: squareSize / 2,
      height: squareSize * 8,
      child: ListView(
        padding: const EdgeInsets.all(0),
        shrinkWrap: true,
        children: List.generate(8, (index) {
          return Container(
            width: squareSize / 2,
            height: squareSize,
            child: Text((index+1).toString(),
              textAlign: TextAlign.center
            )
          );
        })
      )
    );
  }

  Widget _buildOuterSquareLabelsAH(double squareSize) {
    int c = "a".codeUnitAt(0);
    return Container(
      width: squareSize * 8,
      height: squareSize / 2,
      child: ListView(
        padding: const EdgeInsets.all(0),
        scrollDirection: Axis.horizontal,
        children: List.generate(8, (index) {
          return Container(
            width: squareSize,
            height: squareSize / 2,
            child: Text(new String.fromCharCode(c + index),
              textAlign: TextAlign.center
            )
          );
        })
      )
    );
  }

  Widget _buildInnerSquareLabel(int row, int column, double squareSize) {
    Widget label18;  // 1, 2, 3...
    Widget labelAH;  // a, b, c...
    if ( widget.positionLabelOption == PositionLabelOption.leftBottomInner && column == 0) {
      // label on 1st column
      label18 = Text((8-row).toString(),
          style: TextStyle(
            color: row % 2 == 0? COLOR_MAP[widget.boardType][1] : COLOR_MAP[widget.boardType][0]
          ),
          textAlign: TextAlign.left
      );
    }
    else if ( widget.positionLabelOption == PositionLabelOption.rightBottomInner && column == 7 ) {
      // label on last column
      label18 = Text((8-row).toString(),
          style: TextStyle(
            color: row % 2 == 0? COLOR_MAP[widget.boardType][0] : COLOR_MAP[widget.boardType][1]
          ),
          textAlign: TextAlign.right
      );
    }

    if ( (widget.positionLabelOption == PositionLabelOption.leftBottomInner ||
           widget.positionLabelOption == PositionLabelOption.rightBottomInner) && row == 7 ) {
      int c = "a".codeUnitAt(0);
      labelAH = Align(
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
    if ( label18!=null && labelAH!=null ) {
      label = Stack(children: [
        Container(
          height: squareSize,
          width: squareSize,
          child: label18,
        )
        , labelAH]);
    }
    else if ( label18!=null ) {
      label = label18;
    }
    else {
      label = labelAH;
    }
    return label;
  }

  Widget _getBoardWidget(double boardSize) {
    double squareSize = boardSize / 8;
    List<Widget> rows = List();
    for (var i=0; i<8; i++) {
      List<Widget> boardSquares = List();
      for (var j=0; j<8; j++) {
        Color squareColor = i % 2 == j % 2? COLOR_MAP[widget.boardType][0] : COLOR_MAP[widget.boardType][1];
        Widget label = _buildInnerSquareLabel(i, j, squareSize);

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
    if ( widget.positionLabelOption == PositionLabelOption.leftBottomInner ) {
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

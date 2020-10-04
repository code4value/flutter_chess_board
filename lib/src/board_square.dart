import 'package:flutter/material.dart';
import 'package:flutter_chess_board/src/board_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:async';
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:chess/chess.dart' as chess;

/// A single square on the chessboard
class BoardSquare extends StatelessWidget {
  /// The square name (a2, d3, e4, etc.)
  final squareName;

  BoardSquare({this.squareName});

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<BoardModel>(builder: (context, _, model) {
      return Expanded(
        flex: 1,
        child: DragTarget(builder: (context, accepted, rejected) {
          return model.game.get(squareName) != null
              ? Draggable(
                  child: _getImageToDisplay(size: model.size / 8, model: model),
                  feedback: _getImageToDisplay(
                      size: (1.2 * (model.size / 8)), model: model),
                  onDragCompleted: () {},
                  data: [
                    squareName,
                    model.game.get(squareName).type.toUpperCase(),
                    model.game.get(squareName).color,
                  ],
                )
              : _getSquareToDisplay(size: model.size / 8, model: model);
        }, onWillAccept: (willAccept) {
          return model.enableUserMoves ? true : false;
        }, onAccept: (List moveInfo) {
          model.selectedSquare = null;
          model.legalMoves = null;

          // A way to check if move occurred.
          chess.Color moveColor = model.game.turn;

          if (moveInfo[1] == "P" &&
              ((moveInfo[0][1] == "7" &&
                      squareName[1] == "8" &&
                      moveInfo[2] == chess.Color.WHITE) ||
                  (moveInfo[0][1] == "2" &&
                      squareName[1] == "1" &&
                      moveInfo[2] == chess.Color.BLACK))) {
            // promotion
            _promotionDialog(context).then((value) {
              model.game.move(
                  {"from": moveInfo[0], "to": squareName, "promotion": value});
              model.refreshBoard();
            });
          } else {
            model.game.move({"from": moveInfo[0], "to": squareName});
          }
          if (model.game.turn != moveColor) {
            model.onMove(
                moveInfo[1] == "P" ? squareName : moveInfo[1] + squareName);
          }
          model.refreshBoard();
        }),
      );
    });
  }

  /// Show dialog when pawn reaches last square
  Future<String> _promotionDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Choose promotion'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              InkWell(
                child: WhiteQueen(),
                onTap: () {
                  Navigator.of(context).pop("q");
                },
              ),
              InkWell(
                child: WhiteRook(),
                onTap: () {
                  Navigator.of(context).pop("r");
                },
              ),
              InkWell(
                child: WhiteBishop(),
                onTap: () {
                  Navigator.of(context).pop("b");
                },
              ),
              InkWell(
                child: WhiteKnight(),
                onTap: () {
                  Navigator.of(context).pop("n");
                },
              ),
            ],
          ),
        );
      },
    ).then((value) {
      return value;
    });
  }

  Widget _getSquareToDisplay({double size, BoardModel model}) {
    Color bgColor = null;
    if ( model.bgColorPieceFrom != null && model.game.history.isNotEmpty ) {
      if ( model.game.history.last.move.flags & chess.Chess.BITS_KSIDE_CASTLE != 0 ) {
        // castling
        if ( (this.squareName == 'h1' && model.game.history.last.move.fromAlgebraic == 'e1') ||
          (this.squareName == 'h8' && model.game.history.last.move.fromAlgebraic == 'e8' )) {
            bgColor = model.bgColorPieceFrom;
        }
      }
      if ( model.game.history.last.move.flags & chess.Chess.BITS_QSIDE_CASTLE != 0 ) {
        // castling
        if ( (this.squareName == 'a1' && model.game.history.last.move.fromAlgebraic == 'e1') ||
          (this.squareName == 'a8' && model.game.history.last.move.fromAlgebraic == 'e8' )) {
          bgColor = model.bgColorPieceFrom;
        }
      }
      if (this.squareName == model.game.history.last.move.fromAlgebraic) {
        // if moved from the square
        bgColor = model.bgColorPieceFrom;
      }
    }

    if ( model.legalMoves != null ) {
      for(chess.Move move in model.legalMoves) {
        if ( this.squareName == move.toAlgebraic ) {
          return Container(
            color: bgColor,
            width: size,
            height: size,
            alignment: Alignment.center,
            child: new SizedBox(
              width: size/4,
              height: size/4,
              child: new DecoratedBox (
                decoration: new BoxDecoration(
                  color: model.bgColorPieceSelected,
                  shape: BoxShape.circle,
                ),
              )
            )
          );
        }
      }
    }

    return Container(color: bgColor);
  }

  /// Get image to display on square
  Widget _getImageToDisplay({double size, BoardModel model}) {

    if (model.game.get(squareName) == null) {
      return Container();
    }

    Widget imageToDisplay = Container();
    String piece = model.game
            .get(squareName)
            .color
            .toString()
            .substring(0, 1)
            .toUpperCase() +
        model.game.get(squareName).type.toUpperCase();

    switch (piece) {
      case "WP":
        imageToDisplay = WhitePawn(size: size);
        break;
      case "WR":
        imageToDisplay = WhiteRook(size: size);
        break;
      case "WN":
        imageToDisplay = WhiteKnight(size: size);
        break;
      case "WB":
        imageToDisplay = WhiteBishop(size: size);
        break;
      case "WQ":
        imageToDisplay = WhiteQueen(size: size);
        break;
      case "WK":
        imageToDisplay = WhiteKing(size: size);
        break;
      case "BP":
        imageToDisplay = BlackPawn(size: size);
        break;
      case "BR":
        imageToDisplay = BlackRook(size: size);
        break;
      case "BN":
        imageToDisplay = BlackKnight(size: size);
        break;
      case "BB":
        imageToDisplay = BlackBishop(size: size);
        break;
      case "BQ":
        imageToDisplay = BlackQueen(size: size);
        break;
      case "BK":
        imageToDisplay = BlackKing(size: size);
        break;
      default:
        imageToDisplay = WhitePawn(size: size);
    }

    Widget imageItem = imageToDisplay;
    if ( model.legalMoves != null ) {
      for(chess.Move move in model.legalMoves) {
        if ( this.squareName == move.toAlgebraic ) {
          Container newContainer = new Container(
            decoration: new BoxDecoration(
              color: model.bgColorPieceSelected,
              shape: BoxShape.circle,
            ),
            child: imageToDisplay
          );
          imageItem = newContainer;
          break;
        }
      }
    }

    GestureDetector squareItem = new GestureDetector(
        onTap: (){
          if ( model.game.get(squareName).color != model.game.turn ) {
            // not ready for the opponent yet
            return;
          }

          Map options = {"valid": true, "square": this.squareName};
          List<chess.Move> moves = model.game.generate_moves(options);
          model.selectedSquare = this.squareName;
          model.legalMoves = moves;

          model.refreshBoard();
        },
        child: imageItem
    );

    if (this.squareName == model.selectedSquare) {
      return Container(
        color: model.bgColorPieceSelected,
        child: squareItem
      );
    }

    if ( model.bgColorPieceTo != null && model.game.history.isNotEmpty ) {
      if ( model.game.history.last.move.flags & chess.Chess.BITS_KSIDE_CASTLE != 0 ) {
        // castling
        if ( (this.squareName == 'f1' && model.game.history.last.move.fromAlgebraic == 'e1') ||
          (this.squareName == 'f8' && model.game.history.last.move.fromAlgebraic == 'e8' )) {
          return Container(
            color: model.bgColorPieceTo,
            child: squareItem
          );
        }
      }
      if ( model.game.history.last.move.flags & chess.Chess.BITS_QSIDE_CASTLE != 0 ) {
        // castling
        if ( (this.squareName == 'd1' && model.game.history.last.move.fromAlgebraic == 'e1') ||
          (this.squareName == 'd8' && model.game.history.last.move.fromAlgebraic == 'e8' )) {
          return Container(
            color: model.bgColorPieceTo,
            child: squareItem
          );
        }
      }

      if (this.squareName == model.game.history.last.move.toAlgebraic) {
        // if moved to the square, overlay
        return Container(
          color: model.bgColorPieceTo,
          child: squareItem
        );
      }
    }

    return squareItem;
  }
}

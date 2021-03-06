import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/src/chess_board.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {

    var padding = MediaQuery.of(context).padding;
    var barHeight = AppBar().preferredSize.height;
    double safeHeight = MediaQuery.of(context).size.height - padding.top - padding.bottom - barHeight;

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ChessBoard(
              onMove: (move) {
                print(move);
              },
              onCheck: (color) {
                print(color);
              },
              onCheckMate: (color) {
                print(color);
              },
              onDraw: () {},
              size: min(MediaQuery.of(context).size.width, safeHeight),
              enableUserMoves: true,
            )
          ],
        ),
      ),
    );
  }
}
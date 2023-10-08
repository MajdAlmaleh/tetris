import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris/grid.dart';
import 'package:tetris/pixel.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<List<int>> piecesConsts = [
  [4, 5, 14, 15], //O
  [5, 15, 25, 35], //I
  [4, 14, 15, 25], //S
  [5, 14, 15, 24], //Z
  [5, 15, 24, 25], //J
  [4, 14, 24, 25], //L
  [4, 5, 6, 15], //T
];
/* const List<List<int>> piecesConsts = [
  [5, 15, 25, 35], //I
  [4, 5, 14, 15], //I
[5, 15, 25, 35], //I
  [5, 15, 25, 35], //I
[5, 15, 25, 35], //I
 [5, 15, 25, 35], //I
[5, 15, 25, 35], //I
];
 */
const List<Color> piecesColors = [
  Colors.yellow,
  Colors.cyan,
  Colors.green,
  Colors.red,
  Colors.blue,
  Colors.orange,
  Colors.purple,
];

/* const List<int> piecesWidth = [
  2,
  1,
  1,
  1,
  2,
  2,
  1,
]; */
const emptyColor = Color.fromARGB(255, 59, 58, 58);

var random = Random();

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  int bestScore = 0;
  int multi = 0;
  int score = 0;
  List<Pixel> pixels =
      List.generate(180, (index) => Pixel(busy: false, color: emptyColor));
  List<List<int>> pieces =
      piecesConsts.map<List<int>>((piece) => List.from(piece)).toList();
  int picked = -1;
  String dropdownValue = 'Easy';
  int timer = 400;

  bool isStartGame = false;
  void getPiece() {
    pieces = piecesConsts.map<List<int>>((piece) => List.from(piece)).toList();

    picked = random.nextInt(7);
  }

  bool isCollision(List<int> piece, List<Pixel> board) {
    for (int i = 0; i < piece.length; i++) {
      if (piece[i] < 0 || piece[i] >= board.length || board[piece[i]].getBusy) {
        return true;
      }
      // Check if block is outside the grid horizontally
      if (piece[i] % 10 < 0 || piece[i] % 10 >= 10) {
        return true;
      }
      if (((piece[0] + 1) % 10 == 0) ||
          ((piece[1] + 1) % 10 == 0) ||
          ((piece[2] + 1) % 10 == 0) ||
          ((piece[3] + 1) % 10 == 0)) {
        return true;
      }
      if (piecesColors[picked] == Colors.yellow) {
        return true;
      }
    }
    return false;
  }

  void rotatePiece(List<int> piece, List<Pixel> board) {
    // Calculate pivot point (assuming it's the second block)
    int pivot = piece[1];

    // Calculate new positions
    List<int> newPiece = List<int>.from(piece);
    for (int i = 0; i < piece.length; i++) {
      int x = piece[i] % 10 - pivot % 10;
      int y = piece[i] ~/ 10 - pivot ~/ 10;

      // Rotate clockwise
      int newX = -y;
      int newY = x;

      newPiece[i] = pivot + newY * 10 + newX;
    }

    // Check for collisions and perform wall kicks if necessary
    if (isCollision(newPiece, board)) {
      // Try moving left
      for (int i = 0; i < newPiece.length; i++) {
        newPiece[i]--;
      }
      if (!isCollision(newPiece, board)) {
        for (int i = 0; i < 4; i++) {
          pixels[pieces[picked][i]].setColor = emptyColor;
          pixels[pieces[picked][i]].setBusy = false;
        }
        piece.setAll(0, newPiece);
        for (int i = 0; i < 4; i++) {
          pixels[pieces[picked][i]].setColor = piecesColors[picked];
        }
        setState(() {});
        return;
      }

      // Try moving right
      for (int i = 0; i < newPiece.length; i++) {
        newPiece[i] += 2;
      }
      if (!isCollision(newPiece, board)) {
        for (int i = 0; i < 4; i++) {
          pixels[pieces[picked][i]].setColor = emptyColor;
          pixels[pieces[picked][i]].setBusy = false;
        }
        piece.setAll(0, newPiece);
        for (int i = 0; i < 4; i++) {
          pixels[pieces[picked][i]].setColor = piecesColors[picked];
        }
        setState(() {});
        return;
      }

      // If all else fails, don't rotate
      return;
    }

    // If no collisions, update piece
    for (int i = 0; i < 4; i++) {
      pixels[pieces[picked][i]].setColor = emptyColor;
      pixels[pieces[picked][i]].setBusy = false;
    }
    piece.setAll(0, newPiece);
    for (int i = 0; i < 4; i++) {
      pixels[pieces[picked][i]].setColor = piecesColors[picked];
    }
    setState(() {});
  }

  bool gameOver() {
    if (pixels[pieces[picked][0]].getBusy ||
        pixels[pieces[picked][1]].getBusy ||
        pixels[pieces[picked][2]].getBusy ||
        pixels[pieces[picked][3]].getBusy) {
      return true;
    }
    return false;
  }

  bool checkDown() {
    if (pieces[picked][3] + 10 <= 179 &&
        pieces[picked][2] + 10 <= 179 &&
        pieces[picked][1] + 10 <= 179 &&
        pieces[picked][0] + 10 <= 179 &&
        pixels[pieces[picked][0] + 10].getBusy == false &&
        pixels[pieces[picked][1] + 10].getBusy == false &&
        pixels[pieces[picked][2] + 10].getBusy == false &&
        pixels[pieces[picked][3] + 10].getBusy == false) {
      return true;
    }
    return false;
  }

  void moveDown() {
    Timer.periodic(
      Duration(milliseconds: timer),
      (timer) {
        if (checkDown()) {
          for (int i = 0; i < 4; i++) {
            pixels[pieces[picked][i]].setBusy = false;
            pixels[pieces[picked][i]].setColor = emptyColor;
          }
          for (int i = 0; i < 4; i++) {
            pieces[picked][i] += 10;
          }

          for (int i = 0; i < 4; i++) {
            pixels[pieces[picked][i]].setColor = piecesColors[picked];
          }

          setState(() {});
        } else {
          for (int i = 0; i < 4; i++) {
            pixels[pieces[picked][i]].setColor = piecesColors[picked];
            pixels[pieces[picked][i]].setBusy = true;
          }

          timer.cancel();

          startGame();
        }
      },
    );
  }

  bool checkRight() {
    if (((pieces[picked][0] + 1) % 10 != 0) &&
        ((pieces[picked][1] + 1) % 10 != 0) &&
        ((pieces[picked][2] + 1) % 10 != 0) &&
        ((pieces[picked][3] + 1) % 10 != 0) &&
        pixels[pieces[picked][0] + 1].getBusy == false &&
        pixels[pieces[picked][1] + 1].getBusy == false &&
        pixels[pieces[picked][2] + 1].getBusy == false &&
        pixels[pieces[picked][3] + 1].getBusy == false) {
      return true;
    }
    return false;
  }

  void moveRight() {
    if (checkRight()) {
      for (int i = 0; i < 4; i++) {
        pixels[pieces[picked][i]].setColor = emptyColor;
      }
      for (int i = 0; i < 4; i++) {
        pieces[picked][i] += 1;
      }
      for (int i = 0; i < 4; i++) {
        pixels[pieces[picked][i]].setColor = piecesColors[picked];
      }

      setState(() {});
    } else {
      return;
    }
  }

  bool checkLeft() {
    if (((pieces[picked][0] - 1) % 10 != 9) &&
        ((pieces[picked][1] - 1) % 10 != 9) &&
        ((pieces[picked][2] - 1) % 10 != 9) &&
        ((pieces[picked][3] - 1) % 10 != 9) &&
        pixels[pieces[picked][0] - 1].getBusy == false &&
        pixels[pieces[picked][1] - 1].getBusy == false &&
        pixels[pieces[picked][2] - 1].getBusy == false &&
        pixels[pieces[picked][3] - 1].getBusy == false) {
      return true;
    }
    return false;
  }

  void moveLeft() {
    if (checkLeft()) {
      for (int i = 0; i < 4; i++) {
        pixels[pieces[picked][i]].setColor = emptyColor;
      }
      for (int i = 0; i < 4; i++) {
        pieces[picked][i] -= 1;
      }
      for (int i = 0; i < 4; i++) {
        pixels[pieces[picked][i]].setColor = piecesColors[picked];
      }

      setState(() {});
    } else {
      return;
    }
  }

  List<List<bool>> check = List.generate(18, (_) => List.filled(10, false));
  void checkRows() {
    for (int i = 0; i < 18; i++) {
      bool isRowFull =
          pixels.sublist(i * 10, (i + 1) * 10).every((pixel) => pixel.getBusy);
      if (isRowFull) {
        multi += 1;
        clearRow(i);
        score += 10 * multi;
      }
    }
    multi = 0;
  }

  void clearRow(int rowIndex) {
    // Clear the entire row
    for (int j = 0; j < 10; j++) {
      pixels[rowIndex * 10 + j].setBusy = false;
      pixels[rowIndex * 10 + j].setColor = emptyColor;
    }

    // Shift down all rows above the cleared row
    for (int i = rowIndex; i > 0; i--) {
      for (int j = 0; j < 10; j++) {
        pixels[i * 10 + j].setBusy = pixels[(i - 1) * 10 + j].getBusy;
        pixels[i * 10 + j].setColor = pixels[(i - 1) * 10 + j].getColor;
      }
    }
  }

  Future<int> getBestScore() async {
    final pref = await SharedPreferences.getInstance();
    if (pref.getInt('Best') == null) {
      await pref.setInt('Best', 0);
    }
    return pref.getInt('Best')!;
  }

  void getBest() async {
    bestScore = await getBestScore();
  }

  void setScore() async {
    final pref = await SharedPreferences.getInstance();

    if (pref.getInt('Best')! < score) {
      await pref.setInt('Best', score);
    }
  }

  @override
  void initState() {
    getBest();
    super.initState();
  }

  void startGame() {
    if (!isStartGame) {
      getBest();
    }
    isStartGame = true;

    getPiece();
    checkRows();

    if (gameOver()) {
      setScore();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              const Text(
                'Game Over',
                style: TextStyle(color: Colors.red, fontSize: 24),
              ),
              const SizedBox(
                height: 20,
              ),
              Text('Your Score: $score',
                  style: const TextStyle(color: Colors.green, fontSize: 24)),
              const SizedBox(
                height: 20,
              ),
              Text('Best Score: $bestScore',
                  style: const TextStyle(color: Colors.black, fontSize: 24)),
            ]),
            actions: [
              TextButton(
                  onPressed: () {
                    pixels = List.generate(
                        180, (index) => Pixel(busy: false, color: emptyColor));
                    Navigator.pop(context);
                    setState(() {});

                    setScore();
                    score = 0;
                  },
                  child: const Text('Play Again!'))
            ],
          );
        },
      );
      setState(() {
        isStartGame = false;
      });

      return;
    }

    for (int i = 0; i < 4; i++) {
      pixels[pieces[picked][i]].setColor = piecesColors[picked];
    }

    setState(() {});
    moveDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 31, 30, 30),
      body: Column(
        children: [
          Expanded(
            flex: 8,
            child: Grid(
              pixels: pixels,
            ),
          ),
          Expanded(
              child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: !isStartGame ? startGame : null,
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Select Difficulty'),
                          content: StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return DropdownButton<String>(
                                value: dropdownValue,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dropdownValue = newValue!;
                                    switch (newValue) {
                                      case 'Easy':
                                        timer = 400;
                                        break;
                                      case 'Medium':
                                        timer = 250;
                                        break;
                                      case 'Hard':
                                        timer = 150;
                                        break;
                                    }
                                  });
                                },
                                items: <String>[
                                  'Easy',
                                  'Medium',
                                  'Hard'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 59, 58, 58),
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                    ),
                    height: double.infinity,
                    child: Center(
                      child: Text(
                        'PLAY',
                        style: TextStyle(
                            color: isStartGame
                                ? const Color.fromARGB(255, 39, 38, 38)
                                : Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 59, 58, 58),
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  height: double.infinity,
                  child: IconButton(
                    onPressed: isStartGame ? moveLeft : null,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    icon: const Icon(
                      Icons.arrow_left,
                      size: 50,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 59, 58, 58),
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  height: double.infinity,
                  child: IconButton(
                    onPressed: isStartGame ? moveRight : null,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    icon: const Icon(
                      Icons.arrow_right,
                      size: 50,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 59, 58, 58),
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  height: double.infinity,
                  child: IconButton(
                    onPressed: () {
                      //  print(rotatePieceRight(pieces[picked]));

                      setState(() {
                        rotatePiece(pieces[picked], pixels);
                      });
                    },
                    color: const Color.fromARGB(255, 255, 255, 255),
                    icon: const Icon(
                      Icons.replay_sharp,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}

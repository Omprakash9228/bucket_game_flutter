import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class GameScreen extends StatefulWidget {
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double bucketX = 0.0;
  double ballY = -1.0;
  double ballX = 0.0;
  int score = 0;
  int level = 1;
  int ballsCaught = 0;
  int ballsPerLevel = 10;
  double fallSpeed = 0.02;
  int lives = 3;
  bool isGameOver = false;
  bool gameStarted = false;
  int countdown = 3;

  late Timer gameTimer;
  final player = AudioPlayer();

  String ballImage = "assets/Ball/ball_1.jpg";
  String bucketImage = "assets/Bucket/bucket1.jpeg";

  @override
  void initState() {
    super.initState();
    startCountdown();
    resetBall();
  }

  void startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        countdown--;
      });
      if (countdown == 0) {
        timer.cancel();
        gameStarted = true;
        startGame();
      }
    });
  }

  void startGame() {
    gameTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (ballY < 1) {
        setState(() {
          ballY += fallSpeed;
        });

        if (isBallCaught()) {
          setState(() {
            score++;
            ballsCaught++;
            if (ballsCaught >= ballsPerLevel) {
              level++;
              ballsCaught = 0;
              fallSpeed += 0.005;
            }
          });
          resetBall();
        }
      } else {
        setState(() {
          lives--;
          if (lives > 0) {
            resetBall();
          } else {
            isGameOver = true;
            gameTimer.cancel();
            player.play(AssetSource('game_over.mp3'));
          }
        });
      }
    });
  }

  void resetBall() {
    setState(() {
      ballY = -1.0;
      ballX = Random().nextDouble() * 2 - 1;

      int ballNum = Random().nextInt(3) + 1;
      int bucketNum = Random().nextInt(3) + 1;
      ballImage = "assets/Ball/ball_$ballNum.jpg";
      bucketImage = "assets/Bucket/bucket$bucketNum.jpeg";
    });
  }

  bool isBallCaught() {
    final bool verticalMatch = ballY > 0.85 && ballY < 0.95;
    final bool horizontalMatch = (ballX - bucketX).abs() < 0.12;
    return verticalMatch && horizontalMatch;
  }

  void moveBucket(double dx) {
    setState(() {
      bucketX += dx;
      if (bucketX > 1) bucketX = 1;
      if (bucketX < -1) bucketX = -1;
    });
  }

  void endGame() async {
    gameTimer.cancel();
    await player.play(AssetSource('game_over.mp3'));
    setState(() {
      isGameOver = true;
    });
  }

  @override
  void dispose() {
    gameTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft)
            moveBucket(-0.1);
          if (event.logicalKey == LogicalKeyboardKey.arrowRight)
            moveBucket(0.1);
        }
      },
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx > 0)
            moveBucket(0.05);
          else
            moveBucket(-0.05);
        },
        child: Scaffold(
          backgroundColor: Colors.lightBlue[100],
          body: Column(
            children: [
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Score: $score", style: const TextStyle(fontSize: 22)),
                  Text("Level: $level", style: const TextStyle(fontSize: 22)),
                  Text("Lives: $lives", style: const TextStyle(fontSize: 22)),
                ],
              ),
              if (!gameStarted)
                Expanded(
                  child: Center(
                    child: Text(
                      "$countdown",
                      style: const TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 30),
                        top:
                            MediaQuery.of(context).size.height *
                            (ballY + 1) /
                            2,
                        left:
                            MediaQuery.of(context).size.width * (ballX + 1) / 2,
                        child: Image.asset(ballImage, width: 40),
                      ),
                      Positioned(
                        bottom: 50,
                        left:
                            MediaQuery.of(context).size.width *
                                (bucketX + 1) /
                                2 -
                            40,
                        child: Image.asset(bucketImage, width: 80),
                      ),
                    ],
                  ),
                ),
              if (gameStarted)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => moveBucket(-0.1),
                      child: const Text("Left"),
                    ),
                    ElevatedButton(
                      onPressed: () => moveBucket(0.1),
                      child: const Text("Right"),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              if (isGameOver)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      score = 0;
                      level = 1;
                      ballsCaught = 0;
                      fallSpeed = 0.02;
                      lives = 3;
                      bucketX = 0;
                      isGameOver = false;
                      countdown = 3;
                      gameStarted = false;
                      startCountdown();
                      resetBall();
                    });
                  },
                  child: const Text("Restart"),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

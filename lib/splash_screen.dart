import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final String sentence = "Fast Clean Shine";
  late List<String> words;
  int currentWordIndex = 0;

  @override
  void initState() {
    super.initState();

    words = sentence.split(" ");

    startTyping();
  }

  void startTyping() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (currentWordIndex < words.length) {
        setState(() {
          currentWordIndex++;
        });
      } else {
        timer.cancel();

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(context, '/login');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B0A8F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 150,
            ),
            const SizedBox(height: 30),
            Text(
              words.take(currentWordIndex).join(" "),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

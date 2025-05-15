// quiz_page.dart
import 'package:flutter/material.dart';

class QuizPage extends StatelessWidget {
  final List<dynamic> quizData;

  const QuizPage({Key? key , required this.quizData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Quiz Page',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}











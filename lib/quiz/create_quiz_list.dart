import 'package:flutter/material.dart';
import 'package:learn_megnagmet/quiz/create_quiz_container.dart';
import 'package:learn_megnagmet/quiz/quiz_list_widget.dart';
class CreateQuizList extends StatefulWidget {
  final String courseId;
  final String courseName;
  const CreateQuizList({super.key, required this.courseId, required this.courseName});

  @override
  State<CreateQuizList> createState() => _CreateQuizListState();
}

class _CreateQuizListState extends State<CreateQuizList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Quiz List', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        centerTitle: true,backgroundColor: Color(0xFF00AFEE),iconTheme:
        IconThemeData(color: Colors.white),),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CreateQuizContainer(courseName : widget.courseName,courseId: widget.courseId,),
            QuizListWidget(courseId: widget.courseId,),
          ],
        ),

      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learn_megnagmet/quiz/create_quiz_container.dart';
import 'package:learn_megnagmet/quiz/quiz_list_widget.dart';
class CreateQuizList extends StatefulWidget {
  final String courseId;
  const CreateQuizList({super.key, required this.courseId});

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
            CreateQuizContainer(),
            QuizListWidget(courseId: widget.courseId,),
          ],
        ),

      ),
    );
  }
}

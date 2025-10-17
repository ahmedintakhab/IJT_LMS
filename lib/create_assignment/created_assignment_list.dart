import 'package:flutter/material.dart';
import 'package:learn_megnagmet/create_assignment/create_assignment_container.dart';
import 'package:learn_megnagmet/quiz/quiz_list_widget.dart';
class CreatedAssignmentList extends StatefulWidget {
  final String courseId;
  const CreatedAssignmentList({super.key, required this.courseId});

  @override
  State<CreatedAssignmentList> createState() => _CreatedAssignmentListState();
}

class _CreatedAssignmentListState extends State<CreatedAssignmentList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Assignment List', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        centerTitle: true,backgroundColor: Color(0xFF00AFEE),iconTheme:
        IconThemeData(color: Colors.white),),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CreateAssignmentContainer(),
            QuizListWidget(courseId: widget.courseId,),
          ],
        ),

      ),
    );
  }
}

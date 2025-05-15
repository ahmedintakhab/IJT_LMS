// assignment_page.dart
import 'package:flutter/material.dart';

class AssignmentPage extends StatelessWidget {
  final List<dynamic> assignmentData;

  const AssignmentPage({Key? key , required this.assignmentData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Assignment Page',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
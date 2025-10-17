import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learn_megnagmet/widget/button.dart';

class AssignmentResult extends StatelessWidget {
  final Map<String, dynamic> assignmentResult;

  const AssignmentResult({Key? key, required this.assignmentResult}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assignment Result',
          style: TextStyle(color: Color(0xFF00AFEE)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Color(0xFF78A03F),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Assignment Topic',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        assignmentResult['assignment_topic'] ?? 'N/A',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Marks',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        assignmentResult['assignment_total_marks']?.toString() ?? 'N/A',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Marks',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        assignmentResult['your_marks']?.toString() ?? 'None',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notes',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        assignmentResult['notes'] ?? 'None',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: CustomButton(
                onTap: () {
                  Navigator.pop(context);
                },
                buttonText: 'BACK',
                buttonColor: const Color(0xFF00AFEE),
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
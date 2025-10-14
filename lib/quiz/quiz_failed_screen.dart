import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class QuizResultFailed extends StatelessWidget {
  final Map<String, dynamic> normalizedData;

  const QuizResultFailed({Key? key, required this.normalizedData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Check result data: ${normalizedData}');
    final obtainedPercentage = normalizedData['obtained_percentage']?.toString() ?? '0';
    final passingPercentage = normalizedData['passing_percentage']?.toString() ?? '0';
    final quizName = normalizedData['quizName'] ?? 'Test Quiz';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('$quizName (Failed Result)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF00AFEE),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.close, color: Colors.red, size: 50),
            const SizedBox(height: 20),
            Text(
              'Oops! You Failed the Quiz',
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'You need at least 80% to pass.',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Obtained Percentage: $obtainedPercentage',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 20),
                Text(
                  'Passing Percentage: $passingPercentage',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton(
                onPressed: () {
                  Get.back(); // Navigate back to StartQuizScreen or restart logic
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00AFEE)),
                child: Text(
                  'Retry',
                  style: TextStyle(fontSize: 20.sp, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
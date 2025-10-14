import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

import 'leaderboard_screen.dart';

class QuizResult extends StatelessWidget {
  final Map<String, dynamic> resultData;

  QuizResult({Key? key, required this.resultData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final examQuestions = resultData['examQuestions'] ?? [];
    final totalScore = resultData['TotalScore']?.toString() ?? '0';
    final yourScore = resultData['YourScore']?.toString() ?? '0';
    final quizId = resultData['quizID']?.toString() ?? '0';


    return Scaffold(
      appBar: AppBar(
        title: Text('${resultData['quizName'] ?? 'Test Quiz'}(Your Result)'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
            color: Color(0xFF00AFEE),
            fontSize: 24.sp,
            fontWeight: FontWeight.bold),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Score: $totalScore',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18.sp),
                ),
                Text(
                  'Your Score: $yourScore',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18.sp),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.builder(
                itemCount: examQuestions.length,
                itemBuilder: (context, index) {
                  final question = examQuestions[index];
                  final selectedOption = question['options'].firstWhere(
                        (option) => option['user_answer'] != null && option['user_answer'] is bool,
                    orElse: () => {'name': 'Not Answered', 'user_answer': null},
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question['name'],
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16.sp),
                      ),
                      SizedBox(height: 8.h),
                      ...question['options'].map<Widget>((option) {
                        final hasUserAnswer = option['user_answer'] != null;
                        final isSelected = hasUserAnswer && option['user_answer'] == true;
                        final isIncorrect = hasUserAnswer && option['user_answer'] == false;
                        final optionColor = isSelected
                            ? Colors.green
                            : isIncorrect
                            ? Colors.red
                            : Colors.grey;
                        final icon = isSelected
                            ? Icons.check
                            : isIncorrect
                            ? Icons.close
                            : null;

                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          child: Row(
                            children: [
                              Icon(
                                icon,
                                color: optionColor,
                                size: 16.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                option['name'],
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: optionColor,
                                  fontWeight: isSelected || isIncorrect ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      SizedBox(height: 16.h),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 175.w,
                    height: 55.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                      child: Text('BACK TO QUIZ', style: TextStyle(color: Colors.black, fontSize: 16.sp)),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Container(
                    width: 175.w,
                    height: 55.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(()=> LeaderboardScreen(quizId: quizId));

                        // Navigate to leaderboard if needed
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00AFEE)),
                      child: Text('LEADERBOARD', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
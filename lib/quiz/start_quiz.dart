import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:learn_megnagmet/quiz/quiz_failed_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/quiz/quiz_result.dart';
import 'package:learn_megnagmet/widget/button.dart';

import '../utils/api_constant.dart';

class StartQuizScreen extends StatefulWidget {
  final String quizId;
  final String quizName;
  final String quizType;
  final Map<String, dynamic> startQuizResponse;

  const StartQuizScreen({
    Key? key,
    required this.quizId,
    required this.quizName,
    required this.quizType,
    required this.startQuizResponse,
  }) : super(key: key);

  @override
  State<StartQuizScreen> createState() => _StartQuizScreenState();
}

class _StartQuizScreenState extends State<StartQuizScreen> {
  late Timer _timer;
  late int _secondsRemaining;
  late double _progress;
  String? _selectedAnswer;
  late Map<String, dynamic> _currentQuizData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentQuizData = widget.startQuizResponse;
    _secondsRemaining = _parseTimeToSeconds(_currentQuizData['time_remaining']);
    _progress = double.parse(_currentQuizData['quiz_attempt_progress'].replaceAll('%', '')) / 100;
    _startTimer();
  }

  int _parseTimeToSeconds(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 3600 + int.parse(parts[1]) * 60 + int.parse(parts[2]);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer.cancel();
        }
      });
    });
  }

  Future<Map<String, dynamic>> _submitAnswer(String questionUuid, String selectedOptionUuid, int takeExamId) async {
    const String apiUrl = '${ApiConstant.baseUrl}student/course/submit-quiz-answer-api';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'question_uuid': questionUuid,
          'selected_option_uuid': selectedOptionUuid,
          'take_exam_id': takeExamId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to submit answer');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  void _updateProgress() {
    setState(() {
      _progress = double.parse(_currentQuizData['quiz_attempt_progress'].replaceAll('%', '')) / 100;
    });
  }

  void _handleSubmit() async {
    if (_selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an answer!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final currentQuestion = _currentQuizData['question'];
    final selectedOption = currentQuestion['question_options'].firstWhere(
          (option) => option['option_name'] == _selectedAnswer,
      orElse: () => null,
    );

    if (selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected option not found!')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    bool isLastQuestion = _currentQuizData['current_question_no'] == _currentQuizData['total_questions'];

    try {
      final response = await _submitAnswer(
        _currentQuizData['question']['question_uuid'],
        selectedOption['option_uuid'],
        _currentQuizData['take_exam_id'],
      );

      if (isLastQuestion) {
        final normalizedData = response;
        final obtainedPercentage = normalizedData['obtained_percentage'] ?? '';
        print('Check obtained per ${obtainedPercentage}');
        final examQuestions = normalizedData['examQuestions'] as List<dynamic>? ?? [];
        for (var question in examQuestions) {
          for (var option in question['options']) {
            if (option['answer_class'] == 'given-answer-right') {
              option['user_answer'] = true;
            } else if (option['answer_class'] == 'given-answer-wrong') {
              option['user_answer'] = false;
            }
            option.remove('answer_class');
          }
        }

        final resultData = {
          'quizID': normalizedData['quizID'] ?? widget.quizId,
          'courseSlug': normalizedData['courseSlug'] ?? '',
          'quizName': normalizedData['quizName'] ?? widget.quizName,
          'TotalScore': normalizedData['TotalScore'] ?? 0,
          'YourScore': normalizedData['YourScore'] ?? 0,
          'examQuestions': examQuestions,
          'action_api_routes': normalizedData['action_api_routes'] ?? {},
        };
        if (obtainedPercentage >=80) {
          Get.off(() => QuizResult(resultData: resultData));
        }
        else
        {
          Get.off ( () => QuizResultFailed(normalizedData: normalizedData)
          );
        }
      }
      else {
        setState(() {
          _currentQuizData = response['data'] ?? {};
          _selectedAnswer = null;
          _updateProgress();
        });
      }

    } catch (e) {
      print('Error submitting answer: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String timeRemaining = '${(_secondsRemaining ~/ 3600).toString().padLeft(2, '0')}:'
        '${((_secondsRemaining % 3600) ~/ 60).toString().padLeft(2, '0')}:'
        '${(_secondsRemaining % 60).toString().padLeft(2, '0')}';
    final currentQuestion = _currentQuizData['question'];
    final questionOptions = currentQuestion['question_options'];
    final buttonText = _currentQuizData['current_question_no'] == _currentQuizData['total_questions']
        ? 'Submit'
        : 'Next';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.quizName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF00AFEE),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.grey[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.quizName,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.blue[900]),
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentQuizData['current_question_no']} of ${_currentQuizData['total_questions']}',
                  style: TextStyle(fontSize: 16.sp, color: Colors.blue[900]),
                ),
                Text(
                  'Time remaining: $timeRemaining',
                  style: TextStyle(fontSize: 16.sp, color: Colors.blue[900]),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey[300],
              color: const Color(0xFF00AFEE),
              minHeight: 10.h,
            ),
            SizedBox(height: 20.h),
            Text(
              currentQuestion['question_name'],
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20.h),
            ...List.generate(questionOptions.length, (index) {
              final option = questionOptions[index];
              return RadioListTile<String>(
                title: Text(option['option_name']),
                value: option['option_name'],
                groupValue: _selectedAnswer,
                activeColor: Colors.red,
                onChanged: (value) {
                  setState(() {
                    _selectedAnswer = value;
                  });
                },
              );
            }),
            const Spacer(),
            Center(
              child: SizedBox(
                height: 55.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomButton(
                      onTap: _handleSubmit,
                      buttonText: _isLoading ? '' : buttonText,
                      buttonColor: const Color(0xFF00AFEE),
                      textColor: Colors.white,
                    ),
                    if (_isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.0,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
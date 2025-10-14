import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../quiz/start_quiz.dart';
import '../utils/api_constant.dart';
import 'package:learn_megnagmet/quiz/leaderboard_screen.dart';
import 'package:learn_megnagmet/quiz/quiz_result.dart';
import 'package:learn_megnagmet/widget/button.dart';

class QuizPage extends StatefulWidget {
  final List<dynamic> quizData; final String courseId; const
  QuizPage({Key? key, required this.quizData,
    required this.courseId}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final Map<int, bool> _isLoadingAction = {};
  final Map<int, bool> _isLoadingLeaderboard = {};

  List<dynamic> quizData = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchQuizList();
  }

  Future<Map<String, dynamic>> _fetchQuizResult(String quizId) async {
    const String apiUrl = '${ApiConstant.baseUrl}student/course/quiz-result';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'quiz_id': quizId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load quiz result data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> _startQuiz(String quizUuid) async {
    const String apiUrl = '${ApiConstant.baseUrl}student/course/start-quiz';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'quiz_uuid': quizUuid}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to start quiz');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> _fetchQuizList() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final String apiUrl =
          "${ApiConstant.baseUrl}student/course/quiz-list/${widget.courseId}";

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Quiz list fetched successfully: ${response.body}');
        setState(() {
          quizData = data["course_quiz_tab"] ?? [];
        });
      } else {
        print('Failed to fetch quiz list: ${response.body}');
      }
    } catch (e) {
      print('Error fetching quiz list: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getButtonText(int statusNumber) {
    switch (statusNumber) {
      case 1:
        return 'Start Quiz';
      case 2:
        return 'Retry';
      case 3:
        return 'See Result';
      default:
        return 'Unknown';
    }
  }

  void _handleButtonAction(int index, int statusNumber, String quizId,
      String quizName, String quizType, String quizUuid) async {
    if (_isLoadingAction[index] == true) return;

    setState(() {
      _isLoadingAction[index] = true;
    });

    try {
      if (statusNumber == 1 || statusNumber == 2) {
        final response = await _startQuiz(quizUuid);
        await Get.to(() => StartQuizScreen(
          quizId: quizId,
          quizName: quizName,
          quizType: quizType,
          startQuizResponse: response['data'],
        ));
        _fetchQuizList();
      } else if (statusNumber == 3) {
        final resultData = await _fetchQuizResult(quizId);
        await Get.to(() => QuizResult(resultData: resultData));
        _fetchQuizList();
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAction[index] = false;
        });
      }
    }
  }

  void _handleLeaderboardAction(int index, String quizId) async {
    if (_isLoadingLeaderboard[index] == true) return;

    setState(() {
      _isLoadingLeaderboard[index] = true;
    });

    try {
     await Get.to(() => LeaderboardScreen(quizId: quizId));
     _fetchQuizList();
    } catch (e) {
      print('Error navigating to leaderboard: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLeaderboard[index] = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00AFEE),)),
      );
    }

    // if (errorMessage != null) {
    //   return Scaffold(
    //     body: Center(
    //       child: Text(
    //         errorMessage!,
    //         style: const TextStyle(color: Colors.red),
    //       ),
    //     ),
    //   );
    // }

    if (quizData.isEmpty || quizData == null) {
      return const Scaffold(
        body: Center(child: Text("No quizzes available.")),
      );
    }

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: quizData.length,
        itemBuilder: (context, index) {
          final quiz = quizData[index];
          _isLoadingAction.putIfAbsent(index, () => false);
          _isLoadingLeaderboard.putIfAbsent(index, () => false);
          final statusNumber = quiz['status_number'] ?? 0;
          final quizUuid = quiz['quiz_uuid']?.toString() ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
                _buildInfoRow('Quiz Name', quiz['quiz_name']),
                SizedBox(height: 10.h),
                _buildInfoRow('Quiz Type', quiz['quiz_type']),
                SizedBox(height: 10.h),
                _buildInfoRow('Total Questions', quiz['total_questions']),
                SizedBox(height: 10.h),
                _buildInfoRow('Time Duration', quiz['time_duration']),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50.h,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomButton(
                              onTap: () => _handleButtonAction(
                                index,
                                statusNumber,
                                quiz['quiz_id'].toString(),
                                quiz['quiz_name'].toString(),
                                quiz['quiz_type'].toString(),
                                quizUuid,
                              ),
                              buttonText: _isLoadingAction[index]!
                                  ? ''
                                  : _getButtonText(statusNumber),
                              buttonColor: const Color(0xFF00AFEE),
                              textColor: Colors.white,
                            ),
                            if (_isLoadingAction[index]!)
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
                    SizedBox(width: 7.w),
                    Expanded(
                      child: SizedBox(
                        height: 50.h,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomButton(
                              onTap: () => _handleLeaderboardAction(
                                index,
                                quiz['quiz_id'].toString(),
                              ),
                              buttonText: _isLoadingLeaderboard[index]!
                                  ? ''
                                  : 'LeaderBoard',
                              buttonColor: const Color(0xFF00AFEE),
                              textColor: Colors.white,
                            ),
                            if (_isLoadingLeaderboard[index]!)
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
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        Text(
          value?.toString() ?? '',
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
      ],
    );
  }
}

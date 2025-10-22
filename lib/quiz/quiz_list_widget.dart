import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:learn_megnagmet/quiz/delete_true_false_question_dialogbox.dart';
import 'package:learn_megnagmet/quiz/edit_quiz_screen.dart';
import 'package:learn_megnagmet/quiz/true_false_quiz_question_list.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constant.dart';
import '../widget/button.dart';
import 'add_quiz_question_form.dart';
import 'add_true_false_question_screen.dart';

class QuizListWidget extends StatefulWidget {
  final String courseId;
  const QuizListWidget({Key? key, required this.courseId}) : super(key: key);

  @override
  State<QuizListWidget> createState() => _QuizListWidgetState();
}

class _QuizListWidgetState extends State<QuizListWidget> {
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

  Future<void> _fetchQuizList() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final String apiUrl =
          "${ApiConstant.baseUrl}instructor/course/exam/${widget.courseId}";

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
          quizData = data["data"]["quiz_list"] ?? [];
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

  // New method to change quiz status
  Future<void> _changeQuizStatus(String quizId, String status) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final String apiUrl =
          "${ApiConstant.baseUrl}instructor/course/exam/status_change";

      final Map<String, String> body = {
        'quiz_id': quizId,
        'status': status,
      };

      print('Changing quiz status: $body');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Status changed successfully: ${response.body}');

        // Show success message
        Get.snackbar(
          'Success',
          'Quiz status changed to $status',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Refresh the quiz list
        await _fetchQuizList();
      } else {
        print('Failed to change quiz status: ${response.body}');
        Get.snackbar(
          'Error',
          'Failed to change quiz status',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error changing quiz status: $e');
      Get.snackbar(
        'Error',
        'An error occurred while changing quiz status',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00AFEE)));
    }

    if (quizData.isEmpty) {
      return const Center(child: Text("No quizzes available."));
    }

    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: quizData.length,
          itemBuilder: (context, index) {
            final quiz = quizData[index];
            _isLoadingAction.putIfAbsent(index, () => false);
            _isLoadingLeaderboard.putIfAbsent(index, () => false);
            final status = quiz['status'] ?? 'Unknown';
            final quizUuid = quiz['uuid']?.toString() ?? '';
            final quizId = quiz['id']?.toString() ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Quiz Name', quiz['name']),
                  SizedBox(height: 10.h),
                  _buildInfoRow('Quiz Type', quiz['type']),
                  SizedBox(height: 10.h),
                  _buildInfoRow('Total Questions', quiz['total_questions']),
                  SizedBox(height: 10.h),
                  _buildInfoRow('Status', _buildStatusContainer(status)),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 250.w,height: 55.h,
                        child: CustomButton(
                          onTap: () {
                            final quizType = quiz['type']?.toString() ?? '';
                            final quizId = int.parse(quiz['id'].toString());

                            // ✅ DEBUG: Print EXACT value with quotes!
                            print('🔍 DEBUG Quiz $quizId: Type = "$quizType" | Length = ${quizType.length}');

                            // ✅ FIXED: TRIM SPACES + Flexible matching
                            final cleanType = quizType.trim();

                            if (cleanType.contains('Multiple') || cleanType.contains('MCQ')) {
                              print('✅ GOING TO: Multiple Choice Form');
                              Get.to(() => AddQuizQuestionForm(
                                courseId: widget.courseId,
                                quizId: quizId,
                              ));
                            } else {
                              print('✅ GOING TO: True False Form');
                              Get.to(() => AddTrueFalseQuestionScreen(
                                courseId: widget.courseId,
                                quizId: quizId,
                              ));
                            }
                          },
                          buttonText: 'Add Question',
                          buttonColor: Colors.blue[100]!,
                          textColor: Colors.blue,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_horiz, color: Colors.grey[600]),
                        onSelected: (String value) async {
                          switch (value) {
                            case 'Published':
                              print('📢 Setting quiz to Published: $quizUuid');
                              await _changeQuizStatus(quizId, 'Published');
                              break;
                            case 'Unpublished':
                              print('🔇 Setting quiz to Unpublished: $quizUuid');
                              await _changeQuizStatus(quizId, 'Unpublished');
                              break;
                            case 'view':
                              Get.to(() => TrueFalseQuizListScreen(
                                quizId: int.parse(quizId.toString()),
                              ));
                              break;
                            case 'edit':
                              await Get.to(() => EditQuizScreen(
                                quizId: int.parse(quizId.toString()),
                              ));
                              _fetchQuizList();
                              break;
                            case 'delete':
                              Get.dialog(
                                DeleteTrueFalseQuestionDialogbox(
                                  onDelete: () async {
                                    await _fetchQuizList();
                                    if (mounted) {
                                      Get.snackbar(
                                        'Success',
                                        'Quiz deleted successfully',
                                        snackPosition: SnackPosition.TOP,
                                        backgroundColor: Colors.green,
                                        colorText: Colors.white,
                                      );
                                    }
                                  },
                                  onCancel: () => Navigator.pop(context),
                                  quizId: int.parse(quizId.toString()),
                                ),
                              );
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          final status = quiz['status']?.toString() ?? 'Unknown';
                          return <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: status == 'Published' ? 'Unpublished' : 'Published',
                              child: Text(status == 'Published' ? 'Unpublished' : 'Published'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'view',
                              child: Text('View'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ];
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style:  TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600])),
        value is Widget ? value : Text(
          value?.toString() ?? '',
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildStatusContainer(String status) {
    Color containerColor = status == 'Published' ? Colors.green[100]! : Colors.yellow[100]!;
    Color textColor = status == 'Published' ? Colors.green[900]! : Colors.yellow[900]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: containerColor,
        border: Border.all(color: textColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(color: textColor, fontSize: 14),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/quiz/delete_quiz_question_dialogbox.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:learn_megnagmet/quiz/add_true_false_question_screen.dart';
import 'package:learn_megnagmet/quiz/create_quiz_list.dart';
import 'package:learn_megnagmet/utils/api_constant.dart';
import '../widget/button.dart';
import 'delete_true_false_question_dialogbox.dart';
import 'edit_true_false_question_screen.dart'; // You'll need to create this

class TrueFalseQuizListScreen extends StatefulWidget {
  final int quizId;
  const TrueFalseQuizListScreen({
    super.key,
    required this.quizId
  });

  @override
  _TrueFalseQuizListScreenState createState() => _TrueFalseQuizListScreenState();
}

class _TrueFalseQuizListScreenState extends State<TrueFalseQuizListScreen> {
  List<Map<String, dynamic>> quizData = [];
  bool isLoading = true;
  Map<int, int> questionIds = {}; // Store question ID with index
  String courseId = '';
  String courseName = '';
  String quizName = '';

  @override
  void initState() {
    super.initState();
    _fetchQuizData();
  }

  Future<void> _fetchQuizData() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = Uri.parse("${ApiConstant.baseUrl}instructor/course/exam/view_true_false/${widget.quizId}");

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          final questions = data['data']['questions'] as List<dynamic>;
          // ✅ FETCH courseId, courseName, quizName from API response
          courseId = data['data']['course_id'].toString();
          courseName = data['data']['course_title'];
          quizName = data['data']['name'];

          print('Fetched Course ID: $courseId');
          print('Fetched Course Name: $courseName');
          print('Fetched Quiz Name: $quizName');

          setState(() {
            quizData = questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              // ✅ Get True/False options and correct answer
              final trueOption = (question['options'] as List<dynamic>)
                  .firstWhere((option) => option['name'] == 'True');
              final falseOption = (question['options'] as List<dynamic>)
                  .firstWhere((option) => option['name'] == 'False');

              final correctAnswer = trueOption['is_correct_answer'] as bool
                  ? 'True'
                  : 'False';

              questionIds[index] = question['id'] as int; // Store question id
              return {
                'question_name': question['name'],
                'correct_answer': correctAnswer,
              };
            }).toList();
            isLoading = false;
            print('Fetched questionIds: $questionIds');
          });
        } else {
          Get.snackbar('Error', 'Failed to load quiz data: ${data['message']}',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white);
          setState(() {
            isLoading = false;
          });
        }
      } else {
        Get.snackbar('Error', 'Failed to load quiz data: ${response.statusCode}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('True False list api getting error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showDeleteDialog(int index) {
    print('Attempting to delete index: $index, questionId: ${questionIds[index]}');
    if (!questionIds.containsKey(index) || questionIds[index] == null) {
      Get.snackbar('Error', 'Invalid question index or ID',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }
    Get.dialog(
      DeleteQuizQuestionDialogbox( // Use your true false delete dialog
        onDelete: () async {
          await _fetchQuizData(); // Refresh data from API
          Get.snackbar('Success', 'Question deleted successfully',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green,
              colorText: Colors.white);
        },
        onCancel: () => Navigator.pop(context),
        questionId: questionIds[index],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFF00AFEE),
          ),
        ),
      );
    }

    if (quizData.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('True/False Questions',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF00AFEE),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(child: Text("No questions available.")),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: CustomButton(
            //     onTap: () {
            //       Get.to(() => AddTrueFalseQuestionScreen(
            //         courseId: widget.courseId,
            //         quizId: widget.quizId,
            //       ));
            //     },
            //     buttonText: 'Add Question',
            //   ),
            // ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('$quizName Questions',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF00AFEE),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: quizData.length,
              itemBuilder: (context, index) {
                final quiz = quizData[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        'Question',
                        quiz['question_name'],
                        flex: 2,
                        maxLines: 3,
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 10),
                      _buildInfoRow(
                        'Correct Answer',
                        quiz['correct_answer'],
                        flex: 1,
                        isCorrect: true,
                      ),
                      const SizedBox(height: 10),
                      _buildInfoRow('Action', '', flex: 1, isAction: true,
                          onDelete: () => _showDeleteDialog(index), index: index),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: CustomButton(
              onTap: () {
                Get.to(() => CreateQuizList(courseId: courseId, courseName: courseName));
              },
              buttonText: 'Back to Quiz',
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       CustomButton(
          //         onTap: () {
          //           Get.to(() => CreateQuizList(courseId: courseId, courseName: courseName));
          //         },
          //         buttonText: 'Back to Quiz',
          //       ),
          //       // CustomButton(
          //       //   onTap: () {
          //       //     Get.to(() => AddTrueFalseQuestionScreen(
          //       //       courseId: courseId,
          //       //       quizId: widget.quizId,
          //       //     ));
          //       //   },
          //       //   buttonText: 'Add Question',
          //       // ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value,
      {int flex = 1,
        int maxLines = 1,
        bool isCorrect = false,
        bool isAction = false,
        TextAlign textAlign = TextAlign.right,
        VoidCallback? onDelete,
        int? index
      }) {
    return Row(
      children: [
        Expanded(
          flex: flex,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            textAlign: TextAlign.left,
          ),
        ),
        if (isAction)
          Expanded(
            flex: flex,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey),
                  onPressed: () {
                    Get.to(() => EditTrueFalseQuestionScreen(
                      quizId: widget.quizId,
                      questionId: questionIds[index!],
                    )
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.grey),
                  onPressed: onDelete,
                ),
              ],
            ),
          )
        else if (isCorrect)
          Expanded(
            flex: flex,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.check, color: Colors.green),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    value?.toString() ?? '',
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    textAlign: textAlign,
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
        else
          Expanded(
            flex: flex,
            child: Text(
              value?.toString() ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.black),
              textAlign: textAlign,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
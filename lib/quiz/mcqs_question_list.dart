import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widget/button.dart';
import 'package:learn_megnagmet/utils/api_constant.dart';
import 'delete_quiz_question_dialogbox.dart'; // Import the dialog

class McqsQuestionList extends StatefulWidget {
  final int quizId;
  const McqsQuestionList({super.key, required this.quizId});

  @override
  _McqsQuestionListState createState() => _McqsQuestionListState();
}

class _McqsQuestionListState extends State<McqsQuestionList> {
  List<Map<String, dynamic>> quizData = [];
  bool isLoading = true;
  Map<int, int> questionIds = {}; // Store question ID with index

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

      final url = Uri.parse("${ApiConstant.baseUrl}instructor/course/exam/view_mcq/${widget.quizId}");

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
          setState(() {
            quizData = questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              final options = (question['options'] as List<dynamic>)
                  .map((option) => option['name'] as String)
                  .toList();
              final correctOption = (question['options'] as List<dynamic>)
                  .indexWhere((option) => option['is_correct_answer'] as bool);
              questionIds[index] = question['id'] as int; // Use index as key, store question id
              return {
                'quiz_name': question['name'],
                'options': options,
                'correct_option': correctOption,
              };
            }).toList();
            isLoading = false;
            print('Fetched questionIds: $questionIds'); // Debug log
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
      print('MCQS list api getting error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showDeleteDialog(int index) {
    print('Attempting to delete index: $index, questionId: ${questionIds[index]}'); // Debug log
    if (!questionIds.containsKey(index) || questionIds[index] == null) {
      Get.snackbar('Error', 'Invalid question index or ID',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }
    Get.dialog(
      DeleteQuizQuestionDialogbox(
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
      return const Scaffold(
        body: Center(child: Text("No quizzes available.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MCQs List',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                        quiz['quiz_name'],
                        flex: 2,
                        maxLines: 3,
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 10),
                      for (int optionIndex = 0; optionIndex < 4; optionIndex++)
                        _buildInfoRow(
                          'Option ${optionIndex + 1}',
                          optionIndex < quiz['options'].length
                              ? quiz['options'][optionIndex]
                              : '',
                          flex: 1,
                          isCorrect: quiz['correct_option'] == optionIndex,
                        ),
                      const SizedBox(height: 10),
                      _buildInfoRow('Action', '', flex: 1, isAction: true, onDelete: () => _showDeleteDialog(index)),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomButton(
              onTap: () => Navigator.pop(context),
              buttonText: 'Back to Quiz',
              buttonColor: const Color(0xFF00AFEE),
              textColor: Colors.white,
            ),
          ),
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
        VoidCallback? onDelete}) {
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
                  onPressed: () {},
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
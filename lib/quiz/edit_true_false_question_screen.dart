import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:learn_megnagmet/quiz/true_false_quiz_question_list.dart';
import 'package:learn_megnagmet/utils/api_constant.dart';
import '../widget/button.dart';
import '../widget/custom_text_form_field.dart';

class EditTrueFalseQuestionScreen extends StatefulWidget {
  final int quizId;
  final int? questionId;

  const EditTrueFalseQuestionScreen({
    super.key,
    required this.quizId,
    required this.questionId
  });

  @override
  _EditTrueFalseQuestionScreenState createState() => _EditTrueFalseQuestionScreenState();
}

class _EditTrueFalseQuestionScreenState extends State<EditTrueFalseQuestionScreen> {
  final TextEditingController _questionController = TextEditingController();
  int _selectedAnswer = 0; // 0 for True, 1 for False
  bool _isLoadingSave = false;
  bool _isLoadingSaveAnother = false;
  bool _isLoadingData = true; // Loading for fetching data

  @override
  void initState() {
    super.initState();
    _fetchQuestionData(); // Fetch data when screen loads
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  // ✅ NEW: Fetch question data from API
  Future<void> _fetchQuestionData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = Uri.parse("${ApiConstant.baseUrl}instructor/course/exam/edit_quiz_question/${widget.questionId}");

      print('Fetching question data for ID: ${widget.questionId}');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final questionData = data['data']['quiz_question'];
          final options = questionData['options'] as List<dynamic>;

          // ✅ Populate question text
          _questionController.text = questionData['name'] ?? '';

          // ✅ Find correct answer from options
          final trueOption = options.firstWhere((option) => option['option_name'] == 'True');
          if (trueOption['is_correct_answer'] == true) {
            _selectedAnswer = 0; // True
          } else {
            _selectedAnswer = 1; // False
          }

          print('✅ Data populated successfully!');
          print('Question: ${_questionController.text}');
          print('Correct Answer: $_selectedAnswer');
        } else {
          Get.snackbar('Error', 'Failed to load question data: ${data['message']}',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        }
      } else {
        Get.snackbar('Error', 'Failed to load question data: ${response.statusCode}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      print('Error fetching question data: $e');
      Get.snackbar('Error', 'Something went wrong: $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  // API Call Function - FIXED payload key
  Future<void> _saveQuestion({bool isSaveAnother = false}) async {
    // Basic validation
    if (_questionController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a question',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        if (isSaveAnother) _isLoadingSaveAnother = false;
        else _isLoadingSave = false;
      });
      return;
    }

    setState(() {
      if (isSaveAnother) _isLoadingSaveAnother = true;
      else _isLoadingSave = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = Uri.parse("${ApiConstant.baseUrl}instructor/course/exam/update_true_false_question");

      // Prepare the payload - FIXED: 'questionId_id' → 'question_id'
      final isCorrectAnswer = _selectedAnswer == 0 ? 1 : 0; // True = 1, False = 0

      final payload = {
        'question_id': widget.questionId, // ✅ FIXED key name
        'quiz_id': widget.quizId,
        'name': _questionController.text.trim(),
        'is_correct_answer': isCorrectAnswer,
      };

      print('Sending API payload: ${jsonEncode(payload)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // API Success
        print('Question updated successfully: ${response.body}');
        Get.snackbar(
          'Success',
          'True/False question updated successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        if (isSaveAnother) {
          // Reset form for "Save and Another"
          setState(() {
            _questionController.clear();
            _selectedAnswer = 0;
            _isLoadingSaveAnother = false;
          });
        } else {
          // Navigate to question list for "Save"
          Get.back();
          Get.to(() => TrueFalseQuizListScreen(
            quizId: widget.quizId,
          ));
        }
      } else {
        // API Error
        final errorMessage = jsonDecode(response.body)['message'] ?? 'Failed to update question';
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error updating question: $e');
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (!isSaveAnother) setState(() => _isLoadingSave = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFF00AFEE),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit True/False Question',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF00AFEE),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Question',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            CustomTextFormField(
              controller: _questionController,
              hintText: 'Enter your question',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Radio<int>(
                        value: 0,
                        groupValue: _selectedAnswer,
                        onChanged: (_isLoadingSave || _isLoadingSaveAnother)
                            ? null
                            : (value) => setState(() => _selectedAnswer = value!),
                        activeColor: const Color(0xFF00AFEE),
                      ),
                      const Text('True'),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Radio<int>(
                        value: 1,
                        groupValue: _selectedAnswer,
                        onChanged: (_isLoadingSave || _isLoadingSaveAnother)
                            ? null
                            : (value) => setState(() => _selectedAnswer = value!),
                        activeColor: const Color(0xFF00AFEE),
                      ),
                      const Text('False'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 150,
                  child: CustomButton(
                    onTap: () => Navigator.pop(context),
                    buttonText: 'Cancel',
                    buttonColor: Colors.grey[300],
                    textColor: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: CustomButton(
                    onTap:  () => _saveQuestion(),
                    buttonText:  'Save',
                    buttonColor: _isLoadingSave ? Colors.grey : const Color(0xFF00AFEE),
                    textColor: Colors.white,
                    isLoading: _isLoadingSave,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:learn_megnagmet/quiz/mcqs_question_list.dart';
import '../widget/button.dart';
import '../widget/custom_text_form_field.dart';
import 'package:learn_megnagmet/utils/api_constant.dart';

class EditQuizQuestionForm extends StatefulWidget {
  final int quizId;
  final int? questionId;
  const EditQuizQuestionForm({super.key, required this.quizId, required this.questionId});

  @override
  _EditQuizQuestionFormState createState() => _EditQuizQuestionFormState();
}

class _EditQuizQuestionFormState extends State<EditQuizQuestionForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [TextEditingController()];
  int _correctOptionIndex = -1;
  bool _isLoadingSave = false;

  // ✅ Loading state for GET API
  bool _isLoadingGet = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestionData(); // ✅ Call GET API on screen load
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // ✅ GET API to fetch question data
  Future<void> _fetchQuestionData() async {
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
          // ✅ Extract question name
          _questionController.text = data['data']['quiz_question']['name'];

          // ✅ Extract options and populate controllers
          final options = data['data']['quiz_question']['options'] as List<dynamic>;
          _optionControllers.clear();

          for (int i = 0; i < options.length; i++) {
            _optionControllers.add(TextEditingController(text: options[i]['option_name']));

            // ✅ Find correct answer index (0-based)
            if (options[i]['is_correct_answer'] == true) {
              _correctOptionIndex = i;
            }
          }

          // ✅ Ensure we have exactly 4 options
          while (_optionControllers.length < 4) {
            _optionControllers.add(TextEditingController());
          }

          print('✅ Data populated - Question: ${_questionController.text}');
          print('✅ Correct Option Index: $_correctOptionIndex');
        } else {
          Get.snackbar('Error', 'Failed to load question: ${data['message']}',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        }
      } else {
        Get.snackbar('Error', 'Failed to load question: ${response.statusCode}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      print('Error fetching question: $e');
      Get.snackbar('Error', 'Something went wrong: $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      setState(() {
        _isLoadingGet = false; // ✅ Hide loading
      });
    }
  }

  void _addOption() {
    if (_optionControllers.length < 4) {
      setState(() {
        _optionControllers.add(TextEditingController());
      });
    }
  }

  void _setCorrectOption(int index) {
    setState(() {
      _correctOptionIndex = index;
    });
  }

  Future<void> _saveQuestion({bool isSaveAnother = false}) async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _isLoadingSave = false;
      });
      return;
    }

    if (_optionControllers.length < 4) {
      Get.snackbar('Error', 'Please add at least 4 options',
          snackPosition: SnackPosition.TOP, backgroundColor:
          Colors.red, colorText: Colors.white);
      setState(() {
        _isLoadingSave = false;
      });
      return;
    }

    if (_correctOptionIndex == -1) {
      Get.snackbar('Error', 'Please select a correct answer',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red, colorText: Colors.white);
      setState(() {
        _isLoadingSave = false;
      });
      return;
    }

    setState(() {
      _isLoadingSave = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = Uri.parse("${ApiConstant.baseUrl}instructor/course/exam/update_mcq_question");

      // Prepare the payload
      final payload = {
        'question_id': widget.questionId,
        'name': _questionController.text,
        'option_1': _optionControllers.length > 0 ? _optionControllers[0].text : '',
        'option_2': _optionControllers.length > 1 ? _optionControllers[1].text : '',
        'option_3': _optionControllers.length > 2 ? _optionControllers[2].text : '',
        'option_4': _optionControllers.length > 3 ? _optionControllers[3].text : '',
        'is_correct_answer': _correctOptionIndex + 1, // 1-based index for correct answer
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

      if (response.statusCode == 200) {
        print('Question updated successfully: ${response.statusCode}');
        Get.snackbar(
          'Success',
          'MCQ Quiz question updated successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Navigate back to QuizListScreen
        Get.off(() => McqsQuestionList(quizId: widget.quizId));
      } else {
        Get.snackbar(
          'Error',
          'Failed to update question: ${response.statusCode}',
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
    print('Check quiz id and question id ${widget.quizId} and ${widget.questionId}');

    // ✅ Show Circular Progress Indicator while loading
    if (_isLoadingGet) {
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Quiz Question', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF00AFEE),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Question',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _questionController,
                hintText: 'Enter your question',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Question is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Options',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(_optionControllers.length, (index) {
                  return Column(
                    children: [
                      if (index > 0) const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextFormField(
                              controller: _optionControllers[index],
                              hintText: 'Enter option ${index + 1}',
                              maxLines: 1,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Option ${index + 1} is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          Radio<int>(
                            value: index,
                            groupValue: _correctOptionIndex,
                            onChanged: (value) => _setCorrectOption(value!),
                            activeColor: const Color(0xFF00AFEE),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _addOption,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00AFEE),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
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
      ),
    );
  }
}
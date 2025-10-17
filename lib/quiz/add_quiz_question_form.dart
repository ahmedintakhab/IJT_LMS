import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:learn_megnagmet/quiz/mcqs_question_list.dart';
import '../widget/button.dart';
import '../widget/custom_text_form_field.dart';
import 'package:learn_megnagmet/utils/api_constant.dart';

class AddQuizQuestionForm extends StatefulWidget {
  final String courseId;
  final int quizId;
  const AddQuizQuestionForm({super.key, required this.courseId, required this.quizId});

  @override
  _AddQuizQuestionFormState createState() => _AddQuizQuestionFormState();
}

class _AddQuizQuestionFormState extends State<AddQuizQuestionForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [TextEditingController()];
  int _correctOptionIndex = -1;
  bool _isLoadingSave = false;
  bool _isLoadingSaveAnother = false;

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
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
        if (isSaveAnother) _isLoadingSaveAnother = false;
        else _isLoadingSave = false;
      });
      return;
    }

    if (_optionControllers.length < 4) {
      Get.snackbar('Error', 'Please add at least 4 options', snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
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

      final url = Uri.parse("${ApiConstant.baseUrl}instructor/course/exam/save_mcq_question");

      // Prepare the payload
      final payload = {
        'quiz_id': widget.quizId,
        'name': _questionController.text,
        'option_1': _optionControllers.length > 0 ? _optionControllers[0].text : '',
        'option_2': _optionControllers.length > 1 ? _optionControllers[1].text : '',
        'option_3': _optionControllers.length > 2 ? _optionControllers[2].text : '',
        'option_4': _optionControllers.length > 3 ? _optionControllers[3].text : '',
        'is_correct_answer': _correctOptionIndex + 1, // 1-based index for correct answer
      };

      // Print the data before sending to API
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
        print('Question created successfully: ${response.statusCode}');
        Get.snackbar(
          'Success',
          'MCQ Quiz question saved successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        if (isSaveAnother) {
          // Reset form for "Save and Another"
          setState(() {
            _questionController.clear();
            _optionControllers.clear();
            _optionControllers.add(TextEditingController());
            _correctOptionIndex = -1;
            _isLoadingSaveAnother = false;
          });
        } else {
          // Navigate to QuizListScreen for "Save"
          Get.to(() => McqsQuestionList(quizId : widget.quizId));
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to create question: ${response.statusCode}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error creating question: $e');
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Create Quiz', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                'Question 1',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _questionController,
                hintText: 'Enter your question',
                maxLines: 1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Question is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(_optionControllers.length, (index) {
                  return Column(
                    children: [
                      if (index > 0) const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextFormField(
                              controller: _optionControllers[index],
                              hintText: 'Enter option',
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
                    width: 200,
                    child: CustomButton(
                      onTap: () {
                        if (_correctOptionIndex == -1) {
                          Get.snackbar('Error', 'Please select a correct answer', snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
                          return;
                        }
                        _saveQuestion(isSaveAnother: true);
                      },
                      buttonText: 'Save and Another',
                      buttonColor: const Color(0xFF00AFEE),
                      textColor: Colors.white,
                      isLoading: _isLoadingSaveAnother,
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: CustomButton(
                      onTap:  () {
                        if (_correctOptionIndex == -1) {
                          Get.snackbar('Error', 'Please select a correct answer', snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
                          return;
                        }
                        _saveQuestion();
                      },
                      buttonText: 'Save',
                      buttonColor: const Color(0xFF00AFEE),
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
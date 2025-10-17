import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:learn_megnagmet/quiz/add_true_false_question_screen.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:learn_megnagmet/widget/custom_dropdown.dart';
import 'package:learn_megnagmet/widget/custom_text_form_field.dart';
import 'package:learn_megnagmet/utils/api_constant.dart';

import 'add_quiz_question_form.dart'; // Add your ApiConstant import

class CreateQuizForm extends StatefulWidget {
  final String courseId;
  const CreateQuizForm({super.key, required this.courseId});

  @override
  State<CreateQuizForm> createState() => _CreateQuizFormState();
}

class _CreateQuizFormState extends State<CreateQuizForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController quiznameController = TextEditingController();
  TextEditingController quiztypeController = TextEditingController();
  TextEditingController marksController = TextEditingController();
  TextEditingController percentageController = TextEditingController();
  TextEditingController durationController = TextEditingController();

  String? value;
  final List<String> items = ['Multiple Choice', 'True False'];

  // Loading state
  bool isLoading = false;
  int? quizId;

  @override
  void dispose() {
    quiznameController.dispose();
    quiztypeController.dispose();
    marksController.dispose();
    percentageController.dispose();
    durationController.dispose();
    super.dispose();
  }

  // API Call Function
  Future<void> createQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = Uri.parse("${ApiConstant.baseUrl}instructor/course/exam/store");

      // Prepare the payload
      final payload = {
        'course_id': widget.courseId,
        'name': quiznameController.text,
        'type': quiztypeController.text,
        'marks_per_question': int.parse(marksController.text),
        'passing_percentage': double.parse(percentageController.text),
        'duration': int.parse(durationController.text),
      };

      // Print the data before sending to API
      print('Sending API payload: ${jsonEncode(payload)}');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'course_id': widget.courseId,
          'name': quiznameController.text,
          'type': quiztypeController.text,
          'marks_per_question': int.parse(marksController.text),
          'passing_percentage': double.parse(percentageController.text),
          'duration': int.parse(durationController.text),
        }),
      );

      if (response.statusCode == 200 || response.statusCode ==201) {
        // API Success
// Parse API Response
        final responseData = jsonDecode(response.body);
        print('Quiz created successfully: ${response.body}');

        // ✅ FETCH quiz_id FROM RESPONSE
        quizId = responseData['quiz_id'];
        print('Fetched Quiz ID: $quizId');        Get.snackbar(
          'Success',
          'Quiz Created Successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate based on quiz type
        if (quiztypeController.text == 'Multiple Choice') {
          Get.to(() => AddQuizQuestionForm(courseId : widget.courseId,quizId: quizId!,));
        } else if (quiztypeController.text == 'True False') {
          Get.to(() => AddTrueFalseQuestionScreen(courseId: widget.courseId, quizId: quizId!,
          ));
        }
      } else {
        // API Error
        Get.snackbar(
          'Error',
          'Failed to create quiz: ${response.statusCode}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error creating quiz: $e');
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00AFEE),
        title: const Text(
          'Create New Quiz',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20.h),
                CustomTextFormField(
                  controller: quiznameController,
                  hintText: 'Enter Quiz Name',
                  labelText: 'Quiz Name',
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter the quiz name';
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                CustomDropdown(
                  hint: 'Select Type',
                  value: value,
                  items: items,
                  onChanged: (newValue) {
                    setState(() {
                      value = newValue;
                      quiztypeController.text = newValue ?? '';
                    });
                  },
                ),
                SizedBox(height: 20.h),
                CustomTextFormField(
                  controller: marksController,
                  hintText: 'Enter Quiz marks',
                  labelText: 'Quiz Marks',
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter the quiz marks';
                    if (int.tryParse(val) == null || int.parse(val) <= 0) return 'Enter a valid positive number';
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                CustomTextFormField(
                  controller: percentageController,
                  hintText: 'Enter Percentage',
                  labelText: 'Passing Percentage',
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter the marks percentage';
                    if (double.tryParse(val) == null || double.parse(val) < 0 || double.parse(val) > 100) return 'Enter a valid percentage (0-100)';
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                CustomTextFormField(
                  controller: durationController,
                  hintText: 'Enter Quiz Duration',
                  labelText: 'Time Duration (Minutes)',
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter the quiz duration';
                    if (int.tryParse(val) == null || int.parse(val) <= 0) return 'Enter a valid positive number';
                    return null;
                  },
                ),
                SizedBox(height: 30.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 120.w,
                      child: CustomButton(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        buttonText: 'Back',
                        buttonColor: Colors.grey[300],
                        textColor: Colors.black,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    SizedBox(
                      width: 210.w,
                      child: CustomButton(
                        onTap : createQuiz, // Disable when loading
                        buttonText: 'Create',
                        buttonColor: const Color(0xFF00AFEE),
                        textColor: Colors.white,
                        isLoading: isLoading, // Pass loading state
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
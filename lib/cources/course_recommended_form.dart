import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../widget/button.dart';
import '../widget/custom_text_form_field.dart';
import '../utils/api_constant.dart'; // Assuming this contains the baseUrl

// ignore: must_be_immutable
class CourseRecommendedForm extends StatefulWidget {
  final String courseId;
  CourseRecommendedForm({super.key, required this.courseId});

  @override
  State<CourseRecommendedForm> createState() => _CourseRecommendedFormState();
}

class _CourseRecommendedFormState extends State<CourseRecommendedForm> {
  final List<TextEditingController> _emailControllers = [TextEditingController()];
  final List<String?> _emailErrors = [null];
  bool _isLoading = false;

  void _addEmailField() {
    setState(() {
      _emailControllers.add(TextEditingController());
      _emailErrors.add(null);
    });
  }

  void _removeEmailField(int index) {
    setState(() {
      if (_emailControllers.length > 1) {
        _emailControllers.removeAt(index);
        _emailErrors.removeAt(index);
      }
    });
  }

  Future<void> _submitForm() async {
    setState(() {
      _isLoading = true;
      for (int i = 0; i < _emailControllers.length; i++) {
        _emailErrors[i] = null;
      }
    });

    // Validate at least one email
    bool hasValidEmail = false;
    for (int i = 0; i < _emailControllers.length; i++) {
      final email = _emailControllers[i].text.trim();
      if (email.isNotEmpty && RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
        hasValidEmail = true;
        break;
      }
    }

    if (!hasValidEmail) {
      setState(() {
        _isLoading = false;
        for (int i = 0; i < _emailControllers.length; i++) {
          _emailErrors[i] = 'At least one valid email is required';
        }
      });
      return;
    }

    // Prepare email list
    final emails = _emailControllers.map((controller) => controller.text.trim()).where((email) => email.isNotEmpty).toList();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final String apiUrl = "${ApiConstant.baseUrl}send-course-recommendation";

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'course_id': widget.courseId,
          'emails': emails,
        }),
      );

      if (response.statusCode == 200) {
        print('Course recommendation api response: ${response.statusCode}');

        Navigator.pop(context); // Navigate back on success
        Get.snackbar(
          'Success',
    'Quiz Created Successfully!',
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.green,
    colorText: Colors.white,
    );
      } else {
        print('Course recommendation api response: ${response.statusCode}');
        print('Failed to send recommendation: ${response.body}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error sending recommendation: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommend Course', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0XFF00AFEE),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Email input fields with cancel icon and validation error
              for (int i = 0; i < _emailControllers.length; i++)
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            controller: _emailControllers[i],
                            hintText: 'Email',
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Enter the email';
                              } else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val)) {
                                return "Please enter valid email address";
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Container(
                          color: Colors.red,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => _removeEmailField(i),
                          ),
                        ),
                      ],
                    ),
                    if (_emailErrors[i] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          _emailErrors[i]!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    if (i < _emailControllers.length - 1) const SizedBox(height: 20),
                  ],
                ),
              const SizedBox(height: 16),
              // Add Email button
              CustomButton(
                onTap: _addEmailField,
                buttonText: '+ Add Email',
                buttonColor: const Color(0XFF00AFEE),
              ),
              const SizedBox(height: 16),
              // Close and Submit buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 150.w,
                    child: CustomButton(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      buttonText: 'Close',
                      buttonColor: const Color(0XFFFFD700),
                      textColor: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 200.w,
                    child: CustomButton(
                      onTap: _submitForm,
                      buttonText: _isLoading ? '' : 'Submit',
                      buttonColor: const Color(0XFF00AFEE),
                      isLoading: _isLoading,
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

  @override
  void dispose() {
    for (var controller in _emailControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
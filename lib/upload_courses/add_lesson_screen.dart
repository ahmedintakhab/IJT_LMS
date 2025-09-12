import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:learn_megnagmet/widget/custom_text_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/api_constant.dart';

class AddLessonScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback? onBack;

  const AddLessonScreen({super.key, required this.onComplete, this.onBack});

  @override
  State<AddLessonScreen> createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _lessonTitleController = TextEditingController();
  int? courseId;
  bool _isLoading = false; // Added for loading state
  String? courseTitle;

  @override
  void initState() {
    super.initState();
    _loadCourseData();
  }

  Future<void> _loadCourseData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      courseId = prefs.getInt('courseId');
      courseTitle = prefs.getString('courseTitle');
    });
  }

  @override
  void dispose() {
    _lessonTitleController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Print data for debugging
    debugPrint('Submitting data:');
    debugPrint('course_id: $courseId');
    debugPrint('name: ${_lessonTitleController.text}');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = Uri.parse('${ApiConstant.baseUrl}instructor/course/store-lesson');
      var request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields['course_id'] = courseId?.toString() ?? '';
      request.fields['name'] = _lessonTitleController.text;

      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        debugPrint(' Upload course tags API Response : ${response.statusCode}');
        debugPrint('API Response: $responseData');
        // Extract lesson_id from response and store in SharedPreferences
        if (responseData['success'] == true) {
          int lessonId = responseData['data']['lesson_id'];
          await prefs.setInt('lessonId', lessonId);
          debugPrint('Stored lessonId: $lessonId');
        }
        Get.snackbar(
          'Successful', 'Lesson title successfully added',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        widget.onComplete();
      } else {
        debugPrint('Add lesson title API Error: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      debugPrint('Add lesson title api error catch: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(26.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'To Upload your course videos please create your section and lesson details first!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Section title of the courses, ${courseTitle ?? 'Course Title'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFF00AFEE),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextFormField(
                          controller: _lessonTitleController,
                          hintText: 'Enter Lesson Title',
                          labelText: 'Lesson Title',
                          validator: (val) =>
                          val?.isEmpty ?? true ? 'Lesson title is required' : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 100.w,
                    child: CustomButton(
                      onTap: () {
                        if (widget.onBack != null) {
                          widget.onBack!();
                        }
                      },
                      buttonText: 'Back',
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: CustomButton(
                      onTap: _submitForm,
                      buttonText: 'Save and Continue',
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
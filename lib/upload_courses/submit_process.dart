import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:learn_megnagmet/widget/button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../instructor/instructor_courses.dart';
import '../utils/api_constant.dart';

class SubmitProcessScreen extends StatefulWidget {
  // final VoidCallback onSubmit;
  final VoidCallback? onBack;

  const SubmitProcessScreen({super.key,  this.onBack});

  @override
  State<SubmitProcessScreen> createState() => _SubmitProcessScreenState();
}

class _SubmitProcessScreenState extends State<SubmitProcessScreen> {
  int? courseId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCourseId();
  }

  Future<void> _loadCourseId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      courseId = prefs.getInt('courseId');
      print('Fetched courseId: $courseId');
    });
  }

  Future<void> _submitCourse() async {
    if (courseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course ID is missing')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = Uri.parse('${ApiConstant.baseUrl}instructor/course/submit/$courseId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('GET API Response Status: ${response.statusCode}');
      print('GET API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          Get.snackbar(
            'Success',
            'Course submitted for Review!',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          // widget.onSubmit();
          Get.off(() => InstructorCourses());
        } else {
          print('Failed to submit course: ${jsonResponse['message']}');
        }
      } else {
        print('Failed to submit course: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting course: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Submit Process',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Review and submit your course',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 100,
                      child: CustomButton(
                        onTap: () {
                          if (widget.onBack != null) {
                            widget.onBack!();
                          }
                        },
                        buttonText: 'Back',
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: CustomButton(
                        onTap: _submitCourse,
                        buttonText: 'Submit Course',
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
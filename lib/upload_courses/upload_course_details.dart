// File: upload_course_details.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:learn_megnagmet/widget/button.dart';
import '../utils/api_constant.dart';
import '../widget/custom_text_form_field.dart';

class UploadCourseDetails extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback? onBack;

  const UploadCourseDetails({super.key, required this.onComplete, this.onBack});
  @override
  State<UploadCourseDetails> createState() => _UploadCourseDetailsState();
}

class _UploadCourseDetailsState extends State<UploadCourseDetails> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urTitleController = TextEditingController();
  final TextEditingController _subTitleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<TextEditingController> keyPointControllers = [];
  bool _isLoading = false; // For showing progress on button
  int? courseId; // Store course_id from API response

  @override
  void initState() {
    super.initState();
    keyPointControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urTitleController.dispose();
    _subTitleController.dispose();
    _descriptionController.dispose();
    for (var controller in keyPointControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addKeyPoint() {
    setState(() {
      keyPointControllers.add(TextEditingController());
    });
  }

  void _removeKeyPoint(int index) {
    if (keyPointControllers.length > 1) {
      setState(() {
        keyPointControllers[index].dispose();
        keyPointControllers.removeAt(index);
      });
    }
  }

  String? _titleValidator(String? value) {
    if (_titleController.text.isEmpty && _urTitleController.text.isEmpty) {
      return 'Either Course Title or Course Title (Ur) is required';
    }
    return null;
  }

  String? _urTitleValidator(String? value) {
    if (_titleController.text.isEmpty && _urTitleController.text.isEmpty) {
      return 'Either Course Title or Course Title (Ur) is required';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = Uri.parse('${ApiConstant.baseUrl}instructor/course/store');

      List<String> keyPoints =
      keyPointControllers.map((c) => c.text.trim()).toList();
      print('title: ${_titleController.text}');
      print('title: ${_urTitleController.text}');
      print('title: ${_subTitleController.text}');
      print('title: $keyPoints');
      print('title: ${_descriptionController.text}');

      final body = {
        "title": _titleController.text.trim(),
        "title_ur": _urTitleController.text.trim(),
        "subtitle": _subTitleController.text.trim(),
        "key_points": keyPoints,
        "description": _descriptionController.text.trim(),
      };

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Upload course api response: ${response.statusCode}');

        if (responseData["success"] == true) {
          setState(() {
            courseId = responseData["data"]["course_id"];
          });
          // Save courseId into SharedPreferences
          await prefs.setInt('courseId', courseId!);

          debugPrint("Course stored successfully. ID: $courseId");
          Get.snackbar(
            'Successful', 'Course stored successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          widget.onComplete(); // Continue flow
        } else {
          print(responseData["message"]);
        }
      } else {
        print("Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // void _showError(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Title
                      CustomTextFormField(
                        controller: _titleController,
                        hintText: 'Enter course title',
                        labelText: 'Course Title',
                        validator: _titleValidator,
                      ),
                      SizedBox(height: 16.h),

                      // Course Title (Ur)
                      CustomTextFormField(
                        controller: _urTitleController,
                        hintText: 'Enter course title (Ur)',
                        labelText: 'Course Title (Ur)',
                        validator: _urTitleValidator,
                      ),
                      SizedBox(height: 16.h),

                      // Course Sub Title
                      CustomTextFormField(
                        controller: _subTitleController,
                        hintText: 'Enter course sub title',
                        labelText: 'Course Sub Title',
                        maxLines: 4,
                        validator: (val) =>
                        val?.isEmpty ?? true ? 'Required' : null,
                      ),
                      SizedBox(height: 16.h),

                      // Course Key Points
                      Text(
                        'Course Description Key Points *',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: const Color(0xFF00AFEE),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Name',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      ...keyPointControllers.asMap().entries.map((entry) {
                        int index = entry.key;
                        TextEditingController controller = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomTextFormField(
                                  controller: controller,
                                  hintText: 'Type key point name',
                                  validator: (val) =>
                                  val?.isEmpty ?? true ? 'Required' : null,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              ElevatedButton(
                                onPressed: () => _removeKeyPoint(index),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  minimumSize: Size(40.w, 40.h),
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 24.sp,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      TextButton(
                        onPressed: _addKeyPoint,
                        child: Text('+ Add'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF00AFEE),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Course Description
                      CustomTextFormField(
                        controller: _descriptionController,
                        hintText: 'Enter course description',
                        labelText: 'Course Description',
                        maxLines: 4,
                        validator: (val) =>
                        val?.isEmpty ?? true ? 'Required' : null,
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),

            // Buttons Row
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 100.w,
                    child: CustomButton(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      buttonText: 'Cancel',
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: CustomButton(
                      onTap: _submitForm,
                      buttonText: 'Save and Continue',
                      isLoading: _isLoading, // 👈 use your loading logic here
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

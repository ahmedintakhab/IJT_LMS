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
  final int courseId;
  final int isEdit;
  final VoidCallback onComplete;
  final VoidCallback? onBack;

  const UploadCourseDetails({
    super.key,
    required this.courseId,
    required this.isEdit,
    required this.onComplete,
    this.onBack,
  });

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
  bool _isLoadingData = false; // For showing circular progress indicator when loading data
  int? courseId; // Store course_id from API response
  String? courseTitle;

  @override
  void initState() {
    super.initState();
    keyPointControllers.add(TextEditingController());

    // Check if isEdit == 1, then call the GET API
    if (widget.isEdit == 1) {
      _loadCourseData();
    }
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

  Future<void> _loadCourseData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = Uri.parse('${ApiConstant.baseUrl}instructor/course/step-zero-edit-data/${widget.courseId}');
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      debugPrint('Load course data API response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData["success"] == true &&
            responseData["data"] != null &&
            responseData["data"].isNotEmpty) {

          final courseData = responseData["data"][0];

          setState(() {
            // Set basic course info
            courseId = courseData["id"];
            _titleController.text = courseData["title"] ?? '';
            _urTitleController.text = courseData["title_ur"] ?? '';
            _subTitleController.text = courseData["subtitle"] ?? '';
            _descriptionController.text = courseData["description"] ?? '';

            // Handle key points
            if (courseData["key_points"] != null && courseData["key_points"].isNotEmpty) {
              // Clear existing controllers
              for (var controller in keyPointControllers) {
                controller.dispose();
              }
              keyPointControllers.clear();

              // Add controllers for each key point
              List<dynamic> keyPoints = courseData["key_points"];
              for (String keyPoint in keyPoints) {
                TextEditingController controller = TextEditingController();
                controller.text = keyPoint;
                keyPointControllers.add(controller);
              }
            }

            // Ensure at least one key point field exists
            if (keyPointControllers.isEmpty) {
              keyPointControllers.add(TextEditingController());
            }
          });

          debugPrint("Course data loaded successfully. ID: $courseId");
          debugPrint("Title: ${_titleController.text}");
          debugPrint("Title UR: ${_urTitleController.text}");
          debugPrint("Subtitle: ${_subTitleController.text}");
          debugPrint("Description: ${_descriptionController.text}");
          debugPrint("Key Points: ${keyPointControllers.map((c) => c.text).toList()}");

        } else {
          debugPrint("No course data found or unsuccessful response");
        }
      } else {
        debugPrint("Failed to load course data with status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('Error loading course data: $e');
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
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

      List<String> keyPoints = keyPointControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      debugPrint('title: ${_titleController.text}');
      debugPrint('title_ur: ${_urTitleController.text}');
      debugPrint('subtitle: ${_subTitleController.text}');
      debugPrint('keyPoints: $keyPoints');
      debugPrint('description: ${_descriptionController.text}');

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
        debugPrint('Upload course api response: ${response.statusCode}');

        if (responseData["success"] == true) {
          setState(() {
            courseId = responseData["data"]["course_id"];
            courseTitle = responseData["data"]["course_title"];
          });
          // Save courseId into SharedPreferences
          await prefs.setInt('courseId', courseId!);
          await prefs.setString('courseTitle', courseTitle!);

          debugPrint("Course stored successfully. ID: $courseId");
          debugPrint("Course stored successfully. Title: $courseTitle");
          Get.snackbar(
            'Successful', 'Course stored successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          widget.onComplete(); // Continue flow
        } else {
          debugPrint(responseData["message"]);
          Get.snackbar(
            'Error', responseData["message"] ?? 'Failed to save course',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        debugPrint("Failed with status: ${response.statusCode}");
        Get.snackbar(
          'Error', 'Failed to save course',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
      Get.snackbar(
        'Error', 'An error occurred while saving the course',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = Uri.parse('${ApiConstant.baseUrl}instructor/course/update-overview');

      List<String> keyPoints = keyPointControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      debugPrint('title: ${_titleController.text}');
      debugPrint('title_ur: ${_urTitleController.text}');
      debugPrint('subtitle: ${_subTitleController.text}');
      debugPrint('keyPoints: $keyPoints');
      debugPrint('description: ${_descriptionController.text}');

      final body = {
        "course_id": widget.courseId,
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
        debugPrint('Upload course api response: ${response.statusCode}');

        if (responseData["success"] == true) {
          setState(() {
            courseId = responseData["data"]["course_id"];
            courseTitle = responseData["data"]["course_title"];
          });
          // Save courseId into SharedPreferences
          await prefs.setInt('courseId', courseId!);
          await prefs.setString('courseTitle', courseTitle!);

          debugPrint("Course stored successfully. ID: $courseId");
          debugPrint("Course stored successfully. Title: $courseTitle");
          Get.snackbar(
            'Successful', 'Course updated successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          widget.onComplete(); // Continue flow
        } else {
          debugPrint(responseData["message"]);
          Get.snackbar(
            'Error', responseData["message"] ?? 'Failed to save course',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        debugPrint("Failed with status: ${response.statusCode}");
        Get.snackbar(
          'Error', 'Failed to update course',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
      Get.snackbar(
        'Error', 'An error occurred while updating the course',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
      body: _isLoadingData
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00AFEE),
        ),
      )
          : Padding(
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
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF00AFEE),
                        ),
                        child: const Text('+ Add'),
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
                      onTap: () {
                        if (widget.isEdit == 0) {
                          _submitForm();
                        } else {
                          _updateCourse();
                        }
                      },
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
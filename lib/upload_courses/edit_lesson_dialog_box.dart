import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learn_megnagmet/widget/custom_text_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/api_constant.dart';

class EditLessonDialogBox extends StatefulWidget {
  final Function(String) onSubmit;

  const EditLessonDialogBox({
    super.key,
    required this.onSubmit,
  });

  @override
  State<EditLessonDialogBox> createState() => _EditLessonDialogBoxState();
}

class _EditLessonDialogBoxState extends State<EditLessonDialogBox> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  int? courseId;
  int? lessonId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCourseIdAndLessonId();
  }

  Future<void> _getCourseIdAndLessonId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      courseId = prefs.getInt('courseId');
      lessonId = prefs.getInt('lessonId');
    });
    if (lessonId != null && lessonId != 0) {
      await _fetchLessonData();
    } else {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No lesson selected')),
        );
      }
    }
  }

  Future<void> _fetchLessonData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = Uri.parse('${ApiConstant.baseUrl}instructor/course/edit-lesson-data/$lessonId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Check Get lesson name api: ${response.statusCode}');
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _nameController.text = data['data']['name'] ?? '';
            lessonId = data['data']['lesson_id'];
            courseId = data['data']['course_id'];
            _isLoading = false;
          });
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to fetch lesson data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching lesson data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching lesson data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitLesson() async {
    if (!_formKey.currentState!.validate() || courseId == null || lessonId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a valid lesson and fill in the name')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = Uri.parse('${ApiConstant.baseUrl}instructor/course/update-lesson');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'course_id': courseId,
          'lesson_id': lessonId,
          'name': _nameController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        print('Check edit lesson api response: ${response.statusCode}');
        widget.onSubmit(_nameController.text.trim());
        Navigator.pop(context);
      } else {
        print('Check edit lesson api response: ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update lesson: ${response.body}')),
          );
        }
      }
    } catch (e) {
      print('Check edit lesson api response: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating lesson: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400.w,
          maxHeight: 400.h,
        ),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Lesson Name',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: const Color(0xFF00AFEE),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: Colors.grey,
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextFormField(
                      controller: _nameController,
                      labelText: 'Name',
                      hintText: 'Enter Lesson Name',
                      validator: (val) =>
                      val?.isEmpty ?? true ? 'Name is required' : null,
                    ),
                    SizedBox(height: 16.h),
                    Center(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitLesson,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00AFEE),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: Size(120, 45),
                        ),
                        child: _isLoading
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text('Submit'),
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
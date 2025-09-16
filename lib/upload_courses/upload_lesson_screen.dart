import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:learn_megnagmet/utils/api_constant.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:learn_megnagmet/widget/custom_text_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'delete_lesson_dialog_box.dart';
import 'edit_lesson_dialog_box.dart';

class UploadLessonScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback? onBack;

  const UploadLessonScreen({super.key, required this.onComplete, this.onBack});

  @override
  State<UploadLessonScreen> createState() => _UploadLessonScreenState();
}

class _UploadLessonScreenState extends State<UploadLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _lessonTitleController = TextEditingController();
  bool _showAddSection = false;
  final TextEditingController _sectionTitleController = TextEditingController();
  int? courseId;
  List<Map<String, dynamic>> lessons = [];
  bool isLoading = true;
  final Map<String, bool> _lessonExpansion = {};

  @override
  void initState() {
    super.initState();
    _getCourseId();
    for (var lesson in lessons) {
      _lessonExpansion[lesson['title']] = false;
    }
  }


  Future<void> _getCourseId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      courseId = prefs.getInt('courseId');
      if (courseId != null) {
        _fetchLessons();
      }
    });
  }

  Future<void> _fetchLessons() async {
    setState(() {
      isLoading = true;
    });
    try {
      final url = Uri.parse('${ApiConstant.baseUrl}instructor/course/step-two-edit-data/$courseId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print('Check upload lessons api response: ${response.statusCode}');
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            lessons = List<Map<String, dynamic>>.from(data['data'][0]['lessons']);
            for (var lesson in lessons) {
              _lessonExpansion[lesson['name']] = false;
            }
            isLoading = false;
          });
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load lessons: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching lessons: $e')),
      );
    }
  }

  @override
  void dispose() {
    _lessonTitleController.dispose();
    _sectionTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(10.w),
        child: Column(
          children: [
            // New Expandable Section List
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section List
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
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
                            'Section list of "Test"',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: const Color(0xFF00AFEE),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          isLoading
                              ? Center(child: CircularProgressIndicator())
                          :ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: lessons.length,
                            itemBuilder: (context, lessonIndex) {
                              final lesson = lessons[lessonIndex];
                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _lessonExpansion[lesson['name']] = !_lessonExpansion[lesson['name']]!;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(8.w),
                                      margin: EdgeInsets.only(bottom: 8.h),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    _lessonExpansion[lesson['name']]!
                                                        ? Icons.keyboard_arrow_up
                                                        : Icons.keyboard_arrow_down,
                                                    color: Colors.black,
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  Text(
                                                    lesson['name'],
                                                    style: TextStyle(fontSize: 16.sp),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(''),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(''),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text('Video (5)'),
                                                  SizedBox(width: 28.w),
                                                  Text('Duration (1 hr 39 min 21 s)'),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (_lessonExpansion[lesson['name']]!)
                                    Column(
                                      children: [
                                        SizedBox(height: 8.h),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemCount: lesson['lectures'].length,
                                          itemBuilder: (context, lectureIndex) {
                                            final lecture = lesson['lectures'][lectureIndex];
                                            return Container(
                                              padding: EdgeInsets.all(8.w),
                                              margin: EdgeInsets.only(bottom: 8.h),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey),
                                                borderRadius: BorderRadius.circular(8.r),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(lecture['title']),
                                                      TextButton(
                                                        onPressed: () {},
                                                        child: Text('Preview Video'),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 8.h),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      SizedBox(
                                                          width: 120,   // set custom width
                                                          height: 40,
                                                          child: CustomButton(onTap: (){}, buttonText: 'Edit')),

                                                      SizedBox(
                                                          width: 120,   // set custom width
                                                          height: 40,
                                                          child: CustomButton(onTap: (){}, buttonText: 'Delete'))
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                        SizedBox(height: 8.h),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Center(
                                              child: ElevatedButton.icon(
                                                onPressed: widget.onComplete,
                                                icon: const Icon(Icons.upload),
                                                label: const Text('Upload Lesson'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Color(0xFF00AFEE),
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => EditLessonDialogBox(
                                                    onSubmit: (newName) {
                                                      setState(() {
                                                        _lessonTitleController.text = newName;
                                                      });
                                                    },
                                                  ),
                                                );
                                              },
                                              child: Text('Edit Section'),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20,)
                                      ],
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Existing Form Content
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16.w),
                            margin: EdgeInsets.only(top: 16.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
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
                                  'Section title of the course "Test"',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: const Color(0xFF00AFEE),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'Test',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Center(
                                  child: Icon(
                                    Icons.play_circle_outline,
                                    size: 70.sp,
                                    color: Colors.pink[200],
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Center(
                                  child: ElevatedButton.icon(
                                    onPressed: widget.onComplete,
                                    icon: const Icon(Icons.upload),
                                    label: const Text('Upload Lesson'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF00AFEE),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => EditLessonDialogBox(
                                            onSubmit: (newName) {
                                              setState(() {
                                                _lessonTitleController.text = newName;
                                              });
                                            },
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.edit, color: Colors.black),
                                      label: const Text('Edit', style: TextStyle(color: Colors.black)),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.blue),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => DeleteLessonDialogBox(
                                            onDelete: () {
                                              Navigator.pop(context);
                                            },
                                            onCancel: () => Navigator.pop(context),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.delete, color: Colors.black),
                                      label: const Text('Delete', style: TextStyle(color: Colors.black)),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.blue),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 16.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width: 130.w,
                                  child: OutlinedButton.icon(
                                    onPressed: widget.onBack ?? () {},
                                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                                    label: const Text('Back', style: TextStyle(color: Colors.black)),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.blue),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 200.w,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _showAddSection = true;
                                      });
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add More Section'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF00AFEE),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_showAddSection)
                            Container(
                              padding: EdgeInsets.all(16.w),
                              margin: EdgeInsets.only(top: 16.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
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
                                    'Section title of the course "Test"',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: const Color(0xFF00AFEE),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  CustomTextFormField(
                                    hintText: 'Section Title',
                                    labelText: 'Section Title',
                                    controller: _sectionTitleController,
                                    validator: (val) =>
                                    val?.isEmpty ?? true ? 'Section title is required' : null,
                                  ),
                                  SizedBox(height: 16.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        width: 120.w,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            setState(() {
                                              _showAddSection = false;
                                            });
                                          },
                                          child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: Colors.blue),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 150.w,
                                        height: 40,
                                        child: CustomButton(onTap: () {}, buttonText: 'Save'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
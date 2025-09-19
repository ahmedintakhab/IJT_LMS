import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:learn_megnagmet/upload_courses/delete_lecture_dialogbox.dart';
import 'package:learn_megnagmet/utils/api_constant.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:learn_megnagmet/widget/custom_text_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'delete_lesson_dialog_box.dart';
import 'edit_lesson_dialog_box.dart';

class UploadLessonScreen extends StatefulWidget {
  final Function(int lessonId, bool isContinue, {int? lectureId}) onComplete;
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
  int totalLessons = 0;
  int totalLectures = 0;
  String courseTitle = '';

  @override
  void initState() {
    super.initState();
    _getCourseId();
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
            totalLessons = data['data'][0]['total_lessons'] ?? 0;
            totalLectures = data['data'][0]['total_lectures'] ?? 0;
            courseTitle = data['data'][0]['course_title'] ?? 'N/A';
            print('Check total lessons and lectures: ${totalLessons}, ${totalLectures}');
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Print data for debugging
    debugPrint('Submitting data:');
    debugPrint('course_id: $courseId');
    debugPrint('name: ${_sectionTitleController.text}');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = Uri.parse('${ApiConstant.baseUrl}instructor/course/store-lesson');
      var request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields['course_id'] = courseId?.toString() ?? '';
      request.fields['name'] = _sectionTitleController.text;

      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      // final responseData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        debugPrint(' Upload course tags API Response : ${response.statusCode}');
        Get.snackbar(
          'Successful', 'New lesson added successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await _fetchLessons();
        setState(() {
          _showAddSection = false; // Hide the Add Section container
          _sectionTitleController.clear(); // Clear the text field
        });
      } else {
        debugPrint('Add lesson title API Error: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      debugPrint('Add lesson title api error catch: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
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
                            'Section list of, ${courseTitle ?? 'N/A' } ',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: const Color(0xFF00AFEE),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          isLoading
                              ? Center(child: CircularProgressIndicator(color:Color(0xFF00AFEE) ,))
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
                                                        child: Text('Preview Lecture'),
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
                                                          child: CustomButton(onTap: (){
                                                            widget.onComplete(lesson['id'], false, lectureId: lecture['id']);                                                          }, buttonText: 'Edit')),

                                                      SizedBox(
                                                          width: 120,   // set custom width
                                                          height: 40,
                                                          child: CustomButton(onTap: (){
                                                            showDialog(
                                                              context: context,
                                                              builder: (context) => DeleteLectureDialogbox(
                                                                lectureId: lecture['id'],
                                                                onDelete: () {
                                                                  // Navigator.pop(context);
                                                                  _fetchLessons();
                                                                },

                                                                onCancel: () => Navigator.pop(context),
                                                              ),
                                                            );
                                                          },
                                                              buttonText: 'Delete'))
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
                                                onPressed: () {
                                                  // Pass the lessonId when navigating to AddLectureScreen
                                                  // isContinue = false means we're going to AddLectureScreen
                                                  widget.onComplete(lesson['id'], false);
                                                },
                                                icon: const Icon(Icons.upload),
                                                label: const Text('Upload Lecture'),
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
                                                    lessonId: lesson['id'],
                                                    onSubmit: (newName) {
                                                      setState(() {
                                                        _lessonTitleController.text = newName;
                                                      });
                                                      _fetchLessons();
                                                    },
                                                  ),
                                                );
                                              },
                                              child: Text('Edit',style: TextStyle(color: Colors.blue,fontSize: 20.h,fontWeight: FontWeight.bold,
                                                  decoration: TextDecoration.underline,decorationColor:Colors.blue ),),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => DeleteLessonDialogBox(
                                                    lessonId: lesson['id'],
                                                    onDelete: () {
                                                      // Navigator.pop(context);
                                                      _fetchLessons();
                                                    },

                                                    onCancel: () => Navigator.pop(context),
                                                  ),
                                                );
                                              },

                                              child: Text('Delete',style: TextStyle(color: Colors.red,fontSize: 18.h,fontWeight: FontWeight.bold,
                                                  decoration: TextDecoration.underline,decorationColor:Colors.red ),),
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
                                SizedBox(width: 200.w,height: 50.h,
                                  child: CustomButton(onTap: (){
                                    setState(() {
                                      _showAddSection = true;
                                    });
                                  }, buttonText: 'Add more Section'),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 10.h,),
                          if (totalLectures > 0)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomButton(onTap: (){
                                // Save and continue to next step (InstructorsScreen)
                                // isContinue = true means we're going to InstructorsScreen
                                widget.onComplete(0, true);
                              }, buttonText: 'Save and Continue'),
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
                                    'Section title of the course, ${courseTitle ?? ''}',
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
                                        child: CustomButton( onTap: _submitForm,
                                          buttonText: 'Save',
                                          isLoading: isLoading,),
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
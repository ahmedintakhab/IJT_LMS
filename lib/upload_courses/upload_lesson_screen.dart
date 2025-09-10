import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:learn_megnagmet/widget/custom_text_form_field.dart';

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
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                onPressed: widget.onComplete, // Navigate to AddLectureScreen
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
                                        initialName: 'Test',
                                        onSubmit: (newName) {
                                          setState(() {
                                            // Update the lesson name here
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
                                          Navigator.pop(context); // Close dialog
                                          // Add delete logic here
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
                                icon: const Icon(Icons.arrow_back,color: Colors.black,),
                                label: const Text('Back',style: TextStyle(color: Colors.black),),
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
                              CustomTextFormField(hintText: 'Section Title',
                                labelText: 'Section Title',controller: _sectionTitleController,validator: (val) =>
                                val?.isEmpty ?? true ? 'Section title is required' : null,),
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
                                      child: const Text('Cancel',style: TextStyle(color: Colors.black),),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.blue),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 150.w,height: 40,
                                    child: CustomButton(onTap: (){}, buttonText: 'Save')
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
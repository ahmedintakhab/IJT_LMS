// File: upload_course_details.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learn_megnagmet/widget/button.dart';
import '../widget/custom_text_form_field.dart';

class UploadCourseDetails extends StatefulWidget {
  final VoidCallback onComplete;

  const UploadCourseDetails({super.key, required this.onComplete});

  @override
  State<UploadCourseDetails> createState() => _UploadCourseDetailsState();
}

class _UploadCourseDetailsState extends State<UploadCourseDetails> {
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> keyPointControllers = [];

  @override
  void initState() {
    super.initState();
    keyPointControllers.add(TextEditingController()); // Start with one key point field
  }

  @override
  void dispose() {
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
    if (keyPointControllers.length > 1) { // Optional: prevent removing the last one
      setState(() {
        keyPointControllers[index].dispose();
        keyPointControllers.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.w), // Using ScreenUtil for responsive padding
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
                        hintText: 'Enter course title',
                        labelText: 'Course Title',
                        validator: (val) => val?.isEmpty ?? true ? 'Required' : null,
                      ),
                      SizedBox(height: 16.h),
                      // Course Title (Ur)
                      CustomTextFormField(
                        hintText: 'Enter course title (Ur)',
                        labelText: 'Course Title (Ur)',
                        validator: (val) => val?.isEmpty ?? true ? 'Required' : null,
                      ),
                      SizedBox(height: 16.h),
                      // Course Sub Title (expanded)
                      CustomTextFormField(
                        hintText: 'Enter course sub title',
                        labelText: 'Course Sub Title',
                        maxLines: 4,
                        validator: (val) => val?.isEmpty ?? true ? 'Required' : null,
                      ),
                      SizedBox(height: 16.h),
                      // Key Points Section
                      Text(
                        'Course Description Key Points *',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: const Color(0xFF00AFEE), // Assuming blue from screenshot
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
                                  validator: (val) => val?.isEmpty ?? true ? 'Required' : null,
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
                          foregroundColor: const Color(0xFF00AFEE), // Blue text
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Course Description (expanded)
                      CustomTextFormField(
                        hintText: 'Enter course description',
                        labelText: 'Course Description',
                        maxLines: 4,
                        validator: (val) => val?.isEmpty ?? true ? 'Required' : null,
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
                        if (_formKey.currentState!.validate()) {
                          widget.onComplete(); // Only call onComplete, no Navigator.push
                        }
                      },
                      buttonText: 'Save and Continue',
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
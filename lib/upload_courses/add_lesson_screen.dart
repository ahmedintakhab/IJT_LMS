// File: upload_video_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:learn_megnagmet/widget/custom_text_form_field.dart';

class AddLessonScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback? onBack;


  const AddLessonScreen({super.key, required this.onComplete, this.onBack});

  @override
  State<AddLessonScreen> createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonScreen> {
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
                        'Section title of the courses "Test Lesson"',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF00AFEE),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(hintText: 'Introduction',
                        labelText: 'Introduction',
                      )
                    ],
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
                    child: CustomButton(onTap: (){
                      if (widget.onBack != null) {
                        widget.onBack!();
                      }                    }, buttonText: 'Back'),
                  ),
                  SizedBox(width: 20,),
                  Expanded(
                    child: CustomButton(onTap: (){
                      widget.onComplete();

                    }, buttonText: 'Save and Continue'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
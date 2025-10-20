import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:learn_megnagmet/create_assignment/create_assignment_form.dart';

import '../widget/button.dart';

class CreateAssignmentContainer extends StatelessWidget {
  final String courseName;
  final String courseId;

  const CreateAssignmentContainer({super.key, required this.courseName, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 180.h,
        width: double.infinity,
        decoration: BoxDecoration(
          // color: Colors.purple,
            borderRadius: BorderRadius.circular(8),border: Border.all(color: Colors.grey)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Course Name: ${courseName}',
              style: TextStyle( fontSize: 16.sp),
            ),
            SizedBox(height: 10),
            Text(
              'Assignment List',
              style: TextStyle( fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 270.w,
                height: 55.h,
                child: CustomButton(
                  onTap: () {
                    Get.to(()=> CreateAssignmentForm(courseId : courseId));
                  },
                  buttonText: 'Create New Assignment',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../utils/api_constant.dart';
import '../widget/button.dart';
import '../widget/custom_text_form_field.dart';

class EditMarksDialog extends StatefulWidget {
  final int submitId;
  final String initialMarks;
  final String initialNotes;

  const EditMarksDialog({Key? key, required this.submitId, required this.initialMarks, required this.initialNotes}) : super(key: key);

  @override
  _EditMarksDialogState createState() => _EditMarksDialogState();
}

class _EditMarksDialogState extends State<EditMarksDialog> {
  late TextEditingController marksController;
  late TextEditingController notesController;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    marksController = TextEditingController(text: widget.initialMarks);
    notesController = TextEditingController(text: widget.initialNotes);
  }

  @override
  void dispose() {
    marksController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _updateMarks() async {
    final marks = marksController.text.trim();
    final notes = notesController.text.trim();

    if (marks.isEmpty) {
      Get.snackbar(
        'Error',
        'Marks cannot be empty',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => isSubmitting = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('authToken') ?? '';
    final String apiUrl = "${ApiConstant.baseUrl}instructor/course/assignment/assessment/update";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'assignment_submit_id': widget.submitId,
          'marks': int.parse(marks),
          'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Marks updated successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Navigator.pop(context); // Close dialog
        // Refresh parent state if needed (e.g., notify AssignmentTabWidget)
      } else {
        throw Exception('Failed to update marks');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update marks: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Edit Marks',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'Gilroy',
          color: const Color(0xFF00AFEE),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextFormField(
              labelText: 'Marks',
              hintText: 'Enter marks',
              controller: marksController,
            ),
            SizedBox(height: 16.h),
            CustomTextFormField(
              labelText: 'Note',
              hintText: 'Write your note here',
              controller: notesController,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: 'Gilroy',
              color: const Color(0xFF00AFEE),
            ),
          ),
        ),
        SizedBox(
          width: 130.w,
          height: 50.h,
          child: CustomButton(
            onTap: _updateMarks,
            buttonColor: const Color(0xFF00AFEE),
            borderRadius: 6,
            buttonText: isSubmitting ? '' : 'Save',
            isLoading: isSubmitting,
          ),
        ),
      ],
    );
  }
}
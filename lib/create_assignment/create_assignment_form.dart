import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/quiz/add_true_false_question_screen.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:learn_megnagmet/widget/custom_text_form_field.dart';
import 'package:learn_megnagmet/widget/file_choosen_widget.dart';

class CreateAssignmentForm extends StatefulWidget {
  const CreateAssignmentForm({super.key});

  @override
  State<CreateAssignmentForm> createState() => _CreateAssignmentFormState();
}

class _CreateAssignmentFormState extends State<CreateAssignmentForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController assignmentnameController = TextEditingController();
  TextEditingController marksController = TextEditingController();
  TextEditingController detailsController = TextEditingController();

  String? selectedFilePath; // To store the selected file path
  String? fileError; // To store file validation error

  @override
  void dispose() {
    assignmentnameController.dispose();
    marksController.dispose();
    detailsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    setState(() {
      fileError = selectedFilePath == null ? 'Please select a PDF or ZIP file' : null;
    });

    if (_formKey.currentState!.validate() && fileError == null) {
      Get.to(() =>  AddTrueFalseQuestionScreen());
      print('Assignment Name: ${assignmentnameController.text}');
      print('Marks: ${marksController.text}');
      print('Details: ${detailsController.text}');
      print('Selected File: $selectedFilePath');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00AFEE),
        title: const Text(
          'Create New Assignment',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20.h),
                CustomTextFormField(
                  controller: assignmentnameController,
                  hintText: 'Enter Your Assignment Topic',
                  labelText: 'Assignment Topic',
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Enter the assignment topic';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                CustomTextFormField(
                  controller: marksController,
                  hintText: 'Enter Your Assignment Marks',
                  labelText: 'Assignment Marks',
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter the assignment marks';
                    if (int.tryParse(val) == null || int.parse(val) <= 0) {
                      return 'Enter a valid positive number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                CustomTextFormField(
                  controller: detailsController,
                  hintText: 'Enter Your Assignment Details',
                  labelText: 'Assignment Details',
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Enter the assignment details';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                /// ✅ File Chooser integrated here
                FileChoosenWidget(
                  onFileSelected: (filePath) {
                    setState(() {
                      selectedFilePath = filePath;
                      fileError = null;
                    });
                  },
                  errorText: fileError,
                ),

                SizedBox(height: 30.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 120.w,
                      child: CustomButton(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        buttonText: 'Back',
                        buttonColor: Colors.grey[300],
                        textColor: Colors.black,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    SizedBox(
                      width: 210.w,
                      child: CustomButton(
                        onTap: _submitForm,
                        buttonText: 'Create',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

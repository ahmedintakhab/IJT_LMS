import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:learn_megnagmet/quiz/add_true_false_question_screen.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:learn_megnagmet/widget/custom_dropdown.dart';
import 'package:learn_megnagmet/widget/custom_text_form_field.dart';

class CreateQuizForm extends StatefulWidget {
  const CreateQuizForm({super.key});

  @override
  State<CreateQuizForm> createState() => _CreateQuizFormState();
}

class _CreateQuizFormState extends State<CreateQuizForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController quiznameController = TextEditingController();
  TextEditingController quiztypeController = TextEditingController();
  TextEditingController marksController = TextEditingController();
  TextEditingController percentageController = TextEditingController();
  TextEditingController durationController = TextEditingController();

  String? value;
  final List<String> items = ['Multiple Choice', 'True False'];

  @override
  void dispose() {
    quiznameController.dispose();
    quiztypeController.dispose();
    marksController.dispose();
    percentageController.dispose();
    durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00AFEE),
        title: Text(
          'Create New Quiz',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
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
                  controller: quiznameController,
                  hintText: 'Enter Quiz Name',
                  labelText: 'Quiz Name',
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter the quiz name';
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                CustomDropdown(
                  hint: 'Select Type',
                  value: value,
                  items: items,
                  onChanged: (newValue) {
                    setState(() {
                      value = newValue;
                      quiztypeController.text = newValue ?? '';
                    });
                  },
                ),
                SizedBox(height: 20.h),
                CustomTextFormField(
                  controller: marksController,
                  hintText: 'Enter Quiz marks',
                  labelText: 'Quiz Marks',
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter the quiz marks';
                    if (int.tryParse(val) == null || int.parse(val) <= 0) return 'Enter a valid positive number';
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                CustomTextFormField(
                  controller: percentageController,
                  hintText: 'Enter Percentage',
                  labelText: 'Passing Percentage',
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter the marks percentage';
                    if (double.tryParse(val) == null || double.parse(val) < 0 || double.parse(val) > 100) return 'Enter a valid percentage (0-100)';
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                CustomTextFormField(
                  controller: durationController,
                  hintText: 'Enter Quiz Duration',
                  labelText: 'Time Duration (Minutes)',
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter the quiz duration';
                    if (int.tryParse(val) == null || int.parse(val) <= 0) return 'Enter a valid positive number';
                    return null;
                  },
                ),
                SizedBox(height: 30.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 120.w,
                      child: CustomButton(
                        onTap: () {
                          Navigator.pop(context); // Go back
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
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            Get.to(()=>AddTrueFalseQuestionScreen());
                            // Form is valid, proceed with creation
                            print('Quiz Name: ${quiznameController.text}');
                            print('Quiz Type: ${quiztypeController.text}');
                            print('Marks: ${marksController.text}');
                            print('Passing Percentage: ${percentageController.text}');
                            print('Duration: ${durationController.text}');
                            // Add your API call or navigation logic here
                          }
                        },
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
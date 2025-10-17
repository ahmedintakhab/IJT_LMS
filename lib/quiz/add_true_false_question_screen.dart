import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:learn_megnagmet/quiz/true_false_quiz_question_list.dart';
import '../widget/button.dart';
import '../widget/custom_text_form_field.dart';

class AddTrueFalseQuestionScreen extends StatefulWidget {
  final String courseId;
  final int quizId;
  const AddTrueFalseQuestionScreen({super.key, required this.courseId, required this.quizId});

  @override
  _AddTrueFalseQuestionScreenState createState() => _AddTrueFalseQuestionScreenState();
}

class _AddTrueFalseQuestionScreenState extends State<AddTrueFalseQuestionScreen> {
  final TextEditingController _questionController = TextEditingController();
  int _selectedAnswer = 0; // 0 for True, 1 for False

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question for Test Quiz 11',style:
        TextStyle(fontWeight: FontWeight.bold,
            color: Colors.white),),
        backgroundColor: Color(0xFF00AFEE),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Question',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            CustomTextFormField(
              controller: _questionController,
              hintText: 'Enter your question',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Radio<int>(
                        value: 0,
                        groupValue: _selectedAnswer,
                        onChanged: (value) => setState(() => _selectedAnswer = value!),
                        activeColor: const Color(0xFF00AFEE),
                      ),
                      const Text('True'),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Radio<int>(
                        value: 1,
                        groupValue: _selectedAnswer,
                        onChanged: (value) => setState(() => _selectedAnswer = value!),
                        activeColor: const Color(0xFF00AFEE),
                      ),
                      const Text('False'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 150,
                  child: CustomButton(
                    onTap: () => Navigator.pop(context),
                    buttonText: 'Cancel',
                    buttonColor: Colors.grey,
                    textColor: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: CustomButton(
                    onTap: () {
                      Get.to(()=>TrueFalseQuizListScreen());
                    },
                    buttonText: 'Save',
                    buttonColor: const Color(0xFF00AFEE),
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
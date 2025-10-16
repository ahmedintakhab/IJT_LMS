import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:learn_megnagmet/quiz/mcqs_question_list.dart';
import '../widget/button.dart';
import '../widget/custom_text_form_field.dart';

class AddQuizQuestionForm extends StatefulWidget {
  @override
  _AddQuizQuestionFormState createState() => _AddQuizQuestionFormState();
}

class _AddQuizQuestionFormState extends State<AddQuizQuestionForm> {
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [TextEditingController()];
  int _correctOptionIndex = -1;

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _setCorrectOption(int index) {
    setState(() {
      _correctOptionIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Create Quiz', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF00AFEE),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question 1',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            CustomTextFormField(
              controller: _questionController,
              hintText: 'Enter your question',
              maxLines: 1,
            ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(_optionControllers.length, (index) {
                return Column(
                  children: [
                    if (index > 0) SizedBox(height: 16), // Add spacing between options
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            controller: _optionControllers[index],
                            hintText: 'Enter option',
                            maxLines: 1,
                          ),
                        ),
                        Radio<int>(
                          value: index,
                          groupValue: _correctOptionIndex,
                          onChanged: (value) => _setCorrectOption(value!),
                          activeColor: Color(0xFF00AFEE),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _addOption,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                  color: Color(0xFF00AFEE),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(Icons.add, color: Colors.white),
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 200,
                  child: CustomButton(
                    onTap: () {},
                    buttonText: 'Save and Another',
                  ),
                ),
                SizedBox(width: 120,
                  child: CustomButton(
                    onTap: () {
                      Get.to(()=> QuizListScreen());
                    },
                    buttonText: 'Save',
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
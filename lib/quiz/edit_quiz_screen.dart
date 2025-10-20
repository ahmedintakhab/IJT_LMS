import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:learn_megnagmet/widget/custom_dropdown.dart';
import 'package:learn_megnagmet/widget/custom_text_form_field.dart';
import 'package:learn_megnagmet/utils/api_constant.dart';


class EditQuizScreen extends StatefulWidget {
  final int quizId;
  const EditQuizScreen({super.key, required this.quizId});

  @override
  State<EditQuizScreen> createState() => _EditQuizScreenState();
}

class _EditQuizScreenState extends State<EditQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController quiznameController = TextEditingController();
  TextEditingController quiztypeController = TextEditingController();
  TextEditingController marksController = TextEditingController();
  TextEditingController percentageController = TextEditingController();
  TextEditingController durationController = TextEditingController();

  String? value;
  final List<String> items = ['Multiple Choice', 'True False'];

  // Loading states
  bool isLoading = false;        // For Update button
  bool isLoadingData = true;     // For fetching data
  String? courseTitle;           // Store course title

  @override
  void initState() {
    super.initState();
    _fetchQuizData(); // ✅ Fetch data when screen loads
  }

  @override
  void dispose() {
    quiznameController.dispose();
    quiztypeController.dispose();
    marksController.dispose();
    percentageController.dispose();
    durationController.dispose();
    super.dispose();
  }

  // ✅ NEW: Fetch Quiz Data from API
// ✅ COMPLETE: Fetch Quiz Data from API with FULL Error Handling
  Future<void> _fetchQuizData() async {
    setState(() {
      isLoadingData = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = Uri.parse("${ApiConstant.baseUrl}instructor/course/exam/edit/${widget.quizId}");

      print('Fetching quiz data for ID: ${widget.quizId}');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true || data['status'] == true) {
          final quizData = data['data'];

          if (quizData != null) {
            // ✅ POPULATE ALL FIELDS
            quiznameController.text = quizData['name'] ?? '';
            marksController.text = quizData['marks_per_question']?.toString() ?? '';
            percentageController.text = quizData['passing_percentage']?.toString() ?? '';
            durationController.text = quizData['duration']?.toString() ?? '';

            // ✅ FIXED DROPDOWN MAPPING - CORRECT LOGIC
            String apiType = (quizData['type'] ?? '').trim();
            print('Check print type: $apiType');

            String dropdownValue = apiType == 'Multiple Choice' ? 'Multiple Choice' : 'True False';
            print('After $dropdownValue');
            value = dropdownValue;
            quiztypeController.text = dropdownValue;

            // ✅ Store course title
            courseTitle = quizData['course_title'] ?? '';

            print('✅ Quiz data populated successfully!');
            print('Name: ${quiznameController.text}');
            print('Type: $dropdownValue');
            print('Marks: ${marksController.text}');
            print('Percentage: ${percentageController.text}');
            print('Duration: ${durationController.text}');
          } else {
            Get.snackbar('Error', 'No quiz data found!', snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
          }
        } else {
          final errorMessage = data['message'] ?? 'Unknown error occurred';
          Get.snackbar('Error', 'Failed to load quiz: $errorMessage', snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
          print('Fetch create quiz form data response: $errorMessage');
        }
      } else {
        Get.snackbar('Error', 'Failed to load quiz: ${response.statusCode}', snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print('Error fetching quiz data: $e');
      Get.snackbar('Error', 'Something went wrong: $e', snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() {
        isLoadingData = false;
      });
    }
  }  // UPDATED: API Call Function
  Future<void> UpdateQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = Uri.parse("${ApiConstant.baseUrl}instructor/course/exam/update");

      // ✅ FIXED: Use dropdown value for type
      final apiType = value == 'Multiple Choice' ? 'Multiple Choice' : 'True False';

      final payload = {
        'quiz_id': widget.quizId,
        'name': quiznameController.text,
        'type': apiType,  // ✅ Send API format (MCQ/True False)
        'marks_per_question': int.parse(marksController.text),
        'passing_percentage': double.parse(percentageController.text),
        'duration': int.parse(durationController.text),
      };

      print('Sending API payload: ${jsonEncode(payload)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Quiz updated successfully: ${response.body}');
        Get.snackbar(
          'Success',
          'Quiz Updated Successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Navigator.pop(context); // Go back to quiz list
      } else {
        Get.snackbar(
          'Error',
          'Failed to update quiz: ${response.statusCode}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error updating quiz: $e');
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingData) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFF00AFEE),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00AFEE),
        title: const Text(
          'Edit Quiz',  // ✅ Updated title
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
                if (courseTitle != null) ...[
                  Text(
                    'Course: $courseTitle',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  SizedBox(height: 10.h),
                ],
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
                          Navigator.pop(context);
                        },
                        buttonText: 'Cancel',  // ✅ Changed from Back
                        buttonColor: Colors.grey[300],
                        textColor: Colors.black,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    SizedBox(
                      width: 210.w,
                      child: CustomButton(
                        onTap: UpdateQuiz,
                        buttonText: 'Update',  // ✅ Already correct
                        buttonColor: const Color(0xFF00AFEE),
                        textColor: Colors.white,
                        isLoading: isLoading,
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
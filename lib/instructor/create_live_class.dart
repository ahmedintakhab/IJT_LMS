import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:learn_megnagmet/widget/custom_text_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Add intl package for date formatting
import '../utils/api_constant.dart';
import '../widget/custom_dropdown.dart';

class CreateLiveClass extends StatefulWidget {
  final String courseuuid; // Add uuid parameter
  const CreateLiveClass({Key? key, required this.courseuuid}) : super(key: key);

  @override
  _CreateLiveClassState createState() => _CreateLiveClassState();
}

class _CreateLiveClassState extends State<CreateLiveClass> {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  TimeOfDay? _selectedTime;
  String? _selectedLearningTool;
  bool _isLoading = false; // To show loading indicator
  String _errorMessage = ''; // To show error message

  final List<String> _learningTools = ['Zoom', 'BigBlueButton'];

  Future<void> _selectDate(BuildContext context) async {
    // Pick Date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Start from today
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      // Pick Time
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        // Combine date and time
        final DateTime combinedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Format the date and time to MM/dd/yyyy hh:mm a
        final String formattedDateTime = DateFormat('MM/dd/yyyy hh:mm a').format(combinedDateTime);

        setState(() {
          _dateController.text = formattedDateTime; // Format: MM/dd/yyyy hh:mm a (e.g., 04/30/2025 06:04 PM)
          _selectedTime = pickedTime; // Store selected time if needed
        });
      }
    }
  }

  Future<void> _createLiveClass() async {
    // Validate inputs
    if (_topicController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _durationController.text.isEmpty ||
        _selectedLearningTool == null) {
      setState(() {
        _errorMessage = 'Please fill in all fields.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final url = Uri.parse("${ApiConstant.baseUrl}instructor/live-class/store/${widget.courseuuid}");

      // Retrieve the token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';
      // Transform the learning_tool value for the API
      String apiLearningTool;
      if (_selectedLearningTool == 'BigBlueButton') {
        apiLearningTool = 'bbb';
      } else if (_selectedLearningTool == 'Zoom') {
        apiLearningTool = 'zoom';
      } else {
        apiLearningTool = _selectedLearningTool ?? ''; // Fallback in case of unexpected value
      }

      // Prepare the request body
      final Map<String, dynamic> body = {
        'class_topic': _topicController.text,
        'date': _dateController.text,
        'duration': _durationController.text,
        'learning_tool': apiLearningTool,
      };

      // Make the API request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        print('Create Live class Api response: ${response.statusCode}');

        // Successful API call
        Get.snackbar('Successful', 'Successfully created live class',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,        );

        Navigator.pop(context); // Navigate back on success
      } else {
        // Handle API error
        print('Failed to create live class. Status code: ${response.statusCode}');
        setState(() {
          _errorMessage = 'Failed to create live class. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      // Handle network errors
      setState(() {
        _errorMessage = 'Network error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    _durationController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Live Class',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0XFF00AFEE),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Class Topic
            Text(
              'Live Class Topic',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            CustomTextFormField(
              controller: _topicController,
              hintText: 'Enter your topic',
              validator: (val) {
                if (val == null || val.isEmpty) return 'Enter your topic';
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // Live Class Date
            Text(
              'Live Class Date',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            CustomTextFormField(
              controller: _dateController,
              hintText: 'Select date (MM/dd/yyyy hh:mm a)', // Updated hint to reflect expected format
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                color: const Color(0XFF00AFEE),
                onPressed: () => _selectDate(context),
              ),
              validator: (value) =>
              value?.isEmpty ?? true ? 'Please select date and time' : null,
            ),
            SizedBox(height: 16.h),

            // Time Duration
            Text(
              'Time Duration (Write minutes)',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            CustomTextFormField(
              controller: _durationController,
              hintText: "Type duration in minutes",
              validator: (val) {
                if (val!.isEmpty) return 'Enter the duration';
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // Learning Tool
            Text(
              'Learning Tool',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            CustomDropdown(
              hint: 'Select Option',
              value: _selectedLearningTool,
              items: _learningTools,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLearningTool = newValue;
                });
              },
            ),
            SizedBox(height: 24.h),

            // Error Message
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 14.sp),
                ),
              ),

            // Buttons Row
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onTap: () {
                      Navigator.pop(context); // Go back to the previous screen
                    },
                    buttonText: 'Back',
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomButton(
                        onTap: () {
                          _createLiveClass(); // Wrap Future in a VoidCallback
                        },
                        buttonText: _isLoading ? '' : 'Create Meeting', // Hide text when loading
                      ),
                      if (_isLoading)
                        const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                    ],
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


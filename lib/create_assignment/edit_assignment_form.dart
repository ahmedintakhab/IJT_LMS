import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:learn_megnagmet/widget/custom_text_form_field.dart';
import 'package:learn_megnagmet/widget/file_choosen_widget.dart';
import 'package:learn_megnagmet/utils/api_constant.dart';

class EditAssignmentForm extends StatefulWidget {
  final int? assignmentId;
  const EditAssignmentForm({super.key, required this.assignmentId});

  @override
  State<EditAssignmentForm> createState() => _EditAssignmentFormState();
}

class _EditAssignmentFormState extends State<EditAssignmentForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController assignmentNameController = TextEditingController();
  TextEditingController marksController = TextEditingController();
  TextEditingController detailsController = TextEditingController();

  String? selectedFilePath;
  String? originalFileName; // ✅ Store original filename
  bool isLoading = false;
  bool isLoadingData = true; // ✅ Loading for fetching data
  String? courseTitle; // ✅ Store course title

  @override
  void initState() {
    super.initState();
    _fetchAssignmentData(); // ✅ Fetch data when screen loads
  }

  @override
  void dispose() {
    assignmentNameController.dispose();
    marksController.dispose();
    detailsController.dispose();
    super.dispose();
  }

  // ✅ NEW: Fetch Assignment Data from API
  Future<void> _fetchAssignmentData() async {
    setState(() {
      isLoadingData = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final String apiUrl = "${ApiConstant.baseUrl}instructor/course/assignment/edit/${widget.assignmentId}";

      print('Fetching assignment data for ID: ${widget.assignmentId}');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final assignmentData = data['data']['assignment'];

          // ✅ POPULATE ALL FIELDS
          assignmentNameController.text = assignmentData['name'] ?? '';
          marksController.text = assignmentData['marks']?.toString() ?? '';
          detailsController.text = assignmentData['description'] ?? '';

          // ✅ Store original file info (for display)
          originalFileName = assignmentData['original_filename'] ?? '';
          courseTitle = data['data']['course']['title'] ?? '';

          print('✅ Assignment data populated successfully!');
          print('Name: ${assignmentNameController.text}');
          print('Marks: ${marksController.text}');
          print('Details: ${detailsController.text}');
          print('Original File: $originalFileName');
          print('Course: $courseTitle');
        } else {
          Get.snackbar('Error', 'Failed to load assignment: ${data['message']}',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        }
      } else {
        Get.snackbar('Error', 'Failed to load assignment: ${response.statusCode}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      print('Error fetching assignment data: $e');
      Get.snackbar('Error', 'Something went wrong: $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      setState(() {
        isLoadingData = false;
      });
    }
  }

  Future<void> _UpdateAssignment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final String apiUrl = "${ApiConstant.baseUrl}instructor/course/assignment/update";

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['assignment_id'] = widget.assignmentId.toString();
      request.fields['name'] = assignmentNameController.text.trim();
      request.fields['marks'] = marksController.text.trim();
      request.fields['description'] = detailsController.text.trim();

      // ✅ Add file only if NEW file selected
      if (selectedFilePath != null && selectedFilePath!.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('file', selectedFilePath!));
      }

      print('📤 Updating assignment...');
      var response = await request.send();
      final resBody = await response.stream.bytesToString();
      print('📥 Response: $resBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Assignment updated successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Navigator.pop(context);
      } else {
        final error = jsonDecode(resBody)['message'] ?? 'Validation failed';
        Get.snackbar(
          'Error',
          error,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Error: $e');
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isLoading = false);
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
          'Update Assignment',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),

                // ✅ Course Title Display
                if (courseTitle != null) ...[
                  Text(
                    'Course: $courseTitle',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  SizedBox(height: 10.h),
                ],

                CustomTextFormField(
                  controller: assignmentNameController,
                  hintText: 'Enter Assignment Topic',
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
                  hintText: 'Enter Assignment Marks',
                  labelText: 'Assignment Marks',
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Enter the assignment marks';
                    }
                    if (int.tryParse(val) == null || int.parse(val) <= 0) {
                      return 'Enter a valid positive number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                CustomTextFormField(
                  controller: detailsController,
                  hintText: 'Enter Assignment Details',
                  labelText: 'Assignment Details',
                  maxLines: 3,
                ),
                SizedBox(height: 20.h),

                // ✅ File Chooser with Original File Display
                FileChoosenWidget(
                  onFileSelected: (filePath) {
                    setState(() {
                      selectedFilePath = filePath;
                    });
                  },
                  originalFileName: originalFileName, // ✅ Show existing file
                  showOriginalFile: true, // ✅ Display original filename
                ),

                SizedBox(height: 30.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 120.w,
                      child: CustomButton(
                        onTap: () => Navigator.pop(context),
                        buttonText: 'Cancel',
                        buttonColor: Colors.grey[300],
                        textColor: Colors.black,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    SizedBox(
                      width: 210.w,
                      child: CustomButton(
                        onTap: _UpdateAssignment,
                        buttonText: 'Update',
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
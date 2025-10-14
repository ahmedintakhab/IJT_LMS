import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../utils/api_constant.dart';

class UploadAssignment extends StatefulWidget {
  final String courseId;
  final String assignmentId;

  const UploadAssignment({Key? key, required this.courseId, required this.assignmentId})
      : super(key: key);

  @override
  _UploadAssignmentState createState() => _UploadAssignmentState();
}

class _UploadAssignmentState extends State<UploadAssignment> {
  String _fileName = 'No file chosen';
  FilePickerResult? _fileResult;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'zip'],
    );

    if (result != null) {
      setState(() {
        _fileResult = result;
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> submitAssignment() async {
    if (_fileResult == null) {
      Get.snackbar(
        'Error',
        'Please select a file to upload',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('auth_token') ?? '';

    final url = Uri.parse("${ApiConstant.baseUrl}student/course/submit-assignment-store");
    var request = http.MultipartRequest('POST', url);

    // Add headers
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'multipart/form-data';

    // Add fields
    request.fields['assignment_id'] = widget.assignmentId;
    request.fields['course_id'] = widget.courseId;

    // Add file
    if (Platform.isAndroid || Platform.isIOS) {
      // For mobile platforms, use file path
      final file = _fileResult!.files.single;
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path!, filename: file.name),
      );
    } else {
      // For web or other platforms, use bytes
      final file = _fileResult!.files.single;
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ),
      );
    }

    try {
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        print('Assignment upload API response: ${response.statusCode}');
        Get.snackbar(
          'Success',
          'Assignment successfully uploaded',
          snackPosition: SnackPosition.TOP,
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed to upload assignment: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload assignment',
        snackPosition: SnackPosition.TOP,
      );
      print('Error uploading assignment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assignment Upload',
          style: TextStyle(color: Color(0xFF78A03F)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Color(0xFF78A03F),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20.h),
            Container(
              padding: const EdgeInsets.all(46.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  OutlinedButton(
                    onPressed: _pickFile,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.attach_file),
                        SizedBox(width: 8.w),
                        const Text('Choose File'),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    _fileName,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 10.h),
                  const Text(
                    'Accepted file selected (PDF, ZIP)',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 55.h,
                    child: CustomButton(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      buttonText: 'Back',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 55.h,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomButton(
                          onTap: _isLoading
                              ? () {} // Disable button during loading
                              : () async {
                            setState(() {
                              _isLoading = true;
                            });
                            await submitAssignment();
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                          buttonText: _isLoading ? '' : 'Submit',
                          buttonColor: const Color(0xFF78A03F),
                          textColor: Colors.white,
                        ),
                        if (_isLoading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.0,
                            ),
                          ),
                      ],
                    ),
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
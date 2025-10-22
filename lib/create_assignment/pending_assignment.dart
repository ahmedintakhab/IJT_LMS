import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/api_constant.dart';
import '../widget/button.dart';
import '../widget/custom_text_form_field.dart';

class PendingAssignment extends StatefulWidget {
  final List<dynamic> pendingData;
  final bool isLoading;

  const PendingAssignment({Key? key, required this.pendingData, required this.isLoading}) : super(key: key);

  @override
  _PendingAssignmentState createState() => _PendingAssignmentState();
}

class _PendingAssignmentState extends State<PendingAssignment> {
  final Map<int, TextEditingController> marksControllers = {};
  final Map<int, TextEditingController> notesControllers = {};
  final Map<int, bool> isSubmitting = {};
  final Map<int, bool> isDownloading = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.pendingData.length; i++) {
      marksControllers[i] = TextEditingController();
      notesControllers[i] = TextEditingController();
      isSubmitting[i] = false;
      isDownloading[i] = false;
    }
  }

  @override
  void didUpdateWidget(PendingAssignment oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pendingData.length != oldWidget.pendingData.length) {
      marksControllers.clear();
      notesControllers.clear();
      isSubmitting.clear();
      isDownloading.clear();
      for (int i = 0; i < widget.pendingData.length; i++) {
        marksControllers[i] = TextEditingController();
        notesControllers[i] = TextEditingController();
        isSubmitting[i] = false;
        isDownloading[i] = false;
      }
    }
  }

  @override
  void dispose() {
    for (var controller in marksControllers.values) {
      controller.dispose();
    }
    for (var controller in notesControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitMarks(int index) async {
    final data = widget.pendingData[index];
    final submitId = data['id'];
    final marks = marksControllers[index]!.text.trim();
    final notes = notesControllers[index]!.text.trim();

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
    if (notes.isEmpty) {
      Get.snackbar(
        'Error',
        'Notes cannot be empty',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => isSubmitting[index] = true);

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
          'assignment_submit_id': submitId,
          'marks': int.parse(marks),
          'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Marks submitted successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        setState(() {
          marksControllers[index]!.clear();
          notesControllers[index]!.clear();
          isSubmitting[index] = false;
        });
      } else {
        throw Exception('Failed to submit marks');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit marks: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() => isSubmitting[index] = false);
    }
  }

  Future<void> _downloadFile(int index) async {
    final data = widget.pendingData[index];
    final submitId = data['id'];
    setState(() => isDownloading[index] = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('authToken') ?? '';
    final String apiUrl = "${ApiConstant.baseUrl}instructor/course/assignment/assessment/download/$submitId";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final fileUrl = responseData['file_url'];

        if (fileUrl != null) {
          final dio = Dio();
          final dir = await getExternalStorageDirectory(); // Use Downloads or Documents directory
          final fileName = fileUrl.split('/').last;
          final savePath = '${dir?.path}/$fileName';

          await dio.download(
            fileUrl,
            savePath,
            options: Options(
              headers: {'Authorization': 'Bearer $token'},
            ),
            onReceiveProgress: (received, total) {
              if (total != -1) {
                print('Progress: ${(received / total * 100).toStringAsFixed(0)}%');
              }
            },
          );
          print('Check save file path $savePath');

          Get.snackbar(
            'Success',
            'File downloaded to: $savePath',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          throw Exception('File URL not found in response');
        }
      } else {
        throw Exception('Failed to download file');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download file: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isDownloading[index] = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00AFEE),
        ),
      );
    }

    if (widget.pendingData == null || widget.pendingData.isEmpty) {
      return Center(
        child: Text(
          'No pending assignments available',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Gilroy',
            color: const Color(0xFF00AFEE),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.pendingData.length,
            itemBuilder: (context, index) {
              final data = widget.pendingData[index];
              final submitId = data['id'];
              return Container(
                margin: EdgeInsets.only(bottom: 16.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(data['student_image']),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      data['student_name'],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Gilroy',
                        color: const Color(0xFF00AFEE),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      data['student_email'],
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: 'Gilroy',
                        color: const Color(0xFF00AFEE),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 130.w,
                          height: 50.h,
                          child: CustomButton(
                            onTap: () => _downloadFile(index),
                            buttonColor: const Color(0xFF28A745),
                            borderRadius: 6,
                            buttonText: 'Download',
                            isLoading: isDownloading[index]!,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        SizedBox(
                          width: 150.w,
                          height: 50.h,
                          child: CustomTextFormField(
                            labelText: 'Marks',
                            hintText: 'Enter marks',
                            controller: marksControllers[index]!,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    CustomTextFormField(
                      labelText: 'Note',
                      hintText: 'Write your note here',
                      controller: notesControllers[index]!,
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: 130.w,
                      height: 50.h,
                      child: CustomButton(
                        onTap: () => _submitMarks(index),
                        buttonColor: const Color(0xFF00AFEE),
                        borderRadius: 6,
                        buttonText: isSubmitting[index]! ? '' : 'Submit',
                        isLoading: isSubmitting[index]!,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
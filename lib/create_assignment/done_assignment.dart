import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../utils/api_constant.dart';
import '../widget/button.dart';
import '../widget/custom_text_form_field.dart';
import 'edit_marks_dialogbox.dart';

class DoneAssignment extends StatefulWidget {
  final List<dynamic> doneData;
  final bool isLoading;

  const DoneAssignment({Key? key, required this.doneData, required this.isLoading}) : super(key: key);

  @override
  _DoneAssignmentState createState() => _DoneAssignmentState();
}

class _DoneAssignmentState extends State<DoneAssignment> {
  final Map<int, bool> isDownloading = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.doneData.length; i++) {
      isDownloading[i] = false;
    }
  }

  @override
  void didUpdateWidget(DoneAssignment oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.doneData.length != oldWidget.doneData.length) {
      isDownloading.clear();
      for (int i = 0; i < widget.doneData.length; i++) {
        isDownloading[i] = false;
      }
    }
  }

  Future<void> _downloadFile(int index) async {
    final data = widget.doneData[index];
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
        Get.snackbar(
          'Success',
          'File downloaded successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        setState(() => isDownloading[index] = false);
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
      setState(() => isDownloading[index] = false);
    }
  }

  void _showEditMarksDialog(int index) {
    final data = widget.doneData[index];
    showDialog(
      context: context,
      builder: (context) => EditMarksDialog(
        submitId: data['id'],
        initialMarks: data['marks']?.toString() ?? '',
        initialNotes: data['notes'] ?? '',
      ),
    );
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

    if (widget.doneData == null || widget.doneData.isEmpty) {
      return Center(
        child: Text(
          'No done assignments available',
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
            itemCount: widget.doneData.length,
            itemBuilder: (context, index) {
              final data = widget.doneData[index];
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
                          height: 55.h,
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
                          height: 55.h,
                          child: CustomTextFormField(
                            labelText: 'Marks',
                            hintText: 'Marks',
                            controller: TextEditingController(text: data['marks']?.toString() ?? 'N/A'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    CustomTextFormField(
                        labelText: 'Notes',
                        hintText: 'Notes',
                        controller: TextEditingController(text: data['notes'] ?? 'N/A'),
                      ),
                    SizedBox(height: 16.h),
                    CustomButton(
                      onTap: () => _showEditMarksDialog(index),
                      buttonColor: const Color(0xFF00AFEE),
                      borderRadius: 6,
                      buttonText: 'Edit',
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
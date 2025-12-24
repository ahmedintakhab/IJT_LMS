import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:learn_megnagmet/utils/api_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteRecommendationCourseDialogbox extends StatefulWidget {
  final VoidCallback onDelete;
  final VoidCallback onCancel;
  final int? recommendedCourseId;

  const DeleteRecommendationCourseDialogbox({
    super.key,
    required this.onDelete,
    required this.onCancel,
    required this.recommendedCourseId,
  });

  @override
  State<DeleteRecommendationCourseDialogbox> createState() => _DeleteRecommendationCourseDialogboxState();
}

class _DeleteRecommendationCourseDialogboxState extends State<DeleteRecommendationCourseDialogbox> {
  bool _isLoading = false;

  Future<void> _deleteLesson() async {
    if (widget.recommendedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No course selected')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';
      print('check quiz id for delete ${widget.recommendedCourseId}');

      final url = Uri.parse('${ApiConstant.baseUrl}delete-course-recommendation-list');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'course_recommendation_id': widget.recommendedCourseId,
        }),
      );

      if (response.statusCode == 200) {
        print('Recommendation course delete api response: ${response.statusCode}');
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          widget.onDelete(); // Notify parent to refresh or handle post-deletion
          Navigator.pop(context);// Close the dialog
          // Get.snackbar(
          //   'Success',
          //   'Recommended course deleted Successfully!',
          //   snackPosition: SnackPosition.TOP,
          //   backgroundColor: Colors.green,
          //   colorText: Colors.white,
          // );
        } else {
          throw Exception('API returned success: false - ${data['message']}');
        }
      } else {
        throw Exception('Failed to delete recommendation : ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting recommendation course: $e')),
      );
      print('Error deleting recommendation course: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Check the recommended id ${widget.recommendedCourseId}');
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber,
              size: 40,
              color: Color(0xFFFFA500),
            ),
            SizedBox(height: 16.h),
            Text(
              'Sure! You want to delete this question?',
              style: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFF00AFEE),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'You won\'t be able to revert this!',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _deleteLesson,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00AFEE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Yes, Delete It!'),
                ),
                OutlinedButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
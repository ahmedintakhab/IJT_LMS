import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:learn_megnagmet/utils/api_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteLectureDialogbox extends StatefulWidget {
  final VoidCallback onDelete;
  final VoidCallback onCancel;
  final int? lectureId;

  const DeleteLectureDialogbox({
    super.key,
    required this.onDelete,
    required this.onCancel,
    required this.lectureId,
  });

  @override
  State<DeleteLectureDialogbox> createState() => _DeleteLectureDialogboxState();
}

class _DeleteLectureDialogboxState extends State<DeleteLectureDialogbox> {
  bool _isLoading = false;

  Future<void> _deleteLesson() async {
    if (widget.lectureId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No lecture selected')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = Uri.parse('${ApiConstant.baseUrl}instructor/course/delete-lecture');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'lecture_id': widget.lectureId,
        }),
      );

      if (response.statusCode == 200) {
        print('Lecture delete api response: ${response.statusCode}');
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          widget.onDelete(); // Notify parent to refresh or handle post-deletion
          Navigator.pop(context); // Close the dialog
        } else {
          throw Exception('API returned success: false - ${data['message']}');
        }
      } else {
        throw Exception('Failed to delete lesson: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting lesson: $e')),
      );
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
              'Sure! You want to delete this lecture?',
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
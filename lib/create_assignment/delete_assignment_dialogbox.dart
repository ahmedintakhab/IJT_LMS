import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:learn_megnagmet/utils/api_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteAssignmentDialogbox extends StatefulWidget {
  final VoidCallback onDelete;
  final VoidCallback onCancel;
  final int? assignmentId;

  const DeleteAssignmentDialogbox({
    super.key,
    required this.onDelete,
    required this.onCancel,
    required this.assignmentId,
  });

  @override
  State<DeleteAssignmentDialogbox> createState() => _DeleteAssignmentDialogboxState();
}

class _DeleteAssignmentDialogboxState extends State<DeleteAssignmentDialogbox> {
  bool _isLoading = false;

  Future<void> _deleteLesson() async {
    if (widget.assignmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No assignment selected')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = Uri.parse('${ApiConstant.baseUrl}instructor/course/assignment/delete');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'assignment_id': widget.assignmentId.toString(),
        }),
      );

      if (response.statusCode == 200) {
        print('Assignment delete api response: ${response.statusCode}');
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          widget.onDelete(); // Notify parent to refresh or handle post-deletion
          Navigator.pop(context); // Close the dialog
        } else {
          throw Exception('API returned success: false - ${data['message']}');
        }
      } else {
        throw Exception('Failed to delete assignment: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting assignment: $e')),
      );
      print('Error deleting assignment: $e');
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
    print('Check the assignment id ${widget.assignmentId}');
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
              'Sure! You want to delete this assignment?',
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
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:learn_megnagmet/widget/button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/api_constant.dart';
import 'instructor_notice_board.dart';

class AddNoticeScreen extends StatefulWidget {
  final CourseNotice course;

  const AddNoticeScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<AddNoticeScreen> createState() => _AddNoticeScreenState();
}

class _AddNoticeScreenState extends State<AddNoticeScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool isSubmitting = false;

  Future<void> _addNotice() async {
    setState(() {
      isSubmitting = true;
    });
    print("check uuid: ${widget.course.uuid}");

    final String apiUrl = "${ApiConstant.baseUrl}instructor/notice/store/${widget.course.uuid}";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('authToken') ?? '';
    print('check token: $token');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          // 'course_uuid': widget.course.uuid,
          'topic': _titleController.text,
          'details': _descriptionController.text,
        }),
      );

      if (response.statusCode == 200) {
        print("Add notice API response: ${response.statusCode}");
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notice added successfully')),
          );
          Navigator.pop(context); // Go back to the notice board screen
        } else {
          throw Exception('Failed to add notice: ${data['message']}');
        }
      } else {
        throw Exception('Failed to add notice');
      }
    } catch (e) {
      print('Add notice error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding notice: $e')),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.course.courseName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF00AFEE),
            fontSize: 22,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Notice Title',

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Notice Description',

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 5,
            ),
            const Spacer(),
            Row(
              children: [
                // Expanded(child: CustomButton(onTap: (){}, buttonText: 'Back')),
                Expanded(

                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _addNotice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00AFEE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      minimumSize: const Size(0, 38),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                        : const Text('Add Notice', style: TextStyle(fontSize: 13)),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00AFEE),
                      side: const BorderSide(color: Color(0xFF00AFEE)),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      minimumSize: const Size(0, 38),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Back', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}


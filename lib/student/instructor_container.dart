import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_constant.dart';

class InstructorContainer extends StatefulWidget {
  final TextEditingController replyController;
  final String courseId;
  final int? discussionId;
  final Function(Map<String, dynamic>)? onReplyPosted;

  const InstructorContainer({
    Key? key,
    required this.replyController,
    required this.courseId,
    required this.discussionId,
    this.onReplyPosted,
  }) : super(key: key);

  @override
  State<InstructorContainer> createState() => _InstructorContainerState();
}

class _InstructorContainerState extends State<InstructorContainer> {
  bool _isLoading = false;
  String _replyText = '';

  @override
  void initState() {
    super.initState();

    // Add listener to the controller to keep track of text changes
    widget.replyController.addListener(_updateReplyText);
  }

  @override
  void dispose() {
    // Remove listener when widget is disposed
    widget.replyController.removeListener(_updateReplyText);
    super.dispose();
  }

  // Keep track of text changes
  void _updateReplyText() {
    _replyText = widget.replyController.text;
  }

  // Clear text field with multiple safety measures
  void _clearTextField() {
    // Method 1: Set empty text directly
    widget.replyController.text = '';

    // Method 2: Use the clear method
    widget.replyController.clear();

    // Method 3: Update the UI
    setState(() {
      _replyText = '';
    });

    // Method 4: Force a rebuild with post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          // Double-check it's cleared
          if (widget.replyController.text.isNotEmpty) {
            widget.replyController.clear();
          }
        });
      }
    });
  }

  Future<void> _postReply() async {
    if (widget.discussionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No discussion found to reply to')),
      );
      return;
    }

    // Capture the text input before any operations
    final String replyText = _replyText.trim();

    if (replyText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reply')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Clear the text field immediately - IMPORTANT: This happens BEFORE the API call
      _clearTextField();

      // Get auth token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null || authToken.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to log in to post a reply')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Prepare API request
      final url = Uri.parse('${ApiConstant.baseUrl}student/course/create-discussion-reply');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'discussion_id': widget.discussionId,
          'course_id': widget.courseId,
          'reply_comment': replyText,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == true) {
          // Clear text field again (for extra safety)
          _clearTextField();

          // Notify parent widget about the new reply if callback is provided
          if (widget.onReplyPosted != null && responseData['data'] != null) {
            widget.onReplyPosted!(responseData['data']);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reply posted successfully'),backgroundColor: Colors.green,),
          );
        } else {
          // API returned success status code but with error in response body
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Failed to post reply')),
          );
        }
      } else {
        // Failed to post reply
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to post reply. Please try again.')),
        );
      }
    } catch (e) {
      // Handle any exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });

      // One final attempt to clear the text
      _clearTextField();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: widget.replyController,
            cursorColor:const Color(0xFF00AFEE),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Leave a reply...',
              hintStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00AFEE),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _isLoading ? null : () {
                // First check if there's text to submit
                if (widget.replyController.text.trim().isNotEmpty) {
                  _postReply();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a reply')),
                  );
                }
              },
              child: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                'Reply',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

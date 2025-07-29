import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constant.dart';

class ConversationContainer extends StatefulWidget {
  final TextEditingController messageController;
  final String courseId;
  final Function(List<dynamic>)? onDiscussionUpdated;

  const ConversationContainer({
    Key? key,
    required this.messageController,
    required this.courseId,
    this.onDiscussionUpdated,
  }) : super(key: key);

  @override
  _ConversationContainerState createState() => _ConversationContainerState();
}

class _ConversationContainerState extends State<ConversationContainer> {
  bool isExpanded = false;
  bool isLoading = false;

  Future<List<dynamic>?> _fetchDiscussionList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken') ?? '';

      final url = '${ApiConstant.baseUrl}student/course/discussion-list/${widget.courseId}';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Discussion list fetched successfully: ${response.body}');
        return responseData as List<dynamic>;
      } else {
        print('Failed to fetch discussion list: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch discussions: ${response.reasonPhrase}')),
        );
        return null;
      }
    } catch (e) {
      print('Error fetching discussion list: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching discussions: $e')),
      );
      return null;
    }
  }

  Future<void> _postDiscussion() async {
    if (widget.messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken') ?? '';

      if (token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to be logged in to post a discussion')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      final url = '${ApiConstant.baseUrl}student/discussion-create';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'course_id': widget.courseId,
          'comment': widget.messageController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("API successfully posted discussion: ${response.statusCode}");
        widget.messageController.clear();
        setState(() {
          isExpanded = false;
          isLoading = false;
        });

        // Fetch updated discussion list
        final newDiscussionData = await _fetchDiscussionList();
        if (newDiscussionData != null && widget.onDiscussionUpdated != null) {
          widget.onDiscussionUpdated!(newDiscussionData);
        }

        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Discussion posted successfully'),
        //     backgroundColor: Colors.green,
        //   ),
        // );
        // Get.snackbar(
        //   'Success',
        //   'Discussion posted successfully',
        //   snackPosition: SnackPosition.TOP,
        // );
      } else {
        print('Failed to post discussion: ${response.body}');
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Failed to post discussion: ${response.reasonPhrase}')),
        // );
        Get.snackbar(
          'Failed',
          'Failed to post discussion',
          snackPosition: SnackPosition.TOP,
        );

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error posting discussion: $e');
      setState(() {
        isLoading = false;
      });
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
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF00AFEE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.people, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Start a Conversation',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isExpanded) ...[
            const SizedBox(height: 12),
            TextField(
              controller: widget.messageController,
              cursorColor: const Color(0xFF00AFEE),
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                hintText: 'Write your message here...',
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
                onPressed: isLoading ? null : _postDiscussion,
                child: isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Text(
                  'Post',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

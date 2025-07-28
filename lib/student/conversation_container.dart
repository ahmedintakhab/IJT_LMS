import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_constant.dart';

class ConversationContainer extends StatefulWidget {
  final TextEditingController messageController;
  final String courseId;
  final Function(Map<String, dynamic>) onMessagePosted;

  const ConversationContainer({
    Key? key,
    required this.messageController,
    required this.courseId,
    required this.onMessagePosted,
  }) : super(key: key);

  @override
  _ConversationContainerState createState() => _ConversationContainerState();
}

class _ConversationContainerState extends State<ConversationContainer> {
  bool isExpanded = false;
  bool isLoading = false;

  Future<void> _postDiscussion() async {
    if (widget.messageController.text.isEmpty) return;

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
        final responseData = jsonDecode(response.body);
        print("API successfully post data");
        print("API status code: ${response.statusCode}");

        widget.messageController.clear();
        setState(() {
          isExpanded = false;
        });

        if (responseData != null && responseData['discussion'] != null) {
          widget.onMessagePosted(responseData['discussion']);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Discussion posted successfully'),
            backgroundColor: Colors.green,),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post discussion: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
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
                    backgroundColor:const Color(0xFF00AFEE),

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
              cursorColor:const Color(0xFF00AFEE),

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
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
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









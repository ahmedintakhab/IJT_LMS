
import 'package:flutter/material.dart';

import 'conversation_container.dart';
import 'instructor_container.dart';

class DiscussionPage extends StatefulWidget {
  final List<dynamic> discussionData;
  final String courseId;

  const DiscussionPage({
    Key? key,
    required this.discussionData,
    required this.courseId,
  }) : super(key: key);

  @override
  State<DiscussionPage> createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> {
  late List<dynamic> _discussionList;
  final TextEditingController _replyController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  late Map<String, dynamic> _authUserImages;
  // Track the selected discussion for reply
  int? _selectedDiscussionId;

  @override
  void initState() {
    super.initState();

    // Extract discussion items and auth_user_images
    _discussionList = [];
    _authUserImages = {};

    for (var item in widget.discussionData) {
      if (item is Map<String, dynamic> && item.containsKey('auth_user_images')) {
        _authUserImages = item['auth_user_images'];
      } else if (item is Map<String, dynamic> && item.containsKey('discussion_id')) {
        _discussionList.add(item);
      }
    }

    // Set the initially selected discussion if any exists
    if (_discussionList.isNotEmpty) {
      _selectedDiscussionId = _discussionList.first['discussion_id'];
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Method to handle new discussion being posted
  void _onMessagePosted(Map<String, dynamic> newDiscussion) {
    setState(() {
      // Add the new discussion to the top of the list
      _discussionList.insert(0, newDiscussion);
      // Set this as the selected discussion
      _selectedDiscussionId = newDiscussion['discussion_id'];
    });
  }

  // Method to handle new reply being posted
  void _onReplyPosted(Map<String, dynamic> replyData) {
    setState(() {
      // Find the discussion that this reply belongs to
      for (int i = 0; i < _discussionList.length; i++) {
        if (_discussionList[i]['discussion_id'] == _selectedDiscussionId) {
          // Initialize the replies list if it doesn't exist
          if (_discussionList[i]['discussion_replies_list'] == null) {
            _discussionList[i]['discussion_replies_list'] = [];
          }

          // Add the new reply to the discussion's replies list
          _discussionList[i]['discussion_replies_list'].add(replyData);

          // Update the total replies count
          _discussionList[i]['discussion_total_replies'] =
              (_discussionList[i]['discussion_total_replies'] ?? 0) + 1;

          break;
        }
      }
    });
  }

  // Method to select a discussion for replying
  void _selectDiscussionForReply(int discussionId) {
    setState(() {
      _selectedDiscussionId = discussionId;
      // Optionally scroll to the reply container
      // Or focus the reply text field
      _replyController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // First container with Start Conversation
              ConversationContainer(
                messageController: _messageController,
                courseId: widget.courseId,
                onMessagePosted: _onMessagePosted, // Pass the callback
              ),
              const SizedBox(height: 20),

              // Message container (only show if discussionData is not empty)
              if (_discussionList.isNotEmpty)
                ..._discussionList.map((discussion) {
                  final isSelected = discussion['discussion_id'] == _selectedDiscussionId;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: isSelected ? BoxDecoration(
                      border: Border.all(color: const Color(0XFF78A03F), width: 1),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[50],
                    ) : null,
                    padding: isSelected ? const EdgeInsets.all(8) : EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            _selectDiscussionForReply(discussion['discussion_id']);
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundImage: _getImageProvider(
                                  discussion['discussion_user_image'],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            discussion['discussion_user_name'] ?? 'Unknown User',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (discussion['discussion_user_type'] == "Instructor")
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[100],
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                "Instructor",
                                                style: TextStyle(
                                                  color: Colors.blue[800],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(discussion['discussion_comment'] ?? 'No comment'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 56, top: 8),
                          child: Row(
                            children: [
                              Text(
                                discussion['discussion_created_at'] ?? 'Unknown date',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Icon(Icons.message, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    (discussion['discussion_total_replies'] ?? 0).toString(),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Reply message (indented) - only show if discussion_replies_list is not empty
                        if (discussion['discussion_replies_list'] != null &&
                            discussion['discussion_replies_list'].isNotEmpty)
                          ...(discussion['discussion_replies_list'] ?? []).map((reply) {
                            return Container(
                              margin: const EdgeInsets.only(left: 40, top: 16, bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: _getImageProvider(
                                      reply['reply_user_image'],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                reply['reply_user_name'] ?? 'Unknown User',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              if (reply['reply_user_type'] == "Student")
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue[100],
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    "Instructor",
                                                    style: TextStyle(
                                                      color: Colors.blue[800],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(reply['reply_comment'] ?? 'No comment'),
                                          const SizedBox(height: 4),
                                          Text(
                                            reply['reply_created_at'] ?? '',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  );
                }).toList(),

              // Leave a reply container
              if (_selectedDiscussionId != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 8),
                      child: Text(
                        'Reply to discussion',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    InstructorContainer(
                      replyController: _replyController,
                      courseId: widget.courseId,
                      discussionId: _selectedDiscussionId,
                      onReplyPosted: _onReplyPosted,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to handle image URLs
  ImageProvider _getImageProvider(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty || !Uri.parse(imageUrl).isAbsolute) {
      // Use a local fallback image if the URL is invalid
      return const AssetImage('assets/avatar.png');
    } else {
      // Use the provided image URL
      return NetworkImage(imageUrl);
    }
  }
}


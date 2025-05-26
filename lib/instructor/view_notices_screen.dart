import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/api_constant.dart';
import 'instructor_notice_board.dart';

class ViewNoticesScreen extends StatefulWidget {
  final CourseNotice course;

  const ViewNoticesScreen({Key? key, required this.course}) : super(key: key);

  @override
  _ViewNoticesScreenState createState() => _ViewNoticesScreenState();
}

class _ViewNoticesScreenState extends State<ViewNoticesScreen> {
  List<dynamic> notices = [];
  String courseTitle = '';
  bool isLoading = true;
  Set<String> deletingUuids = {};

  @override
  void initState() {
    super.initState();
    fetchNotices();
  }

  Future<void> fetchNotices() async {
    String apiUrl = "${ApiConstant.baseUrl}instructor/notice-board-list/${widget.course.uuid}";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('authToken') ?? '';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('View Notices Api response: ${response.statusCode}');
        final data = jsonDecode(response.body);
        print('View Notices Api data: $data');

        if (data['success'] == true) {
          setState(() {
            courseTitle = data['data']['course_title'];
            notices = data['data']['notices'];
            isLoading = false;
          });
        } else {
          throw Exception('Failed to load notices');
        }
      } else {
        throw Exception('Failed to load notices');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching notices: $e')),
      );
    }
  }

  Future<void> deleteNotice(String uuid, int index) async {
    if (deletingUuids.contains(uuid)) return; // Prevent multiple delete requests for the same notice

    setState(() {
      deletingUuids.add(uuid); // Mark this notice as being deleted
    });

    String apiUrl = "${ApiConstant.baseUrl}instructor/notice/delete/$uuid";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('authToken') ?? '';

    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Delete Notice API response: ${response.statusCode}');
      print('Delete Notice API body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            notices.removeAt(index); // Remove the notice from the list
            deletingUuids.remove(uuid); // Clear the deleting state
          });
          Get.snackbar(
            'Successful',
            responseData['message'] ?? 'Notice deleted successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          throw Exception(responseData['message'] ?? 'Failed to delete notice');
        }
      } else {
        throw Exception('Failed to delete notice: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        deletingUuids.remove(uuid); // Clear the deleting state on error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting notice: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$courseTitle',
          style: const TextStyle(fontWeight: FontWeight.bold,
              color: Color(0XFF00AFEE), fontSize: 22),
          maxLines: 2,
        ),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0XFF00AFEE)))
          : notices.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No notices available for this course.'),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: notices.length,
        itemBuilder: (context, index) {
          final notice = notices[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Title',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        notice['topic'],
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.end,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Date',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        notice['date'],
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('View notice ${notice['topic']} for $courseTitle')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0XFF00AFEE),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('View'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Edit notice ${notice['topic']} for $courseTitle')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Edit'),
                    ),
                    ElevatedButton(
                      onPressed: deletingUuids.contains(notice['uuid'])
                          ? null
                          : () {
                        deleteNotice(notice['uuid'], index);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: deletingUuids.contains(notice['uuid'])
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
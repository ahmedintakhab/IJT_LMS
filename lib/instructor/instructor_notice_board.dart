import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:learn_megnagmet/instructor/view_notices_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/api_constant.dart';
import 'add_notice_screen.dart';

class InstructorNoticeBoard extends StatefulWidget {
  const InstructorNoticeBoard({Key? key}) : super(key: key);

  @override
  State<InstructorNoticeBoard> createState() => _InstructorNoticeBoardState();
}

class _InstructorNoticeBoardState extends State<InstructorNoticeBoard> {
  List<CourseNotice> _courseNotices = [];
  String noticeBoardTitle = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNoticeBoardData();
  }

  Future<void> fetchNoticeBoardData() async {
    String apiUrl = "${ApiConstant.baseUrl}instructor/notice-board";
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
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            noticeBoardTitle = data['data']['title'];
            _courseNotices = (data['data']['courses'] as List).map((course) {
              return CourseNotice(
                id: course['id'].toString(),
                courseName: course['title'],
                courseImage: course['image'],
                uuid: course['uuid'],
                totalNotices: course['total_notices'] ?? 0, // Fetch total_notices from API
              );
            }).toList();
            isLoading = false;
          });
        } else {
          throw Exception('Failed to load notice board data');
        }
      } else {
        throw Exception('Failed to load notice board data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching notice board data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Center(
          child: Text(
            noticeBoardTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00AFEE), fontSize: 22),
          ),
        ),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00AFEE)))
          : _courseNotices.isEmpty
          ? const Center(child: Text('No courses found'))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Course Notices',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      Expanded(
                        child: ListView.separated(
                          itemCount: _courseNotices.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            return CourseNoticeItem(
                              courseNotice: _courseNotices[index],
                              onAddNotice: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddNoticeScreen(course: _courseNotices[index]),
                                  ),
                                );
                              },
                              onViewList: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewNoticesScreen(course: _courseNotices[index]),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CourseNoticeItem extends StatelessWidget {
  final CourseNotice courseNotice;
  final VoidCallback onAddNotice;
  final VoidCallback onViewList;

  const CourseNoticeItem({
    Key? key,
    required this.courseNotice,
    required this.onAddNotice,
    required this.onViewList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160.h,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 400;

          if (isSmallScreen) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCourseImage(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildCourseName(),
                            const SizedBox(height: 6),
                            _buildNoticesInfo(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildAddButton()),
                    const SizedBox(width: 8),
                    Expanded(child: _buildViewButton()),
                  ],
                ),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCourseImage(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildCourseName(),
                            const SizedBox(height: 6),
                            _buildNoticesInfo(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildAddButton()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildViewButton()),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildCourseImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          courseNotice.courseImage,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: Icon(
                Icons.book,
                color: Colors.grey[600],
                size: 40,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCourseName() {
    return Text(
      courseNotice.courseName,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildNoticesInfo() {
    return Row(
      children: [
        const Icon(
          Icons.notifications,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          'Notices: ${courseNotice.totalNotices}',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton(
      onPressed: onAddNotice,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00AFEE),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        minimumSize: const Size(0, 38),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text('ADD NOTICE', style: TextStyle(fontSize: 13)),
    );
  }

  Widget _buildViewButton() {
    return OutlinedButton(
      onPressed: onViewList,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF00AFEE),
        side: const BorderSide(color: Color(0xFF00AFEE)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        minimumSize: const Size(0, 38),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text('VIEW LIST', style: TextStyle(fontSize: 13)),
    );
  }
}

class CourseNotice {
  final String id;
  final String courseName;
  final String courseImage;
  final String uuid;
  final int totalNotices; // Add totalNotices field

  CourseNotice({
    required this.id,
    required this.courseName,
    required this.courseImage,
    required this.uuid,
    required this.totalNotices, // Make totalNotices a required parameter
  });
}

















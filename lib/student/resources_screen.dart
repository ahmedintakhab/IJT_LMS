import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constant.dart';
import 'content_display_screen.dart';
import 'text_content_screen.dart';

class ResourcesScreen extends StatelessWidget {
  final List<dynamic> courseContent;
  final Function? onLectureOpen;

  const ResourcesScreen({
    Key? key,
    required this.courseContent,
    this.onLectureOpen,
  }) : super(key: key);

  // Function to mark lecture as complete via API
  Future<void> _markLectureAsComplete(String lectureId) async {
    const String apiUrl = '${ApiConstant.baseUrl}student/complete-lecture';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'lecture_id': lectureId,
        }),
      );

      if (response.statusCode == 200) {
        print('Lecture complete progress api response:${response.statusCode}');
      } else {
        print('Failed to mark lecture as complete');
      }
    } catch (e) {
      print('Failed to mark lecture as complete: $e');
    }
  }

  // Function to handle content opening based on type
  Future<void> _openContent(BuildContext context, Map<String, dynamic> lecture) async {
    final Map<String, dynamic> data = lecture['data'] ?? {};
    final String type = lecture['type']?.toString() ?? '';
    final String source = lecture['lecture_preview_src']?.toString() ?? '';
    final String title = lecture['title']?.toString() ?? 'Untitled Lecture';
    final String lectureId = lecture['id']?.toString() ?? '';
     // print('chekc the type, source and title:$lectureId $type $title');

    try {
      if (type.isEmpty || source.isEmpty) {
        Get.snackbar('Error', 'Invalid content type or source');
        return;
      }
      await _markLectureAsComplete(lectureId);

      if (type == 'text') {
        // Navigate to TextContentScreen for HTML text
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TextContentScreen(
              title: title,
              htmlContent: source,
            ),
          ),
        );
      } else if (['pdf', 'video', 'youtube', 'audio', 'image'].contains(type)) {
        // Navigate to ContentDisplayScreen for other types
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContentDisplayScreen(
              title: title,
              contentType: type,
              source: source,
            ),
          ),
        );
      } else {
        Get.snackbar('Error', 'Unsupported content type: $type');
        return;
      }

      if (onLectureOpen != null) onLectureOpen!();
    } catch (e) {
      Get.snackbar('Error', 'Failed to open content: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: courseContent.isEmpty
              ? const Center(child: Text('No lessons available'))
              : ListView.builder(
            itemCount: courseContent.length,
            itemBuilder: (context, index) {
              var lesson = courseContent[index];
              List<dynamic> lectures = lesson['lectures'] ?? [];

              return Padding(
                padding: EdgeInsets.only(
                  left: 15.w,
                  right: 15.w,
                  top: 8.h,
                  bottom: 8.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display the lesson name
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lesson['name']?.toString() ?? 'Lesson',
                              style: TextStyle(
                                fontFamily: 'Nastaleeq',
                                color: Colors.black,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Display the lectures
                    ...lectures.map((lecture) {
                      return Padding(
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          height: 80.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22.h),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF23408F).withOpacity(0.14),
                                offset: const Offset(-4, 5),
                                blurRadius: 16,
                              ),
                            ],
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Lecture number
                                Container(
                                  height: 55.h,
                                  width: 33.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22.h),
                                    color: const Color(0xFF00AFEE),
                                  ),
                                  child: Center(
                                    child: Text(
                                      lecture['lecture_no']?.toString() ?? '',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17.sp,
                                        fontFamily: 'Nastaleeq',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),

                                // Lecture title
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 10),
                                    child: Center(
                                      child: Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Text(
                                          lecture['title']?.toString() ?? 'Untitled Lecture',
                                          style: TextStyle(
                                            color: const Color(0xFF000000),
                                            fontSize: 18.sp,
                                            fontFamily: 'Nastaleeq',
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Open icon
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      child: Icon(
                                        Icons.open_in_new,
                                        color: const Color(0xFF00AFEE),
                                        size: 26.w,
                                      ),
                                      onTap: () => _openContent(context, lecture),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: EdgeInsets.only(bottom: 40.h, top: 15.h),
            child: Container(
              height: 56.h,
              width: 374.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.h),
                color: const Color(0xFF00AFEE),
              ),
              child: Center(
                child: Text(
                  "Continue Course",
                  style: TextStyle(
                    color: const Color(0xFFFFFFFF),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Gilroy',
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
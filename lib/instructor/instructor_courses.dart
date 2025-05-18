import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../utils/api_constant.dart';

class InstructorCourses extends StatefulWidget {
  const InstructorCourses({Key? key}) : super(key: key);

  @override
  State<InstructorCourses> createState() => _InstructorCoursesState();
}

class _InstructorCoursesState extends State<InstructorCourses> {
  List<dynamic> courses = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }
  Future<void> fetchCourses() async {
    String apiUrl = "${ApiConstant.baseUrl}instructor/course";
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

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          print('Courses data: ${data['data']}');
          setState(() {
            courses = data['data'];
            isLoading = false;
          });
        } else {
          print('API success flag is false');
          throw Exception('Failed to load courses: ${data['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to load courses. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Detailed error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching courses: ${e.toString()}')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    // Initialize screen size for responsive design
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812), // Standard mobile design size
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Instructor Courses',
          style: TextStyle(
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w700,
              fontSize: 24,color: Color(0XFF00AFEE)
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0XFF00AFEE)))
          : courses.isEmpty
          ? const Center(child: Text('No courses found'))
          :SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
          child: Column(
            children: courses.map((course) => _buildCourseCard(course)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF23408F).withOpacity(0.14),
            offset: const Offset(-4, 5),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: Course Image and Details
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  course['image'],
                  height: 150.h,
                  width: 200.w,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              // Course Name
              SizedBox(
                width: 190.w, // Adjust width to fit mobile screen
                child: Text(
                  course['title'] ?? '',
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 5.h),
              // Price and Rating
              Row(
                children: [
                  Text(
                    ' Rs${course['price']}' ?? '',
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Row(
                    children: [
                      Text(
                        course['average_rating'].toString(),
                        style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Row(
                        children: List.generate(
                          5,
                              (index) => Icon(
                            index < double.parse(course['average_rating']).floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '(${course['review_count']})',
                        style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 5.h),
              // Status
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF00AFEE),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  course['status'] == 1 ? 'Published' : 'Unpublished',
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    fontSize: 12.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Right Side: Buttons
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildButton(
                text: 'Resources',
                color: const Color(0xFF8CC13F),
                onTap: () {
                  // Add functionality for Resources button
                  print('Resources button tapped');
                },
              ),
              SizedBox(height: 18.h),
              _buildButton(
                text: 'Quiz',
                color: const Color(0xFF00AFEE),
                onTap: () {
                  // Add functionality for Quiz button
                  print('Quiz button tapped');
                },
              ),
              SizedBox(height: 18.h),
              _buildButton(
                text: 'Assignment',
                color: const Color(0xFF7B3F8C),
                onTap: () {
                  // Add functionality for Assignment button
                  print('Assignment button tapped');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.w,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}



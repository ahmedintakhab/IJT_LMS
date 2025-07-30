import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/student/student_tabbar_screen.dart';
import 'package:learn_megnagmet/utils/api_constant.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import '../utils/screen_size.dart';

class MyLearningCourses extends StatefulWidget {
  const MyLearningCourses({Key? key}) : super(key: key);

  @override
  State<MyLearningCourses> createState() => _MyLearningCoursesState();
}

class _MyLearningCoursesState extends State<MyLearningCourses> {
  List<dynamic> courses = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadDataWithShimmer();
  }

  Future<void> _loadDataWithShimmer() async {
    if (!mounted) return; // Check if widget is still mounted
    setState(() {
      isLoading = true;
      hasError = false;
    });
    await fetchMylearningCourses();
  }

  Future<void> fetchMylearningCourses() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = '${ApiConstant.baseUrl}student/my-learning';
      final response = await http.get(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('My learning courses API response: ${response.statusCode}');
        final data = json.decode(response.body);
        print('API data: $data');
        if (data['success'] == true && data['data'] != null && data['data']['data'] != null) {
          if (!mounted) return; // Check if widget is still mounted before setState
          setState(() {
            courses = data['data']['data'];
            isLoading = false;
          });
          return;
        } else {
          throw Exception('No courses found in API response');
        }
      }
      throw Exception('Failed to load courses: ${response.statusCode}');
    } catch (e) {
      print('Recent courses error: ${e.toString()}');
      if (!mounted) return; // Check if widget is still mounted before setState
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeScreenSize(context);
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 30.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Image.asset(
                    "assets/back_arrow.png",
                    height: 24.h,
                    width: 24.w,
                  ),
                ),
                SizedBox(width: 16.w),
                Text(
                  "My Courses",
                  style: TextStyle(
                    fontSize: 26.sp,
                    color: const Color(0XFF000000),
                    fontFamily: 'Nastaleeq',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? _buildShimmerEffect()
                : hasError
                ? _buildErrorWidget()
                : courses.isEmpty
                ? _buildEmptyWidget()
                : _buildCourseList(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            'Failed to load courses',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              _loadDataWithShimmer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0XFF00AFEE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text(
              'Retry',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 50, color: Colors.blue),
          SizedBox(height: 16.h),
          Text(
            'No courses available',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              _loadDataWithShimmer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0XFF00AFEE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text(
              'Refresh',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 10.h),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: EdgeInsets.only(bottom: 10.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.h),
              boxShadow: [
                BoxShadow(
                  color: const Color(0XFF00AFEE).withOpacity(0.14),
                  offset: const Offset(-4, 5),
                  blurRadius: 16.h,
                ),
              ],
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 210.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.h),
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 27.h,
                        width: 59.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.h),
                          color: Colors.grey,
                        ),
                      ),
                      Container(
                        height: 23.h,
                        width: 91.w,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 11.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20.h,
                        width: 150.w,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 11.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey,
                              ),
                              SizedBox(width: 10.w),
                              Container(
                                height: 20.h,
                                width: 100.w,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          Container(
                            height: 30.h,
                            width: 74.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.h),
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCourseList() {
    return ListView.builder(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 10.h),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        final instructor = course['course']['instructor'];
        final authorName = '${instructor['first_name']} ${instructor['last_name']}';
        final progress = (course['progress'] ?? 0) / 100.0; // API returns 0-100
        // print('Check the slug on my learning courses: ${course['course']['slug']}');

        return GestureDetector(
          onTap: () {
             Get.to(() =>TabBarDetails( slug: course['course']['slug']));
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 10.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.h),
              boxShadow: [
                BoxShadow(
                  color: const Color(0XFF00AFEE).withOpacity(0.14),
                  offset: const Offset(-4, 5),
                  blurRadius: 16.h,
                ),
              ],
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 250.h,
                      width: double.infinity,
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.h),
                        image: DecorationImage(
                          image: NetworkImage(course['course']['image_url'] ?? ''),
                          fit: BoxFit.fill,
                          // onError: (exception, stackTrace) {
                          //   return const Icon(Icons.broken_image, size: 50);
                          // },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: SizedBox(
                          width: double.infinity, // Take full width
                          child: Padding(
                            padding: EdgeInsets.only(right: 10.w), // Consistent right padding
                            child: Text(
                              course['course']['title'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 22.sp,
                                fontFamily: 'Nastaleeq',
                                color: const Color(0XFF000000),
                              ),
                              textAlign: TextAlign.right, // Force right alignment
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 11.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 10.w),
                              Text(
                                authorName,
                                style: TextStyle(
                                  color: const Color(0XFF00AFEE),
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Nastaleeq',
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 30.h,
                            width: 74.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.h),
                              color: const Color(0XFFE5ECFF),
                            ),
                            child: Center(
                              child: Text(
                                course['course']['learner_accessibility'] == 'free' ? 'Free' : course['course']['price'],
                                style: TextStyle(
                                  color: const Color(0XFF00AFEE),
                                  fontFamily: 'Nastaleeq',
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      LinearPercentIndicator(
                        padding: EdgeInsets.zero,
                        width: 300.0.w,
                        lineHeight: 12.0.h,
                        percent: progress,
                        trailing: Padding(
                          padding: EdgeInsets.only(left: 4.w),
                          child: Text(
                            "${(progress * 100).toInt()}%",
                            style: const TextStyle(
                              fontFamily: 'Gilroy',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        backgroundColor: const Color(0XFFDEDEDE),
                        progressColor: const Color(0XFF00AFEE),
                        barRadius: const Radius.circular(22),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        );
      },
    );
  }
}
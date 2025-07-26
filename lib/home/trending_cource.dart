import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/utils/api_constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

import '../cources/cources.dart';

class TrendingCource extends StatefulWidget {
  const TrendingCource({Key? key}) : super(key: key);

  @override
  State<TrendingCource> createState() => _TrendingCourceState();
}

class _TrendingCourceState extends State<TrendingCource> {
  List<dynamic> courses = [];
  bool isLoading = true;
  bool hasError = false;
  Map<int, bool> likedCourses = {};

  @override
  void initState() {
    super.initState();
    _loadDataWithShimmer();
  }

  Future<void> _loadDataWithShimmer() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    await fetchTrendingCourses();
  }



  Future<void> fetchTrendingCourses() async {
    try {
      final url = '${ApiConstant.baseUrl}courses-list';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data']['courses'] != null) {
          setState(() {
            courses = data['data']['courses'];
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load courses');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Trending courses error: ${e.toString()}');
      setState(() {
        isLoading = false;
        hasError = true;
      });

    }
  }

  void toggleLike(int courseId) {
    setState(() {
      likedCourses[courseId] = !(likedCourses[courseId] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 22.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
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
                      "Trending Course",
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: const Color(0XFF000000),
                        fontFamily: 'Nastaleeq',
                        fontWeight: FontWeight.bold,
                      ),
                      textDirection: TextDirection.rtl,

                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
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
        ),
      ),
    );
  }
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 50, color: Colors.red),
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
              _loadDataWithShimmer(); // Changed to use _loadDataWithShimmer
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
      child: Text(
        'No courses available',
        style: TextStyle(
          fontSize: 16.sp,
          color: Colors.black,
        ),
      ),
    );
  }


  Widget _buildShimmerEffect() {
    return GridView.count(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      crossAxisCount: 2,
      crossAxisSpacing: 18.73,
      mainAxisSpacing: 20,
      childAspectRatio: 0.650,
      children: List.generate(6, (index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Container(
                height: 170.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(6.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 6.h),
                    Container(
                      height: 16.h,
                      width: double.infinity,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 27.h,
                          width: 50.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey,
                          ),
                        ),
                        Container(
                          height: 21.h,
                          width: 76.w,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }

  Widget _buildCourseList() {
    return GridView.count(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      crossAxisCount: 2,
      crossAxisSpacing: 18.73,
      mainAxisSpacing: 20,
      childAspectRatio: 0.650,
      children: courses.map((course) => Container(
        width: 187.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: const Color(0XFF00AFEE).withOpacity(0.14),
              offset: const Offset(-4, 5),
              blurRadius: 16,
            ),
          ],
          color: const Color(0XFFFFFFFF),
        ),
        child: GestureDetector(
          onTap: () {
            Get.to(MyCources(slug: course['slug'] ?? '',));

          },
          child: Column(
            children: [
              Container(
                height: 170.h,
                width: double.infinity,
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(course['image_url'] ?? ''),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Directionality(
                textDirection: TextDirection.rtl,
                child: SizedBox(
                  width: double.infinity, // Take full width
                  child: Padding(
                    padding: EdgeInsets.only(right: 10.w), // Consistent right padding
                    child: Text(
                      course['title'] ?? '',
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
            ],
          ),
        ),
      )).toList(),
    );
  }
}
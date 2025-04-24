import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/utils/api_constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

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
                        fontFamily: 'Gilroy',
                        fontWeight: FontWeight.bold,
                      ),
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
                height: 165.h,
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
        child: Column(
          children: [
            Container(
              height: 165.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(course['image_url'] ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 10.h, left: 10.w),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => toggleLike(course['id']),
                    child: Container(
                      height: 30.h,
                      width: 30.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Image.asset(
                          "assets/like.png",
                          height: 13.08.h,
                          width: 13.08.w,
                          color: likedCourses[course['id']] ?? false
                              ? Colors.red
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 6.h),
                  Text(
                    course['title'] ?? '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Gilroy',
                      color: const Color(0XFF000000),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Padding(
                  //   padding: EdgeInsets.only(top: 6.h),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       Container(
                  //         height: 27.h,
                  //         width: 50.w,
                  //         decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(20),
                  //           color: const Color(0XFFFAF4E1),
                  //         ),
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //           children: [
                  //             Image.asset(
                  //               "assets/staricon.png",
                  //               height: 15.h,
                  //               width: 15.w,
                  //             ),
                  //             Text(
                  //               course['average_rating'] ?? '0.00',
                  //               style: TextStyle(
                  //                 color: Color(0XFFFFC403),
                  //                 fontFamily: 'Gilroy',
                  //                 fontSize: 12.sp,
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //       SizedBox(
                  //         height: 21.h,
                  //         width: 76.w,
                  //         child: Row(
                  //           children: [
                  //             Image.asset(
                  //               "assets/clock.png",
                  //               height: 17.h,
                  //               width: 17.w,
                  //             ),
                  //             SizedBox(width: 4.w),
                  //             Text(
                  //               course['learner_accessibility'] == 'free'
                  //                   ? 'Free'
                  //                   : 'Paid',
                  //               style: TextStyle(
                  //                 fontSize: 12.sp,
                  //                 color: const Color(0XFF000000),
                  //                 fontWeight: FontWeight.w400,
                  //                 fontFamily: 'Gilroy',
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      // CircleAvatar(
                      //   radius: 15,
                      //   backgroundColor: Colors.grey[200],
                      //   child: Text(
                      //     course['author']?.toString().substring(0, 1) ?? '',
                      //     style: TextStyle(
                      //       color: Colors.blue,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          course['author'] ?? '',
                          style: TextStyle(
                            color: const Color(0XFF00AFEE),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Gilroy',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: 21.h,
                        width: 50.w,
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/clock.png",
                              height: 17.h,
                              width: 17.w,
                              color: const Color(0XFF00AFEE),

                            ),
                            SizedBox(width: 4.w),
                            Text(
                              course['learner_accessibility'] == 'free'
                                  ? 'Free'
                                  : 'Paid',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0XFF000000),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Gilroy',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}
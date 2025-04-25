import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/utils/api_constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import '../utils/screen_size.dart';

class RecentlyAdded extends StatefulWidget {
  const RecentlyAdded({Key? key}) : super(key: key);

  @override
  State<RecentlyAdded> createState() => _RecentlyAddedState();
}

class _RecentlyAddedState extends State<RecentlyAdded> {
  List<dynamic> courses = [];
  bool isLoading = true;
  bool hasError = false;

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
    await fetchRecentCourses();
  }

  Future<void> fetchRecentCourses() async {
    try {
      final url = '${ApiConstant.baseUrl}courses-list';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data']['courses'] != null) {
          setState(() {
            courses = data['data']['courses'];
            isLoading = false;
          });
          return;
        }
      }
      throw Exception('Failed to load courses');
    } catch (e) {
      print('Recent courses error: ${e.toString()}');
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
          SizedBox(height: 60.h),
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
                  "Recently Added Course",
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: Color(0XFF000000),
                    fontFamily: 'Gilroy',
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
          Icon(Icons.info_outline, size: 50, color: Colors.blue),
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
        return
          GestureDetector(
            onTap: (){
              // Get.to(RecentCourceDetail(corcedetail: recentcource[index],));
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
                      height: 210.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.h),
                        image: DecorationImage(
                          image: NetworkImage(course['image_url'] ?? ''),
                          fit: BoxFit.cover,
                          // errorBuilder: (context, error, stackTrace) {
                          //   return Container(
                          //     color: Colors.grey[200],
                          //     child: Icon(Icons.broken_image, size: 50),
                          //   );
                          // },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.w, top: 10.h),
                      child: Container(
                        height: 33.h,
                        width: 32.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: IconButton(
                          splashRadius: 10.h,
                          onPressed: () {},
                          icon: Image.asset("assets/saveicon.png"),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 55.w, top: 10.h),
                      child: Container(
                        height: 33.h,
                        width: 32.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: Image.asset("assets/shareicon.png"),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                // Padding(
                //   padding: EdgeInsets.only(left: 10.w),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Container(
                //         height: 27.h,
                //         width: 59.w,
                //         decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(6.h),
                //           color: const Color(0XFFFAF4E1),
                //         ),
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //           children: [
                //             Image.asset(
                //               "assets/staricon.png",
                //               height: 17.h,
                //               width: 17.w,
                //             ),
                //             Text(
                //               course['average_rating'] ?? '0.00',
                //               style: TextStyle(
                //                 color: Color(0XFFFFC403),
                //                 fontFamily: 'Gilroy',
                //                 fontSize: 15.sp,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //       SizedBox(
                //         height: 23.h,
                //         width: 91.w,
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
                //                 fontSize: 15.sp,
                //                 color: const Color(0XFF000000),
                //                 fontFamily: 'Gilroy',
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                SizedBox(height: 11.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course['title'] ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                          fontFamily: 'Gilroy',
                          color: Color(0XFF000000),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 11.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // CircleAvatar(
                              //   radius: 20,
                              //   backgroundColor: Colors.grey[200],
                              //   child: Text(
                              //     course['author']?.toString().substring(0, 1) ?? '',
                              //     style: TextStyle(
                              //       color: Colors.blue,
                              //       fontWeight: FontWeight.bold,
                              //     ),
                              //   ),
                              // ),
                              SizedBox(width: 10.w),
                              Text(
                                course['author'] ?? '',
                                style: TextStyle(
                                  color: Color(0XFF00AFEE),
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Gilroy',
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
                                course['price'] == '0.00' ? 'Free' : course['price'],
                                style: TextStyle(
                                  color: const Color(0XFF00AFEE),
                                  fontFamily: 'Gilroy',
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
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
}
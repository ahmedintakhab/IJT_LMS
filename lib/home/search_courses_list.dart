import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../cources/cources.dart';

class SearchCoursesList extends StatelessWidget {
  final List<dynamic> courses;
  final bool isLoading;
  final String errorMessage;

  const SearchCoursesList({
    Key? key,
    required this.courses,
    required this.isLoading,
    required this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: Color(0XFF00AFEE),));
    }

    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trending Courses',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 240.h, // Fixed height for horizontal list
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: courses.length,
            itemBuilder: (context, index) {
              return Container(
                width: 180.w,
                margin: EdgeInsets.only(right: 12.w),
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => MyCources(slug: courses[index]['slug']));
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 170.h,
                        width: 170.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(courses[index]['image_url']),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          courses[index]['title'],
                          style: TextStyle(
                            fontFamily: 'Nastaleeq',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                           textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
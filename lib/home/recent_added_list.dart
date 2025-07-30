import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:learn_megnagmet/cources/cources.dart';
import 'package:learn_megnagmet/home/recent_added_cource_detail.dart';
import 'package:shimmer/shimmer.dart';

class RecentAddedList extends StatefulWidget {
  final List<Map<String, dynamic>> recentAdded;
  final List<bool> buttonStatuses;
  final Function(int) toggleRecent;
  final bool isLoading;

  const RecentAddedList({
    Key? key,
    required this.recentAdded,
    required this.buttonStatuses,
    required this.toggleRecent,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<RecentAddedList> createState() => _RecentAddedListState();
}

class _RecentAddedListState extends State<RecentAddedList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0XFFFFFFFF),
      height: 323.h,
      width: double.infinity.w,
      child: widget.isLoading
          ? Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          physics: const BouncingScrollPhysics(),
          primary: false,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: 3, // Show 3 shimmer items
          itemBuilder: (BuildContext context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Container(
                width: 276.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 158.h,
                      width: 276.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      height: 25.h,
                      width: 100.w,
                      color: Colors.white,
                      margin: EdgeInsets.only(left: 10.w),
                    ),
                    SizedBox(height: 11.h),
                    Container(
                      height: 20.h,
                      width: 200.w,
                      color: Colors.white,
                      margin: EdgeInsets.only(left: 10.w, right: 10.w),
                    ),
                    SizedBox(height: 11.h),
                    Container(
                      height: 40.h,
                      width: 250.w,
                      color: Colors.white,
                      margin: EdgeInsets.only(left: 10.w, right: 10.w),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        physics: const BouncingScrollPhysics(),
        primary: false,
        shrinkWrap: true,
        itemCount: widget.recentAdded.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, index) {
          final course = widget.recentAdded[index];
          return GestureDetector(
            onTap: () {
               Get.to(MyCources(slug: course['slug'],));
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w,vertical: 10.h),
              child: Container(
                width: 276.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0XFF00AFEE).withOpacity(0.14),
                      offset: const Offset(-4, 5),
                      blurRadius: 16,
                    ),
                  ],
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 200.h,
                      width: 276.w,
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(course['image'] ?? ''),
                          fit: BoxFit.fill,
                        ),
                      ),

                    ),
                    SizedBox(height: 20.h),
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
            ),
          );
        },
      ),
    );
  }
}
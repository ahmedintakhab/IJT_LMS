import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shimmer/shimmer.dart';

import '../cources/cources.dart';

class TrendingCourceList extends StatefulWidget {
  final List<Map<String, dynamic>> trendingCource;
  final bool isLoading;

  const TrendingCourceList({
    Key? key,
    required this.trendingCource,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<TrendingCourceList> createState() => _TrendingCourceListState();
}

class _TrendingCourceListState extends State<TrendingCourceList> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 245.h,
      width: double.infinity.w,
      child: widget.isLoading
          ? Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: 3, // Show 3 shimmer items
          itemBuilder: (BuildContext context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 175.h,
                    width: 175.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: 175.w,
                    height: 16.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 5.h),
                  Container(
                    width: 100.w,
                    height: 14.h,
                    color: Colors.white,
                  ),
                ],
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
        scrollDirection: Axis.horizontal,
        itemCount: widget.trendingCource.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: GestureDetector(
              onTap: () {
                Get.to(MyCources(slug: widget.trendingCource[index]['slug'] ?? ''));

              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 200.h,
                    width: 276.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      image: DecorationImage(
                        image: NetworkImage(
                          widget.trendingCource[index]['image'] ?? '',
                        ),
                        fit: BoxFit.fill,
                      ),
                    ),

                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    width: 275.w,height: 20,
                    child: Text(
                      widget.trendingCource[index]['title'] ?? '',
                      style: TextStyle(
                        fontFamily: 'Nastaleeq',
                        fontWeight: FontWeight.w700,
                        fontSize: 20.sp,
                        color: const Color(0XFF000000),
                      ),
                      textDirection: TextDirection.rtl,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 5.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
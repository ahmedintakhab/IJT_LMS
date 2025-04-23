import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learn_megnagmet/models/design_list.dart';

class HorizontalDesignList extends StatelessWidget {
  final List<Design> design;

  const HorizontalDesignList({Key? key, required this.design}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140.h, // Increased height to accommodate image and text
      width: double.infinity,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        shrinkWrap: true,
        primary: false,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: design.length,
        itemBuilder: (BuildContext context, index) {
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0.w : 12.w),
            child: Container(
              width: 110.w, // Fixed width for each item
              decoration: BoxDecoration(
                color: design[index].color != null
                    ? Color(int.parse(
                    design[index].color!.replaceFirst('0XFF', '0xFF')))
                    : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage(design[index].image!),
                    height: 70.h,
                    width: 70.w,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 70.h,
                        width: 70.w,
                        color: Colors.grey,
                        child: const Center(child: Text('Image not found')),
                      );
                    },
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text(
                      design[index].name!,
                      style: TextStyle(
                        color: const Color(0XFF000000),
                        fontSize: 14.sp,
                        fontFamily: 'Gilroy',
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learn_megnagmet/models/design_list.dart';

class HorizontalDesignList extends StatelessWidget {
  final List<Design> design;

  const HorizontalDesignList({Key? key, required this.design}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.h,
      width: double.infinity,
      child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          shrinkWrap: true,
          primary: false,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: design.length,
          itemBuilder: (BuildContext context, index) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0.w : 6.w),
                  child: Image(
                    image: AssetImage(design[index].image!),
                    height: 110.h,
                    width: 110.w,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 60.h),
                  child: Text(
                    design[index].name!,
                    style: TextStyle(
                        color: Color(0XFF000000),
                        fontSize: 14.sp,
                        fontFamily: 'Gilroy',
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            );
          }),
    );
  }
}
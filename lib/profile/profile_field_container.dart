import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileFieldContainer extends StatelessWidget {
  final String title;
  final Widget icon;
  final VoidCallback onTap;

  const ProfileFieldContainer({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 60.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.h),
            boxShadow: [
              BoxShadow(
                color: const Color(0XFF23408F).withOpacity(0.14),
                offset: const Offset(-4, 5),
                blurRadius: 16.h,
              ),
            ],
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 15.w),
                      SizedBox(
                        height: 24.h,
                        width: 24.w,
                        child: icon,
                      ),

                      SizedBox(width: 15.w),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontFamily: 'Gilroy',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 15.w),
                    child: Row(
                      children: [
                        Image(
                          image: const AssetImage("assets/right_arrow.png"),
                          height: 24.h,
                          width: 24.w,
                          color: Color(0XFF00AFEE),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
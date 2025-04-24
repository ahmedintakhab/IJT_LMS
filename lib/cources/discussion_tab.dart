import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Discussion extends StatelessWidget {
  const Discussion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Discussion Screen",
        style: TextStyle(
          fontFamily: 'Gilroy',
          fontWeight: FontWeight.w700,
          fontSize: 24.sp,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
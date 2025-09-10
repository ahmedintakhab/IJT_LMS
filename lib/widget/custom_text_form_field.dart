import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final TextStyle? hintStyle;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final String? labelText;
  final int? maxLines;


  const CustomTextFormField({
    super.key,
    this.controller,
    required this.hintText,
    this.hintStyle,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.labelText,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,cursorColor: Color(0XFF00AFEE),
      obscureText: obscureText,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle ??
            TextStyle(
              fontSize: 15.sp,
              fontFamily: 'Gilroy',
              color: const Color(0xFF9B9B9B),
              fontWeight: FontWeight.bold,
            ),
        labelText: labelText, // Use optional labelText
        labelStyle: TextStyle(
          fontSize: 16.sp,
          fontFamily: 'Gilroy',
          color: Colors.grey, // Match theme color
          // color: const Color(0xFF00AFEE), // Match theme color
          fontWeight: FontWeight.w600,
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.h) ,
            borderSide: BorderSide(color: const Color(0XFF00AFEE), width: 1.w),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: const Color(0xFFDEDEDE), width: 1.w),
          borderRadius: BorderRadius.circular(6.h)        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.h),
          borderSide: BorderSide(color: Colors.red, width: 1.w),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.h),
          borderSide: BorderSide(color: Colors.red, width: 1.w),
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: EdgeInsets.only(left: 20.w, top: 17.h, bottom: 17.h),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}
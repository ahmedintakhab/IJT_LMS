import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({super.key, required TextEditingController controller});

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      decoration: InputDecoration(
        labelText: 'Phone Number',
        labelStyle: TextStyle(
          fontFamily: 'Gilroy',
          fontWeight: FontWeight.w700,
          fontSize: 15.sp,
          color: const Color(0xFF9B9B9B),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFFDEDEDE), width: 1.w),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF23408F), width: 1.w),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: const Color(0xFFDEDEDE), width: 1.w),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      initialCountryCode: 'PK',
      onChanged: (phone) {
        print(phone.completeNumber);
      },
    );
  }
}
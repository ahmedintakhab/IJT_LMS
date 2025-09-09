import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;

  const CustomDropdown({
    Key? key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0XFFDEDEDE), width: 1.w),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(
              fontSize: 15.sp,
              fontFamily: 'Gilroy',
              color: const Color(0XFF9B9B9B),
              fontWeight: FontWeight.bold,
            ),
          ),
          value: value,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontFamily: 'Gilroy',
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
          buttonStyleData: ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            height: 56.h, // Adjust height to match your design
            width: double.infinity, // Full width
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: const Color(0xFFF5F5F5),
            ),
            elevation: 8,
          ),
          menuItemStyleData: MenuItemStyleData(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            height: 40.h,
          ),
          iconStyleData: IconStyleData(
            icon: const Icon(Icons.arrow_drop_down, color: Color(0XFF9B9B9B)),
            iconSize: 24.sp,
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class ProvinceDropdown extends StatelessWidget {
  final String hint;
  final List<Map<String, dynamic>> items;
  final void Function(String?) onChanged;
  final String? initialValue;
  final bool isCountrySelected;

  const ProvinceDropdown({
    Key? key,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.initialValue,
    required this.isCountrySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isCountrySelected ? const Color(0XFFDEDEDE) : Colors.grey[300]!,
          width: 1.w,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(
              fontSize: 15.sp,
              fontFamily: 'Gilroy',
              color: isCountrySelected ? const Color(0XFF9B9B9B) : Colors.grey[400],
              fontWeight: FontWeight.bold,
            ),
          ),
          value: initialValue,
          onChanged: isCountrySelected && items.isNotEmpty ? onChanged : null,
          items: items.map<DropdownMenuItem<String>>((Map<String, dynamic> province) {
            return DropdownMenuItem<String>(
              value: province['province_name'],
              child: Text(
                province['province_name'],
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
            height: 56.h,
            width: double.infinity,
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
          iconStyleData: const IconStyleData(
            icon: Icon(Icons.arrow_drop_down, color: Color(0XFF9B9B9B)),
            iconSize: 24,
          ),
        ),
      ),
    );
  }
}
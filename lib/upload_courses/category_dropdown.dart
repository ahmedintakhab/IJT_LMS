// widget/category_dropdown.dart
import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constant.dart'; // Adjust the import path as needed

class DropdownItem {
  final int id;
  final String name;

  DropdownItem({required this.id, required this.name});
}

class CategoryDropdown extends StatefulWidget {
  final String hint;
  final String? value;
  final void Function(String?, int?) onChanged;

  const CategoryDropdown({
    super.key,
    required this.hint,
    this.value,
    required this.onChanged,
  });

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  List<DropdownItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cached = prefs.getString('categories');
    if (cached != null) {
      final jsonResponse = jsonDecode(cached);
      if (jsonResponse['success'] == true) {
        List<dynamic> jsonList = jsonResponse['data'];
        setState(() {
          _items = jsonList.map((m) => DropdownItem(id: m['id'], name: m['name'])).toList();
        });
      }
    } else {
      try {
        final url = '${ApiConstant.baseUrl}instructor/get-categories';
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          print('Category api response code: ${response.statusCode}');
          print('Category api response data: $jsonResponse');
          if (jsonResponse['success'] == true) {
            List<dynamic> jsonList = jsonResponse['data'];
            setState(() {
              _items = jsonList.map((m) => DropdownItem(id: m['id'], name: m['name'])).toList();
            });
            await prefs.setString('categories', response.body);
          } else {
            debugPrint('API Error: ${jsonResponse['message']}');
          }
        } else {
          debugPrint('HTTP Error: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Error fetching categories: $e');
      }
    }
  }

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
            widget.hint,
            style: TextStyle(
              fontSize: 15.sp,
              fontFamily: 'Gilroy',
              color: const Color(0XFF9B9B9B),
              fontWeight: FontWeight.bold,
            ),
          ),
          value: widget.value,
          onChanged: (String? newValue) async {
            if (newValue != null) {
              final item = _items.firstWhere(
                    (i) => i.name == newValue,
                orElse: () => DropdownItem(id: -1, name: ''),
              );
              if (item.id != -1) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setInt('selectedCategoryId', item.id);
                widget.onChanged(newValue, item.id);
              }
            } else {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('selectedCategoryId');
              widget.onChanged(null, null);
            }
          },
          items: _items.map<DropdownMenuItem<String>>((DropdownItem item) {
            return DropdownMenuItem<String>(
              value: item.name,
              child: Text(
                item.name,
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
          iconStyleData: IconStyleData(
            icon: const Icon(Icons.arrow_drop_down, color: Color(0XFF9B9B9B)),
            iconSize: 24.sp,
          ),
        ),
      ),
    );
  }
}
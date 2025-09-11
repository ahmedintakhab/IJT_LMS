import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constant.dart';
import 'dropdown_items.dart';

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
          if (jsonResponse['success'] == true) {
            List<dynamic> jsonList = jsonResponse['data'];
            setState(() {
              _items = jsonList.map((m) => DropdownItem(id: m['id'], name: m['name'])).toList();
            });
            await prefs.setString('categories', response.body);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load categories: ${jsonResponse['message']}')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load categories: HTTP ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching categories')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFDEDEDE), width: 1.w),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            widget.hint,
            style: TextStyle(
              fontSize: 15.sp,
              fontFamily: 'Gilroy',
              color: const Color(0xFF9B9B9B),
              fontWeight: FontWeight.bold,
            ),
          ),
          value: widget.value,
          onChanged: _items.isNotEmpty
              ? (String? newValue) async {
            if (newValue != null) {
              final item = _items.firstWhere((i) => i.name == newValue);
              widget.onChanged(newValue, item.id);
            } else {
              widget.onChanged(null, null);
            }
          }
              : null,
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
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF9B9B9B)),
            iconSize: 24.sp,
          ),
        ),
      ),
    );
  }
}
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

class SubCategoryDropdown extends StatefulWidget {
  final String hint;
  final String? value;
  final int? categoryId;
  final void Function(String?) onChanged;

  const SubCategoryDropdown({
    super.key,
    required this.hint,
    this.value,
    this.categoryId,
    required this.onChanged,
  });

  @override
  State<SubCategoryDropdown> createState() => _SubCategoryDropdownState();
}

class _SubCategoryDropdownState extends State<SubCategoryDropdown> {
  List<DropdownItem> _items = [];
  int? _currentCategoryId;

  @override
  void initState() {
    super.initState();
    if (widget.categoryId != null) {
      _loadData(widget.categoryId!);
    }
  }

  @override
  void didUpdateWidget(covariant SubCategoryDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categoryId != oldWidget.categoryId) {
      setState(() {
        _items = [];
        _currentCategoryId = null;
        if (widget.value != null) {
          widget.onChanged(null); // Reset selected value
        }
      });
      if (widget.categoryId != null) {
        _loadData(widget.categoryId!);
      }
    }
  }

  Future<void> _loadData(int catId) async {
    if (_currentCategoryId == catId && _items.isNotEmpty) {
      debugPrint('Subcategory data already loaded for category ID: $catId');
      return;
    }
    _currentCategoryId = catId;
    debugPrint('Fetching subcategories for category ID: $catId');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'subcategories_$catId';
    String? cached = prefs.getString(key);
    if (cached != null) {
      debugPrint('Loading cached subcategories for category ID: $catId');
      try {
        final jsonResponse = jsonDecode(cached);
        if (jsonResponse['success'] == true) {
          List<dynamic> jsonList = jsonResponse['data'];
          setState(() {
            _items = jsonList.map((m) => DropdownItem(id: m['id'], name: m['name'])).toList();
          });
          debugPrint('Cached subcategories loaded: ${_items.map((e) => e.name).toList()}');
        } else {
          debugPrint('Cached API Error: ${jsonResponse['message']}');
        }
      } catch (e) {
        debugPrint('Error parsing cached subcategories: $e');
      }
    } else {
      try {
        final url = '${ApiConstant.baseUrl}instructor/get-category-subcategories/$catId';
        debugPrint('Making API call to: $url');
        final response = await http.get(Uri.parse(url));
        debugPrint('Subcategory API response code: ${response.statusCode}');
        debugPrint('Subcategory API response body: ${response.body}');
        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          if (jsonResponse['success'] == true) {
            List<dynamic> jsonList = jsonResponse['data'];
            setState(() {
              _items = jsonList.map((m) => DropdownItem(id: m['id'], name: m['name'])).toList();
            });
            debugPrint('Subcategories loaded: ${_items.map((e) => e.name).toList()}');
            await prefs.setString(key, response.body);
          } else {
            debugPrint('API Error: ${jsonResponse['message']}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load subcategories: ${jsonResponse['message']}')),
            );
          }
        } else {
          debugPrint('HTTP Error: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load subcategories: HTTP ${response.statusCode}')),
          );
        }
      } catch (e) {
        debugPrint('Error fetching subcategories: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching subcategories')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building SubCategoryDropdown with categoryId: ${widget.categoryId}, items: ${_items.length}');
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
          onChanged: _items.isNotEmpty ? widget.onChanged : null, // Disable dropdown if no items
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
import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constant.dart';
import 'dropdown_items.dart';

class SubCategoryDropdown extends StatefulWidget {
  final String hint;
  final String? value;
  final int? categoryId;
  final int? initialValueId;
  final void Function(String?, int?) onChanged;

  const SubCategoryDropdown({
    super.key,
    required this.hint,
    this.value,
    this.categoryId,
    this.initialValueId,
    required this.onChanged,
  });

  @override
  State<SubCategoryDropdown> createState() => _SubCategoryDropdownState();
}

class _SubCategoryDropdownState extends State<SubCategoryDropdown> {
  List<DropdownItem> _items = [];
  int? _currentCategoryId;
  String? _selectedValueName;

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
        _selectedValueName = null;
        if (widget.value != null) {
          widget.onChanged(null, null);
        }
      });
      if (widget.categoryId != null) {
        _loadData(widget.categoryId!);
      }
    }
  }

  Future<void> _loadData(int catId) async {
    if (_currentCategoryId == catId && _items.isNotEmpty) {
      return;
    }
    _currentCategoryId = catId;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'subcategories_$catId';
    String? cached = prefs.getString(key);
    if (cached != null) {
      try {
        final jsonResponse = jsonDecode(cached);
        if (jsonResponse['success'] == true) {
          List<dynamic> jsonList = jsonResponse['data'];
          setState(() {
            _items = jsonList.map((m) => DropdownItem(id: m['id'], name: m['name'])).toList();
            _setInitialValue();
          });
        }
      } catch (e) {}
    } else {
      try {
        final url = '${ApiConstant.baseUrl}instructor/get-category-subcategories/$catId';
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          if (jsonResponse['success'] == true) {
            List<dynamic> jsonList = jsonResponse['data'];
            setState(() {
              _items = jsonList.map((m) => DropdownItem(id: m['id'], name: m['name'])).toList();
              _setInitialValue();
            });
            await prefs.setString(key, response.body);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load subcategories: ${jsonResponse['message']}')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load subcategories: HTTP ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching subcategories')),
        );
      }
    }
  }

  void _setInitialValue() {
    if (widget.initialValueId != null) {
      final initialItem = _items.firstWhere(
            (item) => item.id == widget.initialValueId,
        orElse: () => null as DropdownItem,
      );
      if (initialItem != null) {
        _selectedValueName = initialItem.name;
        widget.onChanged(_selectedValueName, widget.initialValueId);
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
          value: _selectedValueName ?? widget.value,
          onChanged: _items.isNotEmpty
              ? (String? newValue) {
            if (newValue != null) {
              final item = _items.firstWhere((i) => i.name == newValue);
              setState(() {
                _selectedValueName = newValue;
              });
              widget.onChanged(newValue, item.id);
            } else {
              setState(() {
                _selectedValueName = null;
              });
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
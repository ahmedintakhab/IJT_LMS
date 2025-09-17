import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constant.dart';

class InstructorDropdown extends StatefulWidget {
  final String hint;
  final String? value;
  final void Function(String?, int?) onChanged;

  const InstructorDropdown({
    super.key,
    required this.hint,
    this.value,
    required this.onChanged,
  });

  @override
  State<InstructorDropdown> createState() => _InstructorDropdownState();
}

class _InstructorDropdownState extends State<InstructorDropdown> {
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = Uri.parse('${ApiConstant.baseUrl}instructor/get-others');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          List<dynamic> jsonList = jsonResponse['data'];
          setState(() {
            _items = jsonList
                .map<Map<String, dynamic>>(
                    (m) => {"id": m["id"], "name": m["name"]})
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching instructors: $e");
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
        child: DropdownButton2<int>(
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
          value: widget.value != null ? int.tryParse(widget.value!) : null,
          onChanged: (int? newId) {
            if (newId != null) {
              final item = _items.firstWhere((i) => i['id'] == newId);
              widget.onChanged(item['name'], item['id']);
            } else {
              widget.onChanged(null, null);
            }
          },
          items: _items.map<DropdownMenuItem<int>>((item) {
            return DropdownMenuItem<int>(
              value: item['id'],
              child: Text(
                item['name'],
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
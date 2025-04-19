import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constant.dart';

class DistrictDropdown extends StatefulWidget {
  final String hint;
  final void Function(String?) onChanged;
  final String? initialValue;
  final bool isProvinceSelected;

  const DistrictDropdown({
    Key? key,
    required this.hint,
    required this.onChanged,
    this.initialValue,
    required this.isProvinceSelected,
  }) : super(key: key);

  @override
  _DistrictDropdownState createState() => _DistrictDropdownState();
}

class _DistrictDropdownState extends State<DistrictDropdown> {
  String? selectedValue;
  List<Map<String, dynamic>> districts = [];
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
    if (widget.isProvinceSelected) {
      fetchDistricts();
    }
  }

  @override
  void didUpdateWidget(covariant DistrictDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isProvinceSelected != oldWidget.isProvinceSelected && widget.isProvinceSelected) {
      fetchDistricts();
    }
  }

  Future<String?> getProvinceId() async {
    final prefs = await SharedPreferences.getInstance();
    final provinceId = prefs.getString('province_id');
    print('getProvinceId: Retrieved province ID: $provinceId');
    return provinceId;
  }

  Future<void> saveDistrictId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('district_id', id);
    print('saveDistrictId: Saved district ID: $id');
  }

  Future<void> fetchDistricts() async {
    try {
      final provinceId = await getProvinceId();
      if (provinceId == null) {
        setState(() {
          districts = [];
          hasError = true;
        });
        return;
      }
      print('fetchDistricts: Using province ID: $provinceId');
      final response = await getDistricts(provinceId);
      setState(() {
        districts = response;
        hasError = false;
      });
    } catch (e) {
      print('fetchDistricts: Error fetching districts: $e');
      setState(() {
        districts = [];
        hasError = true;
      });
    }
  }

  Future<List<Map<String, dynamic>>> getDistricts(String provinceId) async {
    final url = '${ApiConstant.baseUrl}districts/$provinceId';
    try {
      final response = await http.get(Uri.parse(url));
      print('District API response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
          final List<dynamic> data = jsonResponse['data'];
          final districtList = data.map((item) => {
            'id': item['id'].toString(),
            'district_name': item['district_name'].toString(),
          }).toList();
          return districtList;
        } else {
          print('getDistricts: Invalid API response format');
          throw Exception('Invalid API response format');
        }
      } else {
        print('getDistricts: API call failed with status: ${response.statusCode}');
        throw Exception('Failed to load districts: ${response.statusCode}');
      }
    } catch (e) {
      print('getDistricts: Error in API call or parsing: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasError ? fetchDistricts : null,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: widget.isProvinceSelected ? const Color(0XFFDEDEDE) : Colors.grey[300]!,
            width: 1.w,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            hint: Text(
              widget.hint,
              style: TextStyle(
                fontSize: 15.sp,
                fontFamily: 'Gilroy',
                color: widget.isProvinceSelected ? const Color(0XFF9B9B9B) : Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
            ),
            value: selectedValue,
            onChanged: widget.isProvinceSelected && districts.isNotEmpty
                ? (value) {
              print('DistrictDropdown onChanged: Selected district: $value');
              setState(() {
                selectedValue = value;
                final selectedDistrict = districts.firstWhere(
                        (district) => district['district_name'] == value);
                saveDistrictId(selectedDistrict['id']);
              });
              widget.onChanged(value);
            }
                : null,
            items: districts.map<DropdownMenuItem<String>>((Map<String, dynamic> district) {
              return DropdownMenuItem<String>(
                value: district['district_name'],
                child: Text(
                  district['district_name'],
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
            onMenuStateChange: (isOpen) {
              print('DistrictDropdown onMenuStateChange: isOpen = $isOpen');
              if (isOpen && widget.isProvinceSelected) {
                fetchDistricts();
              }
            },
          ),
        ),
      ),
    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constant.dart';

class ProvinceDropdown extends StatefulWidget {
  final String hint;
  final void Function(String?) onChanged;
  final String? initialValue;
  final bool isCountrySelected;

  const ProvinceDropdown({
    Key? key,
    required this.hint,
    required this.onChanged,
    this.initialValue,
    required this.isCountrySelected,
  }) : super(key: key);

  @override
  _ProvinceDropdownState createState() => _ProvinceDropdownState();
}

class _ProvinceDropdownState extends State<ProvinceDropdown> {
  String? selectedValue;
  List<Map<String, dynamic>> provinces = [];
  bool hasError = false; // Track error state for retry logic

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
    print('ProvinceDropdown initState: Initializing with value $selectedValue');
    if (widget.isCountrySelected) {
      fetchProvinces();
    }
  }

  @override
  void didUpdateWidget(covariant ProvinceDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCountrySelected != oldWidget.isCountrySelected && widget.isCountrySelected) {
      fetchProvinces();
    }
  }

  Future<String?> getCountryId() async {
    final prefs = await SharedPreferences.getInstance();
    final countryId = prefs.getString('country_id');
    print('getCountryId: Retrieved country ID: $countryId');
    return countryId;
  }

  Future<void> saveProvinceId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('province_id', id);
    print('saveProvinceId: Saved province ID: $id');
  }

  Future<void> fetchProvinces() async {
    print('fetchProvinces: Starting to fetch provinces');
    try {
      final countryId = await getCountryId();
      if (countryId == null) {
        print('fetchProvinces: No country ID found in SharedPreferences');
        setState(() {
          provinces = [];
          hasError = true;
        });
        return;
      }
      print('fetchProvinces: Using country ID: $countryId');
      final response = await getProvinces(countryId);
      print('fetchProvinces: Successfully fetched provinces: $response');
      setState(() {
        provinces = response;
        hasError = false;
      });
    } catch (e) {
      print('fetchProvinces: Error fetching provinces: $e');
      setState(() {
        provinces = [];
        hasError = true;
      });
    }
  }

  Future<List<Map<String, dynamic>>> getProvinces(String countryId) async {
    final url = '${ApiConstant.baseUrl}provinces/$countryId';
    print('getProvinces: Calling API with URL: $url');
    try {
      final response = await http.get(Uri.parse(url));
      print('getProvinces: API response status code: ${response.statusCode}');
      print('getProvinces: Raw API response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print('getProvinces: Parsed JSON response: $jsonResponse');
        if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
          final List<dynamic> data = jsonResponse['data'];
          final provinceList = data.map((item) => {
            'id': item['id'].toString(),
            'province_name': item['province_name'].toString(),
          }).toList();
          print('getProvinces: Extracted province list: $provinceList');
          return provinceList;
        } else {
          print('getProvinces: Invalid API response format');
          throw Exception('Invalid API response format');
        }
      } else {
        print('getProvinces: API call failed with status: ${response.statusCode}');
        throw Exception('Failed to load provinces: ${response.statusCode}');
      }
    } catch (e) {
      print('getProvinces: Error in API call or parsing: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('ProvinceDropdown build: Rendering with ${provinces.length} provinces');
    return GestureDetector(
      onTap: hasError ? fetchProvinces : null,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: widget.isCountrySelected ? const Color(0XFFDEDEDE) : Colors.grey[300]!,
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
                color: widget.isCountrySelected ? const Color(0XFF9B9B9B) : Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
            ),
            value: selectedValue,
            onChanged: widget.isCountrySelected && provinces.isNotEmpty
                ? (value) {
              print('ProvinceDropdown onChanged: Selected province: $value');
              setState(() {
                selectedValue = value;
                final selectedProvince = provinces.firstWhere(
                        (province) => province['province_name'] == value);
                saveProvinceId(selectedProvince['id']);
              });
              widget.onChanged(value);
            }
                : null,
            items: provinces.map<DropdownMenuItem<String>>((Map<String, dynamic> province) {
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
            onMenuStateChange: (isOpen) {
              print('ProvinceDropdown onMenuStateChange: isOpen = $isOpen');
              if (isOpen && widget.isCountrySelected) {
                fetchProvinces();
              }
            },
          ),
        ),
      ),
    );
  }
}
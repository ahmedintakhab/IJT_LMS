import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constant.dart';

class CityDropdown extends StatefulWidget {
  final String hint;
  final void Function(String?) onChanged;
  final String? initialValue;
  final bool isDistrictSelected;

  const CityDropdown({
    Key? key,
    required this.hint,
    required this.onChanged,
    this.initialValue,
    required this.isDistrictSelected,
  }) : super(key: key);

  @override
  _CityDropdownState createState() => _CityDropdownState();
}

class _CityDropdownState extends State<CityDropdown> {
  String? selectedValue;
  List<Map<String, dynamic>> cities = [];
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
    if (widget.isDistrictSelected) {
      fetchCities();
    }
  }

  @override
  void didUpdateWidget(covariant CityDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDistrictSelected != oldWidget.isDistrictSelected && widget.isDistrictSelected) {
      fetchCities();
    }
  }

  Future<String?> getDistrictId() async {
    final prefs = await SharedPreferences.getInstance();
    final districtId = prefs.getString('district_id');
    print('getDistrictId: Retrieved district ID: $districtId');
    return districtId;
  }

  Future<void> saveCityId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('city_id', id);
    print('saveCityId: Saved city ID: $id');
  }

  Future<void> fetchCities() async {
    try {
      final districtId = await getDistrictId();
      if (districtId == null) {
        setState(() {
          cities = [];
          hasError = true;
        });
        return;
      }
      final response = await getCities(districtId);
      print('fetchCities: Successfully fetched cities: $response');
      setState(() {
        cities = response;
        hasError = false;
      });
    } catch (e) {
      print('fetchCities: Error fetching cities: $e');
      setState(() {
        cities = [];
        hasError = true;
      });
    }
  }

  Future<List<Map<String, dynamic>>> getCities(String districtId) async {
    final url = '${ApiConstant.baseUrl}cities/$districtId';
    try {
      final response = await http.get(Uri.parse(url));
      print('getCities: API response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
          final List<dynamic> data = jsonResponse['data'];
          final cityList = data.map((item) => {
            'id': item['id'].toString(),
            'name': item['name'].toString(),
          }).toList();
          return cityList;
        } else {
          print('getCities: Invalid API response format');
          throw Exception('Invalid API response format');
        }
      } else {
        print('getCities: API call failed with status: ${response.statusCode}');
        throw Exception('Failed to load cities: ${response.statusCode}');
      }
    } catch (e) {
      print('getCities: Error in API call or parsing: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasError ? fetchCities : null,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: widget.isDistrictSelected ? const Color(0XFFDEDEDE) : Colors.grey[300]!,
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
                color: widget.isDistrictSelected ? const Color(0XFF9B9B9B) : Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
            ),
            value: selectedValue,
            onChanged: widget.isDistrictSelected && cities.isNotEmpty
                ? (value) {
              print('CityDropdown onChanged: Selected city: $value');
              setState(() {
                selectedValue = value;
                final selectedCity = cities.firstWhere(
                        (city) => city['name'] == value);
                saveCityId(selectedCity['id']);
              });
              widget.onChanged(value);
            }
                : null,
            items: cities.map<DropdownMenuItem<String>>((Map<String, dynamic> city) {
              return DropdownMenuItem<String>(
                value: city['name'],
                child: Text(
                  city['name'],
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
              print('CityDropdown onMenuStateChange: isOpen = $isOpen');
              if (isOpen && widget.isDistrictSelected) {
                fetchCities();
              }
            },
          ),
        ),
      ),
    );
  }
}
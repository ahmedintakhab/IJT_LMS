import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constant.dart';

class MuqamDropdown extends StatefulWidget {
  final String hint;
  final void Function(String?) onChanged;
  final String? initialValue;
  final bool isCitySelected;

  const MuqamDropdown({
    Key? key,
    required this.hint,
    required this.onChanged,
    this.initialValue,
    required this.isCitySelected,
  }) : super(key: key);

  @override
  _MuqamDropdownState createState() => _MuqamDropdownState();
}

class _MuqamDropdownState extends State<MuqamDropdown> {
  String? selectedValue;
  List<Map<String, dynamic>> muqams = [];
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
    print('MuqamDropdown initState: Initializing with value $selectedValue');
    if (widget.isCitySelected) {
      fetchMuqams();
    }
  }

  @override
  void didUpdateWidget(covariant MuqamDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCitySelected != oldWidget.isCitySelected && widget.isCitySelected) {
      fetchMuqams();
    }
  }

  Future<String?> getCityId() async {
    final prefs = await SharedPreferences.getInstance();
    final cityId = prefs.getString('city_id');
    print('getCityId: Retrieved city ID: $cityId');
    return cityId;
  }

  Future<void> saveMuqamId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('muqam_id', id);
    print('saveMuqamId: Saved muqam ID: $id');
  }

  Future<void> fetchMuqams() async {
    print('fetchMuqams: Starting to fetch muqams');
    try {
      final cityId = await getCityId();
      if (cityId == null) {
        print('fetchMuqams: No city ID found in SharedPreferences');
        setState(() {
          muqams = [];
          hasError = true;
        });
        return;
      }
      print('fetchMuqams: Using city ID: $cityId');
      final response = await getMuqams(cityId);
      print('fetchMuqams: Successfully fetched muqams: $response');
      setState(() {
        muqams = response;
        hasError = false;
      });
    } catch (e) {
      print('fetchMuqams: Error fetching muqams: $e');
      setState(() {
        muqams = [];
        hasError = true;
      });
    }
  }

  Future<List<Map<String, dynamic>>> getMuqams(String cityId) async {
    final url = '${ApiConstant.baseUrl}muqams/$cityId';
    print('getMuqams: Calling API with URL: $url');
    try {
      final response = await http.get(Uri.parse(url));
      print('getMuqams: API response status code: ${response.statusCode}');
      print('getMuqams: Raw API response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print('getMuqams: Parsed JSON response: $jsonResponse');
        if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
          final List<dynamic> data = jsonResponse['data'];
          final muqamList = data.map((item) => {
            'id': item['id'].toString(),
            'muqam_name': item['muqam_name'].toString(),
          }).toList();
          print('getMuqams: Extracted muqam list: $muqamList');
          return muqamList;
        } else {
          print('getMuqams: Invalid API response format');
          throw Exception('Invalid API response format');
        }
      } else {
        print('getMuqams: API call failed with status: ${response.statusCode}');
        throw Exception('Failed to load muqams: ${response.statusCode}');
      }
    } catch (e) {
      print('getMuqams: Error in API call or parsing: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('MuqamDropdown build: Rendering with ${muqams.length} muqams');
    return GestureDetector(
      onTap: hasError ? fetchMuqams : null,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: widget.isCitySelected ? const Color(0XFFDEDEDE) : Colors.grey[300]!,
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
                color: widget.isCitySelected ? const Color(0XFF9B9B9B) : Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
            ),
            value: selectedValue,
            onChanged: widget.isCitySelected && muqams.isNotEmpty
                ? (value) {
              print('MuqamDropdown onChanged: Selected muqam: $value');
              setState(() {
                selectedValue = value;
                final selectedMuqam = muqams.firstWhere(
                        (muqam) => muqam['muqam_name'] == value);
                saveMuqamId(selectedMuqam['id']);
              });
              widget.onChanged(value);
            }
                : null,
            items: muqams.map<DropdownMenuItem<String>>((Map<String, dynamic> muqam) {
              return DropdownMenuItem<String>(
                value: muqam['muqam_name'],
                child: Text(
                  muqam['muqam_name'],
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
              print('MuqamDropdown onMenuStateChange: isOpen = $isOpen');
              if (isOpen && widget.isCitySelected) {
                fetchMuqams();
              }
            },
          ),
        ),
      ),
    );
  }
}
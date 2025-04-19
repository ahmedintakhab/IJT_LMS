import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constant.dart';

class CountryDropdown extends StatefulWidget {
  final String hint;
  final void Function(String?) onChanged;
  final String? initialValue;

  const CountryDropdown({
    Key? key,
    required this.hint,
    required this.onChanged,
    this.initialValue,
  }) : super(key: key);

  @override
  _CountryDropdownState createState() => _CountryDropdownState();
}

class _CountryDropdownState extends State<CountryDropdown> {
  String? selectedValue;
  List<Map<String, dynamic>> countries = [];

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
    fetchCountries();
  }

  Future<void> fetchCountries() async {
    try {
      final response = await getCountries();
      setState(() {
        countries = response;
      });
    } catch (e) {
      print('Error fetching countries: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCountries() async {
    final url = '${ApiConstant.baseUrl}countries';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Country dropdown api response: ${response.statusCode}');
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((item) => {
        'id': item['id'].toString(),
        'country_name': item['country_name']
      }).toList();
    } else {
      throw Exception('Failed to load countries: ${response.statusCode}');
    }
  }

  Future<void> saveCountryId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('country_id', id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12.r),
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
          value: selectedValue,
          onChanged: countries.isNotEmpty
              ? (value) {
            setState(() {
              selectedValue = value;
            });
            // Find the country ID for the selected country
            final selectedCountry = countries.firstWhere(
                    (country) => country['country_name'] == value);
            saveCountryId(selectedCountry['id']);
            widget.onChanged(value);
          }
              : null,
          items: countries.map<DropdownMenuItem<String>>((Map<String, dynamic> country) {
            return DropdownMenuItem<String>(
              value: country['country_name'],
              child: Text(
                country['country_name'],
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
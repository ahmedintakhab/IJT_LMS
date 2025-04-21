import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/login/login_empty_state.dart';
import 'package:learn_megnagmet/login/sign_up/term_condition_widget.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:learn_megnagmet/widget/custom_text_form_field.dart';
import 'package:learn_megnagmet/widget/phone_number_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../dropdowns/city_dropdown.dart';
import '../../dropdowns/country_dropdown.dart';
import '../../dropdowns/district_dropdown.dart';
import '../../dropdowns/muqam_dropdown.dart';
import '../../dropdowns/province_dropdown.dart';
import '../../utils/api_constant.dart';
import '../../utils/screen_size.dart';
import 'Signup_screen2.dart';
import 'affiliation_field.dart';

class SignUpEmptyScreen extends StatefulWidget {
  const SignUpEmptyScreen({Key? key}) : super(key: key);

  @override
  State<SignUpEmptyScreen> createState() => _SignUpEmptyScreenState();
}

class _SignUpEmptyScreenState extends State<SignUpEmptyScreen> {
  String? selectedCountry;
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedCity;
  String? selectedMuqam;

  bool ischeaked = false;
  bool ispassHiden = true;
  bool ispassHiden1 = true;
  bool isLoading = false;
  bool isDataLoading = true;
  bool isCountrySelected = false;
  bool isProvinceSelected = false;
  bool isDistrictSelected = false;
  bool isCitySelected = false;
  String provinceHint = 'Province';
  String districtHint = 'District';
  String cityHint = 'City';
  String muqamHint = 'Muqam';

  String phoneNumber = '';
  final formkey = GlobalKey<FormState>();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  // TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();
  TextEditingController membershipController = TextEditingController();
  final locationControllers = {
    'country': TextEditingController(),
    'province': TextEditingController(),
    'district': TextEditingController(),
    'city': TextEditingController(),
    'muqam': TextEditingController(),
  };

  List<Map<String, dynamic>> countries = [];
  List<Map<String, dynamic>> provinces = [];
  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> cities = [];
  List<Map<String, dynamic>> muqams = [];

  late LocationDataService locationDataService;

  @override
  void initState() {
    super.initState();
    locationDataService = LocationDataService();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    setState(() => isDataLoading = true);
    final prefs = await SharedPreferences.getInstance();

    // Pre-load all data (countries and provinces for all countries)
    await locationDataService.preloadAllData(prefs);

    // Load countries into the state
    countries = await locationDataService.fetchCountries(prefs);

    // Do not load selected values from SharedPreferences to set as initialValue
    // Instead, keep the dropdowns empty (showing hints) by leaving selectedX as null
    selectedCountry = null;
    selectedProvince = null;
    selectedDistrict = null;
    selectedCity = null;
    selectedMuqam = null;
    isCountrySelected = false;
    isProvinceSelected = false;
    isDistrictSelected = false;
    isCitySelected = false;
    provinceHint = 'Province';
    districtHint = 'District';
    cityHint = 'City';
    muqamHint = 'Muqam';

    // Check if there’s a previously selected country and load provinces
    if (prefs.containsKey('selected_country')) {
      final countryId = prefs.getString('country_id');
      if (countryId != null) {
        provinces = await locationDataService.fetchProvinces(countryId, prefs);
      }
    }

    // Load districts, cities, and muqams if previously selected
    if (prefs.containsKey('selected_province')) {
      final provinceId = prefs.getString('province_id');
      if (provinceId != null) {
        districts = await locationDataService.fetchDistricts(provinceId, prefs);
      }
    }

    if (prefs.containsKey('selected_district')) {
      final districtId = prefs.getString('district_id');
      if (districtId != null) {
        cities = await locationDataService.fetchCities(districtId, prefs);
      }
    }

    if (prefs.containsKey('selected_city')) {
      final cityId = prefs.getString('city_id');
      if (cityId != null) {
        muqams = await locationDataService.fetchMuqams(cityId, prefs);
      }
    }

    setState(() => isDataLoading = false);
  }

  Future<Map<String, String?>> getAllIdsFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'country_id': prefs.getString('country_id'),
      'province_id': prefs.getString('province_id'),
      'district_id': prefs.getString('district_id'),
      'city_id': prefs.getString('city_id'),
      'muqam_id': prefs.getString('muqam_id'),
      'student_type': prefs.getInt('has_affiliation')?.toString(),
    };
  }

  Future<void> registerUser() async {
    if (!formkey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    // if (!ischeaked) {
    //   Get.snackbar(
    //     'Error',
    //     'Please accept terms and conditions',
    //     snackPosition: SnackPosition.BOTTOM,
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //   );
    //   print('Terms and conditions not accepted');
    //   return;
    // }

    if (passwordController.text != confirmpasswordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Passwords do not match');
      return;
    }

    final ids = await getAllIdsFromSharedPreferences();

    if (ids['country_id'] == null ||
        ids['province_id'] == null ||
        ids['district_id'] == null ||
        ids['city_id'] == null ||
        ids['muqam_id'] == null ||
        ids['student_type'] == null) {
      Get.snackbar(
        'Error',
        'Please complete all selections (Country, Province, District, City, Muqam, and Affiliation)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Missing selections: $ids');
      return;
    }

    setState(() => isLoading = true);

    String mobileNumber = phoneNumber.trim();

    if (mobileNumber.isEmpty) {
      Get.snackbar(
        'Error',
        'Phone number cannot be empty',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Phone number is empty');
      setState(() => isLoading = false);
      return;
    }

    final url = '${ApiConstant.baseUrl}register';
    final data = {
      'first_name': firstnameController.text.trim(),
      'last_name': lastnameController.text.trim(),
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
      'password_confirmation': confirmpasswordController.text.trim(),
      'mobile_number': phoneNumber,
      'country_id': ids['country_id'],
      'province_id': ids['province_id'],
      'district_id': ids['district_id'],
      'city_id': ids['city_id'],
      'muqam_id': ids['muqam_id'],
      'student_type': ids['student_type'],
    };

    print('Fields being sent to API:');
    data.forEach((key, value) => print('$key: $value'));

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      final responseData = json.decode(response.body);
      print('API response status code: ${response.statusCode}');
      print('API response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Register API status response: ${response.statusCode}');
        Get.snackbar(
          'Successful',
          'User registered successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.off(() => const EmptyState());
      } else {
        String errorMessage = 'Registration failed';
        if (responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        } else if (responseData.containsKey('errors')) {
          errorMessage = responseData['errors'].values.first[0];
        }
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print('Register API error: $errorMessage');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Register error: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeScreenSize(context);
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60.h),
              backButton(),
              SizedBox(height: 20.h),
              Center(
                child: Text(
                  "Create an account",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.sp,
                    fontFamily: 'Gilroy',
                    color: const Color(0XFF000000),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: isDataLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                  children: [
                    detailForm(),
                    SizedBox(height: 25.h),
                    TermConditionCheckbox(),
                    SizedBox(height: 25.h),
                    CustomButton(
                      onTap: registerUser,
                      buttonText: 'Sign Up',
                      isLoading: isLoading,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 30.h),
                child: alreadyLoginButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void toggle() {
    setState(() {
      ispassHiden = !ispassHiden;
    });
  }

  void toggle1() {
    setState(() {
      ispassHiden1 = !ispassHiden1;
    });
  }

  Widget detailForm() {
    return Form(
      key: formkey,
      child: Column(
        children: [
          CustomTextFormField(
            controller: emailController,
            hintText: 'Email',
            validator: (val) {
              if (val == null || val.isEmpty) return 'Enter the email';
              if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(val)) {
                return "Please enter valid email address";
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),
          phone_number_field(
            onPhoneNumberChanged: (String phone) {
              setState(() {
                phoneNumber = phone; // Store the phone number
              });
            },
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter phone number';
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),
          CustomTextFormField(
            controller: firstnameController,
            hintText: 'First Name',
            validator: (val) {
              if (val == null || val.isEmpty) return 'Enter the first name';
              return null;
            },
          ),
          SizedBox(height: 20.h),
          CustomTextFormField(
            controller: lastnameController,
            hintText: 'Last Name',
            validator: (val) {
              if (val == null || val.isEmpty) return 'Enter the last name';
              return null;
            },
          ),
          SizedBox(height: 20.h),
          CustomTextFormField(
            controller: passwordController,
            hintText: 'Password',
            obscureText: ispassHiden,
            suffixIcon: ispassHiden
                ? GestureDetector(
              onTap: toggle,
              child: Image(
                image: const AssetImage("assets/notvisible_eye.png"),
                height: 20.h,
                width: 20.w,
              ),
            )
                : GestureDetector(
              onTap: toggle,
              child: Image(
                image: const AssetImage("assets/visible_eye.png"),
                height: 20.h,
                width: 20.w,
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Enter the password';
              if (val.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          SizedBox(height: 20.h),
          CustomTextFormField(
            controller: confirmpasswordController,
            hintText: 'Confirm password',
            obscureText: ispassHiden1,
            suffixIcon: ispassHiden1
                ? GestureDetector(
              onTap: toggle1,
              child: Image(
                image: const AssetImage("assets/notvisible_eye.png"),
                height: 20.h,
                width: 20.w,
              ),
            )
                : GestureDetector(
              onTap: toggle1,
              child: Image(
                image: const AssetImage("assets/visible_eye.png"),
                height: 20.h,
                width: 20.w,
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Enter the confirm password';
              if (val != passwordController.text) return 'Passwords do not match';
              return null;
            },
          ),
          SizedBox(height: 20.h),
          AffiliationField(controller: membershipController),
          SizedBox(height: 20.h),
          CountryDropdown(
            hint: 'Country',
            items: countries,
            onChanged: (value) async {
              final prefs = await SharedPreferences.getInstance();
              List<Map<String, dynamic>> newProvinces = [];
              if (value != null) {
                final selectedItem = countries.firstWhere((item) => item['country_name'] == value);
                await prefs.setString('country_id', selectedItem['id']);
                await prefs.setString('selected_country', value);
                newProvinces = await locationDataService.fetchProvinces(selectedItem['id'], prefs);
              } else {
                await prefs.remove('country_id');
                await prefs.remove('selected_country');
              }

              // Update state after fetching data
              setState(() {
                selectedCountry = value;
                isCountrySelected = value != null;
                provinceHint = isCountrySelected ? '--Select Province--' : 'Province';
                provinces = newProvinces;
                selectedProvince = null;
                selectedDistrict = null;
                selectedCity = null;
                selectedMuqam = null;
                isProvinceSelected = false;
                isDistrictSelected = false;
                isCitySelected = false;
                districts = [];
                cities = [];
                muqams = [];
              });

              // Clear dependent SharedPreferences keys
              await prefs.remove('province_id');
              await prefs.remove('selected_province');
              await prefs.remove('district_id');
              await prefs.remove('selected_district');
              await prefs.remove('city_id');
              await prefs.remove('selected_city');
              await prefs.remove('muqam_id');
              await prefs.remove('selected_muqam');
            },
            initialValue: selectedCountry,
          ),
          SizedBox(height: 20.h),
          ProvinceDropdown(
            hint: provinceHint,
            items: provinces,
            onChanged: (value) async {
              final prefs = await SharedPreferences.getInstance();
              List<Map<String, dynamic>> newDistricts = [];
              if (value != null) {
                final selectedItem = provinces.firstWhere((item) => item['province_name'] == value);
                await prefs.setString('province_id', selectedItem['id']);
                await prefs.setString('selected_province', value);
                newDistricts = await locationDataService.fetchDistricts(selectedItem['id'], prefs);
              } else {
                await prefs.remove('province_id');
                await prefs.remove('selected_province');
              }

              setState(() {
                selectedProvince = value;
                isProvinceSelected = value != null;
                districtHint = isProvinceSelected ? '--Select District--' : 'District';
                districts = newDistricts;
                selectedDistrict = null;
                selectedCity = null;
                selectedMuqam = null;
                isDistrictSelected = false;
                isCitySelected = false;
                cities = [];
                muqams = [];
              });

              await prefs.remove('district_id');
              await prefs.remove('selected_district');
              await prefs.remove('city_id');
              await prefs.remove('selected_city');
              await prefs.remove('muqam_id');
              await prefs.remove('selected_muqam');
            },
            initialValue: selectedProvince,
            isCountrySelected: isCountrySelected,
          ),
          SizedBox(height: 20.h),
          DistrictDropdown(
            hint: districtHint,
            items: districts,
            onChanged: (value) async {
              final prefs = await SharedPreferences.getInstance();
              List<Map<String, dynamic>> newCities = [];
              if (value != null) {
                final selectedItem = districts.firstWhere((item) => item['district_name'] == value);
                await prefs.setString('district_id', selectedItem['id']);
                await prefs.setString('selected_district', value);
                newCities = await locationDataService.fetchCities(selectedItem['id'], prefs);
              } else {
                await prefs.remove('district_id');
                await prefs.remove('selected_district');
              }

              setState(() {
                selectedDistrict = value;
                isDistrictSelected = value != null;
                cityHint = isDistrictSelected ? '--Select City--' : 'City';
                cities = newCities;
                selectedCity = null;
                selectedMuqam = null;
                isCitySelected = false;
                muqams = [];
              });

              await prefs.remove('city_id');
              await prefs.remove('selected_city');
              await prefs.remove('muqam_id');
              await prefs.remove('selected_muqam');
            },
            initialValue: selectedDistrict,
            isProvinceSelected: isProvinceSelected,
          ),
          SizedBox(height: 20.h),
          CityDropdown(
            hint: cityHint,
            items: cities,
            onChanged: (value) async {
              final prefs = await SharedPreferences.getInstance();
              List<Map<String, dynamic>> newMuqams = [];
              if (value != null && cities.isNotEmpty) {
                final selectedItem = cities.firstWhere(
                      (item) => item['name'] == value,
                  orElse: () => {'id': '', 'name': ''},
                );
                if (selectedItem['id'] != '') {
                  await prefs.setString('city_id', selectedItem['id']);
                  await prefs.setString('selected_city', value);
                  newMuqams = await locationDataService.fetchMuqams(selectedItem['id'], prefs);
                }
              } else {
                await prefs.remove('city_id');
                await prefs.remove('selected_city');
              }

              setState(() {
                selectedCity = value;
                isCitySelected = value != null;
                muqamHint = isCitySelected ? '--Select Muqam--' : 'Muqam';
                muqams = newMuqams;
                selectedMuqam = null;
              });

              await prefs.remove('muqam_id');
              await prefs.remove('selected_muqam');
            },
            initialValue: selectedCity,
            isDistrictSelected: isDistrictSelected,
          ),
          SizedBox(height: 20.h),
          MuqamDropdown(
            hint: muqamHint,
            items: muqams,
            onChanged: (value) async {
              final prefs = await SharedPreferences.getInstance();
              if (value != null) {
                final selectedItem = muqams.firstWhere((item) => item['muqam_name'] == value);
                await prefs.setString('muqam_id', selectedItem['id']);
                await prefs.setString('selected_muqam', value);
              } else {
                await prefs.remove('muqam_id');
                await prefs.remove('selected_muqam');
              }

              setState(() {
                selectedMuqam = value;
              });
            },
            initialValue: selectedMuqam,
            isCitySelected: isCitySelected,
          ),
        ],
      ),
    );
  }

  Widget alreadyLoginButton() {
    return Align(
      alignment: Alignment.center,
      child: RichText(
        text: TextSpan(
          text: 'Already have an account? ',
          style: TextStyle(color: Colors.black, fontSize: 15.sp, fontFamily: 'Gilroy'),
          children: [
            TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Get.off(const EmptyState());
                },
              text: 'Login',
              style: TextStyle(
                color: const Color(0XFF000000),
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Gilroy',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget backButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context, true);
      },
      child: Image(
        image: const AssetImage("assets/back_arrow.png"),
        height: 24.h,
        width: 24.w,
      ),
    );
  }

  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    // phoneNumberController.dispose();
    passwordController.dispose();
    confirmpasswordController.dispose();
    locationControllers.values.forEach((controller) => controller.dispose());
    membershipController.dispose();
    super.dispose();
  }
}
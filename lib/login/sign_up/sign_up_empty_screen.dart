import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/login/login_empty_state.dart';
import 'package:learn_megnagmet/login/sign_up/term_condition_widget.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:learn_megnagmet/widget/custom_text_form_field.dart';
import 'package:learn_megnagmet/widget/phone_number_field.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../dropdowns/country_dropdown.dart';
import '../../dropdowns/district_dropdown.dart';
import '../../dropdowns/province_dropdown.dart';
import '../../utils/api_constant.dart';
import '../../utils/screen_size.dart';
import '../../widget/custom_dropdown.dart';
import 'affiliation_field.dart';

class SignInEmptyScreen extends StatefulWidget {
  const SignInEmptyScreen({Key? key}) : super(key: key);

  @override
  State<SignInEmptyScreen> createState() => _SignInEmptyScreenState();
}

class _SignInEmptyScreenState extends State<SignInEmptyScreen> {
  List<String> cities = ['Wah Cantt', 'Islamabad', 'Rawalpindi'];
  List<String> muqams = ['Central', 'North', 'South'];

  String? selectedCountry;
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedCity;
  String? selectedMuqam;

  bool ischeaked = false;
  bool ispassHiden = true;
  bool ispassHiden1 = true;
  bool isLoading = false;
  bool isCountrySelected = false;
  bool isProvinceSelected = false;
  String provinceHint = 'Province';
  String districtHint = 'District';

  String passworderror = '';
  final formkey = GlobalKey<FormState>();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();
  TextEditingController membershipController = TextEditingController();
  TextEditingController provinceController = TextEditingController();
  final locationControllers = {
    'country': TextEditingController(),
    'province': TextEditingController(),
    'district': TextEditingController(),
    'city': TextEditingController(),
    'muqam': TextEditingController(),
  };
  @override
  void initState() {
    super.initState();
    checkCountrySelection();
  }
  Future<void> checkCountrySelection() async {
    final prefs = await SharedPreferences.getInstance();
    final countryId = prefs.getString('country_id');
    setState(() {
      // Only set isCountrySelected to true if a country is actually selected
      isCountrySelected = countryId != null && selectedCountry != null;
      provinceHint = isCountrySelected ? '--Select Province--' : 'Province';
    });
  }

  Future<void> checkProvinceSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final provinceId = prefs.getString('province_id');
    setState(() {
      isProvinceSelected = provinceId != null && selectedProvince != null;
      districtHint = isProvinceSelected ? '--Select District--' : 'District';
    });
  }

  Future<void> registerUser() async {
    if (!formkey.currentState!.validate()) return;
    if (!ischeaked) {
      Get.snackbar(
        'Error',
        'Please accept terms and conditions',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (passwordController.text != confirmpasswordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (selectedCountry == null ||
        selectedProvince == null ||
        selectedDistrict == null ||
        selectedCity == null ||
        selectedMuqam == null) {
      Get.snackbar('Error', 'Please select all location fields',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    setState(() => isLoading = true);

    final url = '${ApiConstant.baseUrl}register';
    final data = {
      'email': emailController.text.trim(),
      'first_name': firstnameController.text.trim(),
      'last_name': lastnameController.text.trim(),
      'phone_number': phoneNumberController.text.trim(),
      'password': passwordController.text.trim(),
      'confirm_password': confirmpasswordController.text.trim(),
      'membership': membershipController.text.trim(),
      'country': locationControllers['country']!.text.trim(),
      'province': locationControllers['province']!.text.trim(),
      'district': locationControllers['district']!.text.trim(),
      'city': locationControllers['city']!.text.trim(),
      'muqam': locationControllers['muqam']!.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Login api status response: ${response.statusCode}');
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
        print('Login error: $errorMessage');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Login error: ${e.toString()}');

    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeScreenSize(context);
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60.h),
              back_button(),
              SizedBox(height: 20.h),
              Center(
                child: Text(
                  "Create an account",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.sp,
                      fontFamily: 'Gilroy',
                      color: const Color(0XFF000000)),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    detailform(),
                    SizedBox(height: 25.h),
                    // term_condition_cheakbox(),
                    TermConditionCheckbox(),
                    SizedBox(height: 25.h),
                    CustomButton(
                      onTap: registerUser,
                      buttonText: 'Sign Up',
                      isLoading: isLoading,
                    )
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.only(bottom: 30.h),
                child: already_login_button(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  toggle() {
    setState(() {
      ispassHiden = !ispassHiden;
    });
  }

  toggle1() {
    setState(() {
      ispassHiden1 = !ispassHiden1;
    });
  }

  Widget detailform() {
    return Form(
      key: formkey,
      child: Column(
        children: [
          CustomTextFormField(
            controller: emailController,
            hintText: 'Email',
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Enter the email';
              } else if (!RegExp(
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(val)) {
                return "Please enter valid email address";
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),
          PhoneNumberField(
            controller: phoneNumberController,
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
          AffiliationField(
            controller: membershipController,
          ),
          SizedBox(height: 20.h),
          CountryDropdown(
            hint: 'Country',
            onChanged: (value) async {
              setState(() {
                selectedCountry = value;
                isCountrySelected = value != null;
                provinceHint = isCountrySelected ? '--Select Province--' : 'Province';
                selectedProvince = null;
                selectedDistrict = null;
                isProvinceSelected = false;
                districtHint = 'District';
              });
              final prefs = await SharedPreferences.getInstance();
              if (value == null) {
                await prefs.remove('country_id');
              }
              await prefs.remove('province_id');
              await prefs.remove('district_id');
            },
            initialValue: selectedCountry,
          ),
          SizedBox(height: 20.h),
          ProvinceDropdown(
            hint: provinceHint,
            onChanged: (value) async {
              setState(() {
                selectedProvince = value;
                isProvinceSelected = value != null;
                districtHint = isProvinceSelected ? '--Select District--' : 'District';
                selectedDistrict = null;
              });
              final prefs = await SharedPreferences.getInstance();
              if (value == null) {
                await prefs.remove('province_id');
              }
              await prefs.remove('district_id');
              checkProvinceSelection();
            },
            initialValue: selectedProvince,
            isCountrySelected: isCountrySelected,
          ),          SizedBox(height: 20.h),
          DistrictDropdown(
            hint: districtHint,
            onChanged: (value) {
              setState(() {
                selectedDistrict = value;
              });
            },
            initialValue: selectedDistrict,
            isProvinceSelected: isProvinceSelected,
          ),
          SizedBox(height: 20.h),
          CustomDropdown(
            hint: 'City',
            value: selectedCity,
            items: cities,
            onChanged: (value) {
              setState(() {
                selectedCity = value;
                // cityController.text = value ?? '';
              });
            },
          ),
          SizedBox(height: 20.h),
          CustomDropdown(
            hint: 'Muqam',
            value: selectedMuqam,
            items: muqams,
            onChanged: (value) {
              setState(() {
                selectedMuqam = value;
                // muqamController.text = value ?? '';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget already_login_button() {
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
                      fontFamily: 'Gilroy'),
                )
              ])),
    );
  }

  Widget back_button() {
    return GestureDetector(
        onTap: () {
          Navigator.pop(context, true);
        },
        child: Image(
          image: const AssetImage("assets/back_arrow.png"),
          height: 24.h,
          width: 24.w,
        ));
  }

  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    confirmpasswordController.dispose();
    locationControllers.values.forEach((controller) => controller.dispose());
    membershipController.dispose();
    super.dispose();
  }
}
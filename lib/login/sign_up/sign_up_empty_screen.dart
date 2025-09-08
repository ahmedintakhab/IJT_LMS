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
  bool hasAffiliation = false;
  bool isChecked = false;


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
  // Declare a GlobalKey for accessing state
  final GlobalKey<TermConditionCheckboxState> termsKey = GlobalKey();

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
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDropdownData(); // reload data every time this screen becomes active
  }


  Future<void> _loadDropdownData() async {
    setState(() => isDataLoading = true);
    final prefs = await SharedPreferences.getInstance();

    // Pre-load all data (countries and provinces for all countries)
    await locationDataService.preloadAllData(prefs);

    // Load countries into the state
    countries = await locationDataService.fetchCountries(prefs);

    // Load affiliation from prefs or set default
    int? affiliationInt = prefs.getInt('has_affiliation');
    if (affiliationInt == null) {
      affiliationInt = 0;
      await prefs.setInt('has_affiliation', 0);
    }
    hasAffiliation = affiliationInt == 1;

    // Check if a country is saved in prefs, otherwise select Pakistan
    selectedCountry = prefs.getString('selected_country');
    if (selectedCountry == null) {
      final pakistan = countries.firstWhere(
            (c) => c['country_name'].toString().toLowerCase() == 'pakistan',
        orElse: () => {},
      );
      if (pakistan.isNotEmpty) {
        selectedCountry = pakistan['country_name'];
        await prefs.setString('country_id', pakistan['id'].toString());
        await prefs.setString('selected_country', selectedCountry!);
        provinces = await locationDataService.fetchProvinces(pakistan['id'].toString(), prefs);
        isCountrySelected = true;
        provinceHint = '--Select Province--';
      }
    } else {
      // If a country is already saved, load its provinces
      final countryId = prefs.getString('country_id');
      if (countryId != null) {
        provinces = await locationDataService.fetchProvinces(countryId, prefs);
        isCountrySelected = true;
        provinceHint = '--Select Province--';
      }
    }

    // Load selected province from prefs if available
    selectedProvince = prefs.getString('selected_province');
    if (selectedProvince != null) {
      final provinceId = prefs.getString('province_id');
      if (provinceId != null) {
        if (hasAffiliation) {
          muqams = await locationDataService.fetchMuqams(provinceId, prefs);
        } else {
          districts = await locationDataService.fetchDistricts(provinceId, prefs);
        }
        isProvinceSelected = true;
        districtHint = '--Select District--';
      }
    }

    // Load selected district from prefs if available and no affiliation
    if (!hasAffiliation) {
      selectedDistrict = prefs.getString('selected_district');
      if (selectedDistrict != null) {
        final districtId = prefs.getString('district_id');
        if (districtId != null) {
          cities = await locationDataService.fetchCities(districtId, prefs);
          isDistrictSelected = true;
          cityHint = '--Select City--';
        }
      }
    }

    // Load selected city from prefs if available and no affiliation
    if (!hasAffiliation) {
      selectedCity = prefs.getString('selected_city');
      if (selectedCity != null) {
        final cityId = prefs.getString('city_id');
        if (cityId != null) {
          muqams = await locationDataService.fetchMuqams(cityId, prefs);
          isCitySelected = true;
          muqamHint = '--Select Muqam--';
        }
      }
    }

    // Load selected muqam from prefs if available
    selectedMuqam = prefs.getString('selected_muqam');
    if (selectedMuqam != null && (isProvinceSelected || isCitySelected)) {
      muqamHint = '--Select Muqam--';
    }

    setState(() => isDataLoading = false);
  }

  Future<Map<String, String?>> getAllIdsFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'country_id': prefs.getString('country_id'),
      'province_id': prefs.getString('province_id'),
      'district_id': hasAffiliation ? null : prefs.getString('district_id'),
      'city_id': hasAffiliation ? null : prefs.getString('city_id'),
      'muqam_id': prefs.getString('muqam_id'),
      'student_type': prefs.getInt('has_affiliation')?.toString(),
    };
  }

  Future<void> registerUser() async {
    if (!formkey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    final ids = await getAllIdsFromSharedPreferences();

    // Check required fields for both cases
    if (ids['country_id'] == null || ids['province_id'] == null || ids['student_type'] == null) {
      Get.snackbar(
        'Error',
        'Please select Country, Province, and Affiliation',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Missing required selections: Country, Province, or Affiliation: $ids');
      return;
    }

    // Validation for "No" case: District and City required
    if (!hasAffiliation && (ids['district_id'] == null || ids['city_id'] == null)) {
      Get.snackbar(
        'Error',
        'Please select District and City',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Missing District or City for non-affiliated user');
      return;
    }

    // Validation for "Yes" case: Muqam required
    // if (hasAffiliation && ids['muqam_id'] == null) {
    //   Get.snackbar(
    //     'Error',
    //     'Please select Muqam',
    //     snackPosition: SnackPosition.TOP,
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //   );
    //   print('Missing Muqam selection for affiliated user');
    //   return;
    // }

    setState(() => isLoading = true);

    String mobileNumber = phoneNumber.trim();

    if (mobileNumber.isEmpty) {
      Get.snackbar(
        'Error',
        'Phone number cannot be empty',
        snackPosition: SnackPosition.TOP,
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
      'district_id': hasAffiliation ? null : ids['district_id'],
      'city_id': hasAffiliation ? null : ids['city_id'],
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
        Get.snackbar(
          'Successful',
          'User registered successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        await Future.delayed(Duration(seconds: 2));
        Get.off(() => const EmptyState());
      } else {
        String errorMessage = 'Registration failed';
        try {
          final responseData = json.decode(response.body);
          if (response.statusCode == 422 && responseData.containsKey('data')) {
            final errors = responseData['data'] as Map<String, dynamic>;
            if (errors.containsKey('email') && errors['email'] is List && errors['email'].isNotEmpty) {
              errorMessage = errors['email'][0];
            } else if (errors.containsKey('mobile_number') &&
                errors['mobile_number'] is List &&
                errors['mobile_number'].isNotEmpty) {
              errorMessage = errors['mobile_number'][0];
            } else if (errors.isNotEmpty) {
              errorMessage = errors.values.first[0];
            } else if (responseData.containsKey('message')) {
              errorMessage = responseData['message'];
            }
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        } catch (e) {
          errorMessage = 'Registration failed: Invalid response from server';
          print('Error parsing response: $e');
        }

        if (response.statusCode == 429) {
          errorMessage = 'Too many requests. Please try again later.';
        } else if (response.statusCode >= 500) {
          errorMessage = 'Server error. Please try again later.';
        }

        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        print('Register API error: $errorMessage');
      }
    } catch (e) {
      String errorMessage = 'An error occurred: ${e.toString()}';
      if (e.toString().contains('SocketException')) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
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
              SizedBox(height: 30.h),
              Row(
                children: [
                  backButton(),
                  SizedBox(width: 60.h),
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
                ],
              ),
              SizedBox(height: 30.h),
              Expanded(
                child: isDataLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF00AFEE)))
                    : ListView(
                  children: [
                    detailForm(),
                  ],
                ),
              ),
              TermConditionCheckbox(key: termsKey),
              SizedBox(height: 20),

              CustomButton(
                buttonText: "Sign Up",
                isLoading: isLoading,
                onTap: () {
                  // 🔑 Validate checkbox before calling registerUser()
                  if (termsKey.currentState?.validateAgreement() ?? false) {
                    registerUser();
                  }
                },
              ),
              SizedBox(height: 15.h),
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
                phoneNumber = phone;
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
          AffiliationField(
            controller: membershipController,
            onAffiliationChanged: (bool? value) async {
              final prefs = await SharedPreferences.getInstance();
              setState(() {
                hasAffiliation = value ?? false;
                if (!hasAffiliation) {
                  selectedMuqam = null;
                  muqams = [];
                } else if (hasAffiliation && selectedProvince != null) {
                  final provinceItem = provinces.firstWhere((item) => item['province_name'] == selectedProvince);
                  locationDataService.fetchMuqams(provinceItem['id'].toString(), prefs).then((newMuqams) {
                    setState(() {
                      muqams = newMuqams;
                      selectedMuqam = null;
                      muqamHint = '--Select Muqam--';
                    });
                  });
                }
                selectedDistrict = null;
                selectedCity = null;
                districts = [];
                cities = [];
              });
              await prefs.setInt('has_affiliation', hasAffiliation ? 1 : 0);
              await prefs.remove('district_id');
              await prefs.remove('selected_district');
              await prefs.remove('city_id');
              await prefs.remove('selected_city');
              await prefs.remove('muqam_id');
              await prefs.remove('selected_muqam');
            },
          ),
          SizedBox(height: 20.h),
          CountryDropdown(
            hint: 'Country',
            items: countries,
            onChanged: (value) async {
              final prefs = await SharedPreferences.getInstance();
              List<Map<String, dynamic>> newProvinces = [];
              if (value != null) {
                final selectedItem = countries.firstWhere((item) => item['country_name'] == value);
                await prefs.setString('country_id', selectedItem['id'].toString());
                await prefs.setString('selected_country', value);
                newProvinces = await locationDataService.fetchProvinces(selectedItem['id'].toString(), prefs);
              } else {
                await prefs.remove('country_id');
                await prefs.remove('selected_country');
              }

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
              List<Map<String, dynamic>> newMuqams = [];
              if (value != null) {
                final selectedItem = provinces.firstWhere((item) => item['province_name'] == value);
                await prefs.setString('province_id', selectedItem['id'].toString());
                await prefs.setString('selected_province', value);
                if (hasAffiliation) {
                  newMuqams = await locationDataService.fetchMuqams(selectedItem['id'].toString(), prefs);
                } else {
                  newDistricts = await locationDataService.fetchDistricts(selectedItem['id'].toString(), prefs);
                }
              } else {
                await prefs.remove('province_id');
                await prefs.remove('selected_province');
              }

              setState(() {
                selectedProvince = value;
                isProvinceSelected = value != null;
                districtHint = isProvinceSelected ? '--Select District--' : 'District';
                districts = newDistricts;
                muqams = newMuqams;
                selectedDistrict = null;
                selectedCity = null;
                selectedMuqam = null;
                isDistrictSelected = false;
                isCitySelected = false;
                cities = [];
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
          if (!hasAffiliation) ...[
            SizedBox(height: 20.h),
            DistrictDropdown(
              hint: districtHint,
              items: districts,
              onChanged: (value) async {
                final prefs = await SharedPreferences.getInstance();
                List<Map<String, dynamic>> newCities = [];
                if (value != null) {
                  final selectedItem = districts.firstWhere((item) => item['district_name'] == value);
                  await prefs.setString('district_id', selectedItem['id'].toString());
                  await prefs.setString('selected_district', value);
                  newCities = await locationDataService.fetchCities(selectedItem['id'].toString(), prefs);
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
                    await prefs.setString('city_id', selectedItem['id'].toString());
                    await prefs.setString('selected_city', value);
                    newMuqams = await locationDataService.fetchMuqams(selectedItem['id'].toString(), prefs);
                  }
                } else {
                  await prefs.remove('city_id');
                  await prefs.remove('selected_city');
                }

                setState(() {
                  selectedCity = value;
                  isCitySelected = value != null;
                  muqamHint = isCitySelected ? '--Select Muqam--' : '--Select Muqam--';
                  muqams = newMuqams;
                  selectedMuqam = null;
                });

                await prefs.remove('muqam_id');
                await prefs.remove('selected_muqam');
              },
              initialValue: selectedCity,
              isDistrictSelected: isDistrictSelected,
            ),
          ],
          if (hasAffiliation) ...[
            SizedBox(height: 20.h),
            MuqamDropdown(
              hint: muqamHint,
              items: muqams,
              onChanged: (value) async {
                final prefs = await SharedPreferences.getInstance();
                if (value != null) {
                  final selectedItem = muqams.firstWhere((item) => item['muqam_name'] == value);
                  await prefs.setString('muqam_id', selectedItem['id'].toString());
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
              isCitySelected: isProvinceSelected,
            ),
          ],
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
    passwordController.dispose();
    confirmpasswordController.dispose();
    locationControllers.values.forEach((controller) => controller.dispose());
    membershipController.dispose();
    super.dispose();
  }
}
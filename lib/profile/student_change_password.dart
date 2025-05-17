import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/api_constant.dart';
import '../widget/button.dart';
import '../widget/custom_text_form_field.dart';

class StudentChangePassword extends StatefulWidget {
  const StudentChangePassword({Key? key}) : super(key: key);

  @override
  State<StudentChangePassword> createState() => _StudentChangePasswordState();
}

class _StudentChangePasswordState extends State<StudentChangePassword> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _newpasswordconfirmationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool isoldpasswordHiden = true;
  bool isnewpasswordHiden = true;
  bool isconfirmnewpasswordHiden = true;


  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _newpasswordconfirmationController.dispose();
    super.dispose();
  }
  Future<void> _changePassword() async {
    if (_oldPasswordController.text.isEmpty || _newPasswordController.text.isEmpty ||
        _newpasswordconfirmationController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Retrieve the token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      // API endpoint for changing password (adjust the endpoint as per your API)
      final url = Uri.parse("${ApiConstant.baseUrl}student/change-password");

      // Prepare the request body
      final body = jsonEncode({
        'new_password_confirmation': _newpasswordconfirmationController.text,
        'new_password': _newPasswordController.text,
        'password': _oldPasswordController.text,
        'email': _emailController.text,
      });

      // Make the POST API request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      // Handle the response
      if (response.statusCode == 200) {
        print('Student Change Password Api response: ${response.statusCode}');
        Get.snackbar('Password Change','Password Update Successfully',
            snackPosition: SnackPosition.TOP,
            colorText: Colors.white,backgroundColor: Colors.green
        );

        // Clear the fields
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _emailController.clear();
        _newpasswordconfirmationController.clear();
      } else {
        final error = jsonDecode(response.body);
        Get.snackbar('Failed Update Password',error['message'] ,
            snackPosition: SnackPosition.TOP,
            colorText: Colors.white,backgroundColor: Colors.red
        );

      }
    } catch (e) {
      print('API error: $e');
      Get.snackbar('Failed Update Password', 'Error: $e',
          snackPosition: SnackPosition.TOP,
          colorText: Colors.white,backgroundColor: Colors.red
      );

    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  OldPasswordtoggle() {
    setState(() {
      isoldpasswordHiden = !isoldpasswordHiden;
    });
  }
  NewPasswordtoggle() {
    setState(() {
      isnewpasswordHiden = !isnewpasswordHiden;
    });
  }
  ConfirmNewPasswordtoggle() {
    setState(() {
      isconfirmnewpasswordHiden = !isconfirmnewpasswordHiden;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Center(
                  child: Text(
                    "Change Password",
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Gilroy',
                      color: Color(0XFF00AFEE),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10.r,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      Text(
                        "Email",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Gilroy',
                          color: const Color(0xFF000080),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      CustomTextFormField(
                        controller: _emailController,
                        hintText: "Email",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email is required";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "Old Password",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Gilroy',
                          color: const Color(0xFF000080),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      CustomTextFormField(
                        controller: _oldPasswordController,
                        hintText: 'Old Password',
                        obscureText: isoldpasswordHiden,
                        suffixIcon: isoldpasswordHiden
                            ? GestureDetector(
                          onTap: OldPasswordtoggle,
                          child: Image(
                            image: const AssetImage("assets/notvisible_eye.png"),
                            height: 20.h,
                            width: 20.w,
                          ),
                        )
                            : GestureDetector(
                          onTap: OldPasswordtoggle,
                          child: Image(
                            image: const AssetImage("assets/visible_eye.png"),
                            height: 20.h,
                            width: 20.w,
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter the Old password';
                          return null;
                        },
                      ),

                      SizedBox(height: 16.h),
                      Text(
                        "New Password",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Gilroy',
                          color: const Color(0xFF000080),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      CustomTextFormField(
                        controller: _newPasswordController,
                        hintText: 'New Password',
                        obscureText: isnewpasswordHiden,
                        suffixIcon: isnewpasswordHiden
                            ? GestureDetector(
                          onTap: NewPasswordtoggle,
                          child: Image(
                            image: const AssetImage("assets/notvisible_eye.png"),
                            height: 20.h,
                            width: 20.w,
                          ),
                        )
                            : GestureDetector(
                          onTap: NewPasswordtoggle,
                          child: Image(
                            image: const AssetImage("assets/visible_eye.png"),
                            height: 20.h,
                            width: 20.w,
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter the new password';
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "Confirm New Password ",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Gilroy',
                          color: const Color(0xFF000080),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      CustomTextFormField(
                        controller: _newpasswordconfirmationController,
                        hintText: 'Confirm New Password',
                        obscureText: isconfirmnewpasswordHiden,
                        suffixIcon: isconfirmnewpasswordHiden
                            ? GestureDetector(
                          onTap: ConfirmNewPasswordtoggle,
                          child: Image(
                            image: const AssetImage("assets/notvisible_eye.png"),
                            height: 20.h,
                            width: 20.w,
                          ),
                        )
                            : GestureDetector(
                          onTap: ConfirmNewPasswordtoggle,
                          child: Image(
                            image: const AssetImage("assets/visible_eye.png"),
                            height: 20.h,
                            width: 20.w,
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter the Confirm new password';
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),
                      CustomButton(
                        onTap: _isLoading ? () {} : _changePassword,
                        buttonText: _isLoading ? 'Updating...' : 'Change Password',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


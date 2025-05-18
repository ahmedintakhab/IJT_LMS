// ignore_for_file: non_constant_identifier_names
import 'dart:convert';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/home/home_main.dart';
import 'package:learn_megnagmet/login/forgot_password.dart';
import 'package:learn_megnagmet/login/sign_up/sign_up_empty_screen.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../utils/api_constant.dart';
import '../utils/screen_size.dart';
import '../widget/custom_text_form_field.dart';

class EmptyState extends StatefulWidget {
  const EmptyState({Key? key}) : super(key: key);

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState> {

  final formkey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool ispassHiden = true;
  bool isLoading = false;
  String authToken = '';

  Future<void> loginUser() async {
    if (!formkey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final url = '${ApiConstant.baseUrl}login';
    final data = {
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Extract token from nested data object
        final token = responseData['data']['token'];
        final role = responseData['data']['role'].toString();
        final userName = responseData['data']['user_name'];
        final userEmail = responseData['data']['user_email'];
        print('Check name email and role:$userName$userEmail$role');

        if (token != null && token.isNotEmpty) {
          authToken = token;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', token);
          await prefs.setString('role', role);
          await prefs.setString('userName', userName);
          await prefs.setString('userEmail', userEmail);

          Get.snackbar(
            'Successful',
            responseData['message'] ?? 'User login successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Navigate to home screen or dashboard
           Get.off(() => const HomeMainScreen());
        } else {
          Get.snackbar(
            'Error',
            'Authentication token not received',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        String errorMessage = responseData['message'] ?? 'Login failed';
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    initializeScreenSize(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: Padding(
            padding:  EdgeInsets.only(left: 20.w, right: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: (){
                    Navigator.pop(exit(0));
                  },
                  child:  Image(
                    image: const AssetImage("assets/back_arrow.png"),
                    height: 24.h,
                    width: 24.w,
                  )
                ),

                Expanded(
                  flex: 1,
                  child: ListView(
                    primary: true,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 20.h),
                      Center(
                        child: Text(
                          "Login",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 24.sp,
                              fontFamily: 'Gilroy',
                              color: Color(0XFF000000)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Center(
                          child: Text(
                            "Glad to meet you again!",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: const Color(0XFF000000),
                                fontSize: 15.sp,
                                fontFamily: 'Gilroy',
                                fontStyle: FontStyle.normal
                            ),
                            textAlign: TextAlign.center,
                          )),
                      SizedBox(height: 10.h),
                      email_password_form(),
                      SizedBox(height: 21.h),
                      forgotpassword(),
                      SizedBox(height: 40.h),
                      // loginbutton(),
                      CustomButton(
                        onTap: loginUser,
                        buttonText: 'Log In',
                        isLoading: isLoading,
                      ),
                      SizedBox(height: 40.h),
                      // CustomButton(onTap: (){
                      //   Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeMainScreen()));
                      // }, buttonText: 'Skip'),
                      SizedBox(height: 40.h),
                      or_sign_in_with_text(),
                      SizedBox(height: 41.h),
                      login_google(),
                      SizedBox(height: 20.h),
                      login_facebook(),
                      //SizedBox(height: 97.h),

                    ],
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.only(bottom: 30.h),
                  child: sign_up(),
                ),
              ],
            ),
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

  Widget forgotpassword() {
    return GestureDetector(
      onTap: () {
        Get.to(const ForgotPassword());
      },
      child:  Align(
        alignment: Alignment.topRight,
        child: Text(
          "Forgot password ?",
          style: TextStyle(
            fontFamily: 'Gilroy',
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
            color: Color(0XFF00AFEE),
          ),
        ),
      ),
    );
  }
  Widget login_google() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 56.h,
        width: 374.w,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.withOpacity(0.1)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            const Image(image: AssetImage("assets/google.png")),
            SizedBox(width: 10.w),
            Text(
              "Login with Google",
              style: TextStyle(color: Color(0XFF000000), fontSize: 18.sp,fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget login_facebook() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 56.h,
        width: 374.w,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.withOpacity(0.1)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            const Image(image: AssetImage("assets/facebook.png")),
            SizedBox(width: 10.w),
            Text(
              "Login with Facebook",
              style: TextStyle(color: const Color(0XFF000000), fontSize: 18.sp,fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget sign_up() {
    return Center(
      child: RichText(
          text: TextSpan(
              text: 'Dont have an account?',
              style:  TextStyle(color: Colors.black, fontSize: 15.sp,fontFamily: 'Gilroy'),
              children: [
            TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Get.to(const SignUpEmptyScreen());
                },
              text: ' Sign up',
              style:  TextStyle(
                color: Color(0XFF000000),
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Gilroy'
              ),
            )
          ])),
    );
  }

  Widget or_sign_in_with_text() {
    return Row(
      children: [
         Expanded(
          child: Divider(
            height: 0.h,
            thickness: 2,
            indent: 20,
            endIndent: 0,
            color: const Color(0XFFDEDEDE),
          ),
        ),
        GestureDetector(
          child:  Text("OR Sign in with",
              style: TextStyle(
                  color: const Color(0XFF000000),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Gilroy',fontStyle: FontStyle.normal)),
        ),
         Expanded(
          child: Divider(
            height: 0.h,
            thickness: 2,
            indent: 20,
            endIndent: 0,
            color: const Color(0XFFDEDEDE),
          ),
        )
      ],
    );
  }

  Widget email_password_form() {
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
           SizedBox(height: 15.h),
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
              return null;
            },
          ),
        ],
      ),
    );
  }
}

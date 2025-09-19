// ignore_for_file: non_constant_identifier_names

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:learn_megnagmet/login/reset_password.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:learn_megnagmet/widget/custom_text_form_field.dart';
import '../utils/api_constant.dart';
import '../utils/screen_size.dart';
import 'login_empty_state.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> sendVerificationCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final url = '${ApiConstant.baseUrl}forgot-password';
      final response = await http.post(
        Uri.parse(url),
        body: {'email': emailController.text},
      );

      if (response.statusCode == 200) {
        print('Check forgot password api response: ${response.statusCode}');
        Get.to(() => const ResetPassword());
      } else {
        print('Failed to send verification code: ${response.statusCode}');
        print('Failed to send verification code: ${response.body}');
      }
    } catch (e) {
      print(' Forgor password api Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeScreenSize(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: WillPopScope(
        onWillPop: () {
          return Future.value(false);
        },
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      backbutton(),
                      SizedBox(width: 56.w),
                      Center(
                        child: Text(
                          "Forgot Password",
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontFamily: 'Gilroy',
                            color: const Color(0XFF000000),
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.h),
                  Expanded(
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Enter the email address you used when you joined and we’ll send you instructions to reset your password. For security reasons, we do NOT store your password. So rest assured that we will never send your password via email.",
                              style: TextStyle(
                                color: const Color(0XFF000000),
                                fontSize: 15.sp,
                                fontFamily: 'Gilroy',
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(height: 54.h),
                        CustomTextFormField(
                          controller: emailController,
                          hintText: 'Email',
                          labelText: 'Email',
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Enter the email';
                            if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(val)) {
                              return "Please enter valid email address";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30.h),
                        CustomButton(
                          onTap: sendVerificationCode,
                          buttonText: 'Submit',
                          isLoading: isLoading,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 30.h),
                    child: back_login_button(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget back_login_button() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: 'Back to login?',
          style: TextStyle(
            color: Colors.black,
            fontSize: 15.sp,
            fontFamily: 'Gilroy',
            fontWeight: FontWeight.w400,
          ),
          children: [
            TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Get.off(() => const EmptyState());
                },
              text: ' Login',
              style: TextStyle(
                fontFamily: 'Gilroy',
                color: Color(0XFF000000),
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget backbutton() {
    return GestureDetector(
      onTap: () {
        Get.back();
      },
      child: Image(
        image: const AssetImage("assets/back_arrow.png"),
        height: 24.h,
        width: 24.w,
      ),
    );
  }
}

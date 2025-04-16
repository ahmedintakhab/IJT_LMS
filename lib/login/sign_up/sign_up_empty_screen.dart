import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/login/login_empty_state.dart';
import 'package:learn_megnagmet/login/sign_up/sign_in_phonenumber.dart';
import 'package:learn_megnagmet/login/sign_up/term_and_condition.dart';
import 'package:learn_megnagmet/widget/custom_text_form_field.dart';
import 'package:learn_megnagmet/widget/phone_number_field.dart';

import '../../utils/screen_size.dart';
import 'affiliation_field.dart';

class SignInEmptyScreen extends StatefulWidget {
  const SignInEmptyScreen({Key? key}) : super(key: key);

  @override
  State<SignInEmptyScreen> createState() => _SignInEmptyScreenState();
}

class _SignInEmptyScreenState extends State<SignInEmptyScreen> {

  bool ischeaked = false;
  bool ispassHiden = true;
  bool ispassHiden1 = true;

  String passworderror = '';
  final formkey = GlobalKey<FormState>();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController provinceController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController muqamController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();

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
          padding:  EdgeInsets.only(left: 20.w, right: 20.w),
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
             //  SizedBox(height: 20.h),
              Expanded(
                child:ListView(
                  children: [
                    detailform(),
                    SizedBox(height: 25.h),
                    term_condition_cheakbox(),
                    SizedBox(height: 25.h),
                    sign_up_button(),
                  ],
                ),
              ),
              Padding(
                padding:  EdgeInsets.only(bottom: 30.h),
                child: already_login_button(),
              ),
              //Checkbox
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
          PhoneNumberField(),
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
              if (val == null || val.isEmpty) return 'Enter the confirmpassword';
              return null;
            },
          ),
          SizedBox(height: 20.h),
          const AffiliationField(),
          SizedBox(height: 20.h),
          CustomTextFormField(
            controller: countryController,
            hintText: 'Country',
            validator: (val) {
              if (val == null || val.isEmpty) return 'Enter the country';
              return null;
            },
          ),
          SizedBox(height: 20.h),
          CustomTextFormField(
            controller: provinceController,
            hintText: 'Province',
            validator: (val) {
              if (val == null || val.isEmpty) return 'Enter the province';
              return null;
            },
          ),
          SizedBox(height: 20.h),
          CustomTextFormField(
            controller: districtController,
            hintText: 'District',
            validator: (val) {
              if (val == null || val.isEmpty) return 'Enter the district';
              return null;
            },
          ),
          SizedBox(height: 20.h),
          CustomTextFormField(
            controller: cityController,
            hintText: 'City',
            validator: (val) {
              if (val == null || val.isEmpty) return 'Enter the city';
              return null;
            },
          ),
          SizedBox(height: 20.h),
          CustomTextFormField(
            controller: muqamController,
            hintText: 'Muqam',
            validator: (val) {
              if (val == null || val.isEmpty) return 'Enter the muqam';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget term_condition_cheakbox() {
    return Row(
      children: [
        Checkbox(

          activeColor: const Color(0XFF23408F),
          side: const BorderSide(color: Color(0XFFDEDEDE)),
          value: ischeaked,
          onChanged: (value) {
            setState(() {
              ischeaked = value!;
            });
          },
        ),
        RichText(
            text: TextSpan(
                text: 'I Agree with ',
                style:  TextStyle(color: Colors.black, fontSize: 15.sp, fontFamily: 'Gilroy',fontWeight: FontWeight.w400),
                children: [
              TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {

                    Get.to(const TermCondition());
                  },
                text: 'Terms and condition',
                style: const TextStyle(
                    color: Color(0XFF23408F),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Gilroy'),
              )
            ])),
      ],
    );
  }

  Widget sign_up_button() {
    return Container(
      height: 56.h,
      width: 374.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0XFF23408F),
      ),
      child: TextButton(
        onPressed: ischeaked
            ? () {
                if (formkey.currentState!.validate()) {
                  if (confirmpasswordController.value == passwordController.value) {
                    Get.to(const SignInPhonenumber());
                  }
                }
              }
            : null,
        child:  Text("Sign Up",
            style: TextStyle(
                color: Color(0XFFFFFFFF),
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Gilroy')),
      ),
    );
  }

  Widget already_login_button() {
    return Align(
      alignment: Alignment.center,
      child: RichText(
          text: TextSpan(
              text: 'Already have an account? ',
              style:  TextStyle(color: Colors.black, fontSize: 15.sp,fontFamily: 'Gilroy'),
              children: [
            TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Get.off(const EmptyState());
                },
              text: 'Login',
              style:  TextStyle(
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
    passwordController.dispose();
    confirmpasswordController.dispose();
    countryController.dispose();
    provinceController.dispose();
    districtController.dispose();
    cityController.dispose();
    muqamController.dispose();
    confirmpasswordController.dispose();
    super.dispose();
  }
}

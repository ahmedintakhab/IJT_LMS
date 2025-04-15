import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/login/login_empty_state.dart';
import 'package:learn_megnagmet/login/sign_up/sign_in_phonenumber.dart';
import 'package:learn_megnagmet/login/sign_up/term_and_condition.dart';

import '../../utils/screen_size.dart';

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
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpassController = TextEditingController();

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
          TextFormField(
            controller: nameController,

            decoration: InputDecoration(

                hintText: 'Name',
                hintStyle:  TextStyle(
                    fontSize: 15.sp,
                    fontFamily: 'Gilroy',
                    color: const Color(0XFF9B9B9B),
                    fontWeight: FontWeight.bold),

                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: const Color(0XFF23408F), width: 1.w)),
                enabledBorder:OutlineInputBorder(
                  borderSide: BorderSide(color: const Color(0XFFDEDEDE),width: 1.w),
                  borderRadius: BorderRadius.circular(12),
                ),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              contentPadding: EdgeInsets.only(left: 20.w,top:20.h,bottom: 20.h),
            ),
            validator: (val) {
              if (val!.isEmpty) return 'Enter the  Name';
              return null;
            },
          ),
          SizedBox(height: 20.h),
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
                hintText: 'Email',
                hintStyle:  TextStyle(
                    fontSize: 15.sp,
                    fontFamily: 'Gilroy',
                    color: const Color(0XFF9B9B9B),
                    fontWeight: FontWeight.bold),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: const Color(0XFF23408F), width: 1.w)),
                enabledBorder:OutlineInputBorder(
                  borderSide: BorderSide(color: const Color(0XFFDEDEDE),width: 1.w),
                  borderRadius: BorderRadius.circular(12),
                ), filled: true,
              fillColor: const Color(0xFFF5F5F5),
              contentPadding: EdgeInsets.only(left: 20.w,top:20.h,bottom: 20.h),),
            validator: (val) {
              if (val!.isEmpty)
                return 'Enter the  email';
              else {
                if (!RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(val)) {
                  return "Please enter valid email address";
                }
              }
              return null;
            },
          ),
           SizedBox(height: 20.h),
          TextFormField(
            controller: passwordController,
            obscureText: ispassHiden,
            decoration: InputDecoration(
                suffixIcon:ispassHiden
                    ? GestureDetector(
                    onTap: () => toggle(),
                    child:  Image(image: const AssetImage("assets/notvisible_eye.png"),height: 20.h,width: 20.w,))
                    : GestureDetector(
                    onTap: () => toggle(),
                    child:  Image(image: const AssetImage("assets/visible_eye.png"),height: 20.h,width: 20.w,)),
                hintText: 'Password',
                hintStyle: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'Gilroy',
                    color: Color(0XFF9B9B9B),
                    fontWeight: FontWeight.bold),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: const Color(0XFF23408F), width: 1.w)),
                enabledBorder:OutlineInputBorder(
                  borderSide: BorderSide(color: const Color(0XFFDEDEDE),width: 1.w),
                  borderRadius: BorderRadius.circular(12),
                ), filled: true,
              fillColor: const Color(0xFFF5F5F5),
              contentPadding: EdgeInsets.only(left: 20.w,top:20.h,bottom: 20.h),),
            validator: (val) {
              if (val!.isEmpty) return 'Enter the  password';
              return null;
            },
          ),
           SizedBox(height: 20.h),
          TextFormField(
            controller: confirmpassController,
            obscureText: ispassHiden1,
            decoration: InputDecoration(
                suffixIcon: ispassHiden1
                    ? GestureDetector(
                    onTap: () => toggle1(),
                    child:  Image(image:const  AssetImage("assets/notvisible_eye.png"),height: 20.h,width: 20.w,))
                    : GestureDetector(
                    onTap: () => toggle1(),
                    child:  Image(image: const AssetImage("assets/visible_eye.png"),height: 20.h,width: 20.w,)),
                hintText: 'Confirm password',
                hintStyle:  TextStyle(
                    fontSize: 15.sp,
                    fontFamily: 'Gilroy',
                    color: const Color(0XFF9B9B9B),
                    fontWeight: FontWeight.bold),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: const Color(0XFF23408F), width: 1.w)),
                enabledBorder:OutlineInputBorder(
                  borderSide:  BorderSide(color: Color(0XFFDEDEDE),width: 1.w),
                  borderRadius: BorderRadius.circular(12),
                ), filled: true,
              fillColor: const Color(0xFFF5F5F5),
              contentPadding: EdgeInsets.only(left: 20.w,top:20.h,bottom: 20.h),),
            validator: (val) {
              if (val!.isEmpty) return 'Enter the  confirmpassword';
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
                  if (confirmpassController.value == passwordController.value) {
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmpassController.dispose();
    super.dispose();
  }
}

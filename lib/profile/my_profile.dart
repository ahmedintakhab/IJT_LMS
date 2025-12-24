import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/profile/profile_field_container.dart';
import 'package:learn_megnagmet/profile/recommended_courses_list.dart';
import 'package:learn_megnagmet/profile/student_change_password.dart';
import 'package:learn_megnagmet/profile/student_update_profile.dart';
import 'package:learn_megnagmet/utils/slider_page_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../controller/controller.dart';
import '../login/login_empty_state.dart';
import '../models/new_user_detail.dart';
import '../models/profile_option.dart';
import '../utils/api_constant.dart';
import '../utils/screen_size.dart';
import '../utils/shared_pref.dart';
import 'package:http/http.dart' as http;

import '../widget/button.dart';


class MyProfile extends StatefulWidget {
  const MyProfile({Key? key, required this.user_detail}) : super(key: key);
  final User user_detail;


  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  MyProfileController myProfileController = Get.put(MyProfileController());
  List<ProfileOption> profileoption = Utils.getProfileOption();
  HomeMainController controller = Get.put(HomeMainController());
  String? userName;
  String? userEmail;
  String? userImage;


  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Guest';
      userEmail = prefs.getString('userEmail') ?? 'guest@gmail.com';
      userImage = prefs.getString('image');
    });
  }


  Future<void> logoutApiCall() async {
    final String apiUrl = "${ApiConstant.baseUrl}logout";
    bool isLoggingOut = false;

    if (isLoggingOut) return;
    isLoggingOut = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('authToken') ?? '';

      if (token.isEmpty) {
        Get.snackbar('Error', 'No session found. Please log in again.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3));
        await prefs.clear();
        await PrefData.setLogin(false);
        return;
      }

      final response = await http
          .post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: '{}',
      );
      //     .timeout(const Duration(seconds: 10), onTimeout: () {
      //   throw const HttpException('Request timed out');
      // });

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Logged out successfully.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3));
        await prefs.clear();
        await PrefData.setLogin(false);
        await Future.delayed(const Duration(seconds: 1));
        if (Get.currentRoute != '/EmptyState') {
          Get.off(() => const EmptyState());
        }
      } else {
        String message;
        Color bgColor = Colors.red;
        switch (response.statusCode) {
          case 302:
            message = 'Server redirected request. Please try again.';
            break;
          case 401:
            message = 'Session expired. Please log in again.';
            bgColor = Colors.orange;
            break;
          case 402:
            message = 'Payment issue. Please contact support.';
            break;
          case 403:
            message = 'Access denied.';
            break;
          case 500:
            message = 'Server error. Please try again later.';
            break;
          default:
            message = 'Logout failed. Please try again.';
        }
        Get.snackbar('Error', message,
            snackPosition: SnackPosition.TOP,
            backgroundColor: bgColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 3));
        await prefs.clear();
        await PrefData.setLogin(false);
      }
    }  finally {
      isLoggingOut = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeScreenSize(context);
    return WillPopScope(
      onWillPop: (){
        return Future.value(false);
      },
      child: Scaffold(
        body: GetBuilder(
            init: MyProfileController(),
            builder: (MyProfileController) =>
                SafeArea(
                  child: Column(
                    children: [
                       SizedBox(height: 20.h),
                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          children: [
                            GestureDetector(
                                onTap: () {
                                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                                },
                                child:  Image(
                                  image: AssetImage("assets/back_arrow.png"),
                                  height: 24.h,
                                  width: 24.w,
                                )),
                             SizedBox(width: 15.w),
                             Text(
                              "My Profile",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 24.sp,fontFamily: 'Gilroy'),
                            ),
                            SizedBox(width: 40.w),
                            SizedBox(width: 180.w, height: 35.h,
                                child: CustomButton(onTap: (){}, buttonText: 'Student Panel'))
                          ],
                        ),
                      ),
                       SizedBox(height: 20.h),
                      // Updated Image widget with shimmer and person icon
                      ClipOval(
                        child: userImage == null || userImage!.isEmpty
                            ? Icon(
                          Icons.person,
                          size: 100.w,
                          color: Colors.grey,
                        )
                            : Image(
                          image: NetworkImage(userImage!),
                          height: 100.h,
                          width: 100.w,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child; // Image loaded, show it
                            }
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                height: 100.h,
                                width: 100.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[300],
                                ),
                              ),
                            ); // Circular shimmer effect while loading
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 100.w,
                              color: Colors.grey,
                            ); // Person icon if image fails
                          },
                        ),
                      ),
                       SizedBox(height: 12.h),
                      Text(
                        userName ?? 'Guest',
                        style:  TextStyle(
                            fontSize: 18.sp,
                            fontFamily: 'Gilroy',
                            fontWeight: FontWeight.w700,
                            color: const Color(0XFF000000)),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        userEmail ?? 'guest@gmail.com',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: 'Gilroy',
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF000000),
                        ),
                      ),
                      // GestureDetector(
                      //   onTap: () {
                      //
                      //     Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (context) =>
                      //                 EditScreen(
                      //                   user: widget.user_detail,
                      //                 )));
                      //   },
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children:  [
                      //       Text("Edit Profile",
                      //           style: TextStyle(
                      //               fontSize: 15.sp,
                      //               fontFamily: 'Gilroy',
                      //               fontWeight: FontWeight.w400,
                      //               color: Color(0XFF000000))),
                      //       Image(
                      //         image: AssetImage("assets/editsymbol.png"),
                      //         height: 16.h,
                      //         width: 16.w,
                      //       )
                      //     ],
                      //   ),
                      // ),
                      SizedBox(height: 20,),
                      Expanded(
                        child: ListView(
                          primary: true,
                          shrinkWrap: false,
                          children: [
                            ProfileFieldContainer(
                              title: 'Edit Profile',
                              icon: Icon(Icons.edit, color: Color(0XFF00AFEE)),
                              onTap: () {
                                Get.to(StudentUpdateProfile());
                              },
                            ),
                            ProfileFieldContainer(
                              title: 'Recommended Courses',
                              icon: Icon(Icons.book, color: Color(0XFF00AFEE)),
                              onTap: () {
                                Get.to(RecommendedCoursesList());
                              },
                            ),
                            ProfileFieldContainer(
                              title: 'Privacy Policy',
                              icon: Icon(Icons.lock, color: Color(0XFF00AFEE)),
                              onTap: () {
                                // Get.to(PrivacyPolicy());
                              },
                            ),
                            ProfileFieldContainer(
                              title: 'Help Center',
                              icon: Icon(Icons.help_center, color: Color(0XFF00AFEE)),
                              onTap: () {
                                // Get.to(HelpCenter());
                              },
                            ),
                            ProfileFieldContainer(
                              title: 'Change Password',
                              icon: Icon(Icons.password, color: Color(0XFF00AFEE)),
                              onTap: () {
                                Get.to(StudentChangePassword());
                              },
                            ),

                            SizedBox(height: 30.h),
                            Padding(
                              padding: EdgeInsets.only(bottom: 40.h, left: 20.h, right: 20.h),
                              child: GestureDetector(
                                onTap: () {
                                  showLogoutDialog();
                                },
                                child: Container(
                                  height: 56.h,
                                  width: 374.w,
                                  decoration: BoxDecoration(
                                    color: Color(0XFF00AFEE),
                                    border: Border.all(
                                      color: const Color(0xFF00AFEE),
                                      style: BorderStyle.solid,
                                      width: 1.0.w,
                                    ),
                                    borderRadius: BorderRadius.circular(8.h),
                                  ),
                                  child: Center(
                                    child: Text("Logout",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22.sp,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Nastaleeq')),
                                  ),
                                ),
                              ),
                            )




                          ],
                        ),
                      ),
                      //SizedBox(height: 30),


                    ],
                  ),
                )),
      ),
    );
  }


  void showLogoutDialog() {
    bool isLoggingOut = false; // Track loading state

    Get.defaultDialog(
      barrierDismissible: false,
      title: '',
      content: Padding(
        padding: EdgeInsets.only(left: 10.w, right: 10.w),
        child: Column(
          children: [
            Text(
              "Are you sure you want to Logout?",
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Gilroy',
              ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.only(top: 25.h, bottom: 13.h),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        if (isLoggingOut) return;
                        setState(() => isLoggingOut = true);
                        await logoutApiCall();
                        setState(() => isLoggingOut = false);
                        Get.back(); // Close dialog
                      },
                      child: Container(
                        height: 56.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.h),
                          color: const Color(0XFF00AFEE),
                        ),
                        child: Center(
                          child: isLoggingOut
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                            "Yes",
                            style: TextStyle(
                              fontFamily: 'Nastaleeq',
                              fontWeight: FontWeight.bold,
                              color: Color(0XFFFFFFFF),
                              fontStyle: FontStyle.normal,
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        height: 56.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0XFF00AFEE),
                            style: BorderStyle.solid,
                            width: 1.0.w,
                          ),
                          borderRadius: BorderRadius.circular(8.h),
                        ),
                        child: Center(
                          child: Text(
                            "No",
                            style: TextStyle(
                              fontFamily: 'Nastaleeq',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00AFEE),
                              fontStyle: FontStyle.normal,
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

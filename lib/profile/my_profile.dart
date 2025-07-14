import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/profile/profile_field_container.dart';
import 'package:learn_megnagmet/profile/student_change_password.dart';
import 'package:learn_megnagmet/profile/student_update_profile.dart';
import 'package:learn_megnagmet/utils/slider_page_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    });
  }


  Future<void> logoutApiCall() async {
    final String apiUrl = "${ApiConstant.baseUrl}logout";
    bool isLoggingOut = false; // Prevent multiple taps

    if (isLoggingOut) return;
    isLoggingOut = true;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';
      if (token.isEmpty) {
        Get.snackbar(
          'Error',
          'No valid token found',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        await prefs.clear();
        await PrefData.setLogin(false);
        await Future.delayed(Duration(seconds: 2)); // Delay for snackbar visibility
        if (Get.currentRoute != '/EmptyState') {
          Get.off(() => EmptyState());
        }
        return;
      }
      print('Token check: $token');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // Added to match Postman
          'Authorization': 'Bearer $token',
        },
        body: '{}',
      );

      if (response.statusCode == 200) {
        print('Logout api response: ${response.statusCode}');
        Get.snackbar(
          'Successful',
          'User logout successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        await prefs.clear();
        await PrefData.setLogin(false);
        await Future.delayed(Duration(seconds: 1)); // Delay for snackbar visibility
        if (Get.currentRoute != '/EmptyState') {
          Get.off(() => EmptyState());
        }
      } else if (response.statusCode == 401) {
        Get.snackbar(
          'Info',
          'Session expired. Logging out.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        await prefs.clear();
        await PrefData.setLogin(false);
        await Future.delayed(Duration(seconds: 2)); // Delay for snackbar visibility
        if (Get.currentRoute != '/EmptyState') {
          Get.off(() => EmptyState());
        }
      } else {
        Get.snackbar(
          'Failed',
          'Logout failed: ${response.statusCode} ${response.body}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        print("Logout failed: ${response.statusCode} ${response.body}");
        await prefs.clear();
        await PrefData.setLogin(false);
        await Future.delayed(Duration(seconds: 2)); // Delay for snackbar visibility
        if (Get.currentRoute != '/EmptyState') {
          Get.off(() => EmptyState());
        }
      }
    } catch (e) {
      Get.snackbar(
        'Failed',
        'Logout failed: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      print("User logout failed: $e");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await PrefData.setLogin(false);
      await Future.delayed(Duration(seconds: 2)); // Delay for snackbar visibility
      if (Get.currentRoute != '/EmptyState') {
        Get.off(() => EmptyState());
      }
    } finally {
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
                      Image(
                        image: AssetImage(widget.user_detail.image!), height: 100.h,
                        width: 100.w,

                        //fit: BoxFit.cover,
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

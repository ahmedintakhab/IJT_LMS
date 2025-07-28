import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/controller.dart';
import '../models/new_user_detail.dart';
import '../utils/screen_size.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({Key? key, required this.user}) : super(key: key);
  final User user;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  EditScreenController editScreenController = Get.put(EditScreenController());

  @override
  Widget build(BuildContext context) {
    initializeScreenSize(context);
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: GetBuilder(
              init: EditScreenController(),
              builder: (editScreenController) => SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.w, right: 20.w),
                      child: Column(
                        children: [
                          SizedBox(height: 20.h),
                          Row(
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    Get.back();
                                  },
                                  child: const Icon(Icons.arrow_back_ios)),
                              SizedBox(width: 16.w),
                              Text(
                                "Edit Profile",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24.sp,
                                    fontFamily: 'Gilroy'),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          Expanded(
                            child: ListView(
                              children: [
                                Image(
                                  image: AssetImage(widget.user.image!),
                                  height: 100.h,
                                  width: 100.h,

                                ),
                                SizedBox(height: 30.h),
                                name_email_phone("assets/profileicon1st.png",
                                    widget.user.name),
                                SizedBox(height: 20.h),
                                name_email_phone("assets/profileicon2nd.png",
                                    widget.user.email),
                                SizedBox(height: 20.h),
                                name_email_phone("assets/profileicon3rd.png",
                                    widget.user.phoneNo),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 40.h),
                            child: save_button(),
                          )
                        ],
                      ),
                    ),
                  ))),
    );
  }

  name_email_phone(String i, var v) {
    return Container(
      height: 60.h,
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.h),
          boxShadow: [
            BoxShadow(
                color: const Color(0XFF00AFEE).withOpacity(0.14),
                offset: const Offset(-4, 5),
                blurRadius: 16),
          ],
          color: Colors.white),
      child: Padding(
        padding: EdgeInsets.all(8.0.h),
        child: TextFormField(
          initialValue: v,
          decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.only(left: 18.w, top: 18.h, bottom: 18.h),
              prefixIcon: Padding(
                padding: EdgeInsets.all(7.0.h),
                child: Container(
                  //color: Colors.red,
                  height: 24.h,
                  width: 24.h,
                  child: Image(
                    image: AssetImage(i),
                  ),
                ),
              ),
              border: InputBorder.none),
          style: TextStyle(
              fontSize: 15.sp,
              color: Color(0XFF6E758A),
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  save_button() {
    return GestureDetector(
      onTap: () {
       Get.back();
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 40.h, top: 15.h),
        child: Container(
          height: 56.h,
          width: 374.w,
          //color: Color(0XFF00AFEE),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.h),
            color: const Color(0XFF00AFEE),
          ),
          child: Center(
            child: Text("Save",
                style: TextStyle(
                    color: Color(0XFFFFFFFF),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Gilroy')),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/controller/controller.dart';
import '../utils/screen_size.dart';
import 'completed_screen.dart';
import 'ongoing_screen.dart';

class OngoingCompletedScreen extends StatefulWidget {
  const OngoingCompletedScreen({Key? key}) : super(key: key);

  @override
  State<OngoingCompletedScreen> createState() => _OngoingCompletedScreenState();
}

class _OngoingCompletedScreenState extends State<OngoingCompletedScreen> {
  OngoingCompletedController ongoingCompletedController =
  Get.put(OngoingCompletedController());
  PageController pageController = PageController();
  List courcesClass = [const OngoingScreen(), const CompletedScreen()];
  int initialValue = 1;

  @override
  Widget build(BuildContext context) {
    initializeScreenSize(context);
    return Scaffold(
      body: WillPopScope(
        onWillPop: () {
          return Future.value(false);
        },
        child: GetBuilder<OngoingCompletedController>(
          init: OngoingCompletedController(),
          builder: (controller) => Column(
            children: [
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                      },
                      child: Image(
                        image: const AssetImage("assets/back_arrow.png"),
                        height: 24.h,
                        width: 24.w,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      "My Courses",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Container(
                  height: 54.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00AFEE).withOpacity(0.14),
                        offset: const Offset(-4, 5),
                        blurRadius: 16.h,
                      ),
                    ],
                    color: Colors.white,
                     borderRadius: BorderRadius.circular(6.h),
                  ),
                  child:  TabBar(
                      controller: ongoingCompletedController.tabController,
                      labelColor: Colors.white, // Selected tab text color
                      unselectedLabelColor: Colors.black, // Unselected tab text color
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                        fontFamily: 'Gilroy',
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                        fontFamily: 'Gilroy',
                      ),
                      indicator: BoxDecoration(
                        color: const Color(0xFF00AFEE), // Selected tab background color
                         borderRadius: BorderRadius.circular(6.h),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab, // Makes the indicator span the tab
                      dividerColor: Colors.transparent, // Removes any divider line
                      tabs: [
                        Tab(
                          child: Container(
                            width: double.infinity, // Ensures equal width for both tabs
                            alignment: Alignment.center,
                            child: const Text("Ongoing"),
                          ),
                        ),
                        Tab(
                          child: Container(
                            width: double.infinity, // Ensures equal width for both tabs
                            alignment: Alignment.center,
                            child: const Text("Completed"),
                          ),
                        ),
                      ],
                      onTap: (value) {
                        ongoingCompletedController.pController.animateToPage(
                          value,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      },
                    ),

                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: PageView.builder(
                  controller: ongoingCompletedController.pController,
                  onPageChanged: (value) {
                    ongoingCompletedController.tabController.animateTo(
                      value,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                  itemCount: courcesClass.length,
                  itemBuilder: (context, index) {
                    return courcesClass[index];
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/controller/controller.dart';
import 'package:learn_megnagmet/cources/lessons_screen.dart';
import 'package:learn_megnagmet/cources/overview_page.dart';
import 'package:learn_megnagmet/cources/review_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

import '../utils/screen_size.dart';
import '../widget/button.dart';
import 'choose_plane_screen.dart';

class MyCources extends StatefulWidget {
  // final Map<String, dynamic> trende;
  final String slug;  // Add this parameter

  const MyCources({Key? key,required this.slug,
  }) : super(key: key);
  // final Trending trende;


  @override
  State<MyCources> createState() => _MyCourcesState();
}

class _MyCourcesState extends State<MyCources> {
  CourceController courceController = Get.put(CourceController());
  PageController pageController = PageController();
  int initialvalue = 0;



  late FlickManager flickManager;
  bool currentbuttonpos = false;
  List pageclass = [
    Overview(),
    Lesson(),
    Review(),
  ];


  @override
  void initState() {

    super.initState();
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(
          "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"),
      autoPlay: false,

    );
  }

  @override
  void dispose() {
    flickManager.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initializeScreenSize(context);
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        body: GetBuilder<CourceController>(
          init: CourceController(),
          builder: (CourceController) => SafeArea(
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 SizedBox(height: 20.h),
                Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child:  Image(
                            image: const AssetImage("assets/back_arrow.png"),
                            height: 24.h,
                            width: 24.w,
                          )),
                       SizedBox(width: 15.w),
                       Text(
                        "Courses",
                        style: TextStyle(fontFamily: 'Gilroy',fontWeight: FontWeight.w700, fontSize: 24.sp),
                      ),
                    ],
                  ),
                ),
                 SizedBox(height: 20.h),
                Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 15.w),
                  child: Container(
                    padding: EdgeInsets.all(12.h),

                    decoration: BoxDecoration(
                      color:Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0XFF00AFEE).withOpacity(0.1),
                            blurRadius: 16,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(22.h),
                        ),
                    child: Container(
                      height: 195.h,

                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22.h)),
                        child: ClipRRect(borderRadius: BorderRadius.circular(22),child: FlickVideoPlayer(flickManager: flickManager))),
                  ),
                ),
                 SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Container(
                    height: 54.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00AFEE).withOpacity(0.20),
                          blurRadius: 16,
                        ),
                      ],
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(6.h),
                    ),
                    child: TabBar(
                      controller: courceController.tabController,
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
                            width: double.infinity, // Ensures equal width for all tabs (one-third each)
                            alignment: Alignment.center,
                            child: const Text("Overview"),
                          ),
                        ),
                        Tab(
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: const Text("Lessons"),
                          ),
                        ),
                        Tab(
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: const Text("Reviews"),
                          ),
                        ),
                      ],
                      onTap: (value) {
                        courceController.pController.animateToPage(
                          value,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                Expanded(
                  child: PageView.builder(
                    controller: courceController.pController,
                    onPageChanged: (value) {
                      courceController.tabController.animateTo(value,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease);
                    },
                    itemCount: pageclass.length,
                    itemBuilder: (context, index) {
                      return pageclass[index];
                    },
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.only(bottom: 30.h),
                  child: CustomButton(
                    onTap: () {
                      Get.to(const ChoosePlane());
                    },
                    buttonText: 'Enroll Now',
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

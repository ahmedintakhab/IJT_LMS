import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/controller/controller.dart';

class TabbarSection extends StatelessWidget {
  final CourceController courceController;
  final List<Widget> pageclass;

  const TabbarSection({
    Key? key,
    required this.courceController,
    required this.pageclass,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
                fontFamily: 'Gilroy',
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
                fontFamily: 'Gilroy',
              ),
              indicator: BoxDecoration(
                color: const Color(0xFF00AFEE),
                borderRadius: BorderRadius.circular(6.h),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: "Overview"),
                Tab(text: "Curriculum"),
                Tab(text: "Reviews"),
                Tab(text: "Instructors"),
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
                curve: Curves.ease,
              );
            },
            itemCount: pageclass.length,
            itemBuilder: (context, index) => pageclass[index],
          ),
        ),
      ],
    );
  }
}
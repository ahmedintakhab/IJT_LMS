import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/home/search_screen_widget.dart' hide HorizontalDesignList;
import 'search_screen_controller.dart';

class SearchScreen extends StatefulWidget {
  final String slug;

  const SearchScreen({Key? key, required this.slug,}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchScreenController searchScreenController = Get.put(SearchScreenController());

  @override
  void initState() {
    super.initState();
    searchScreenController.fetchCategoriesAndSubcategories();
    searchScreenController.searchCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<SearchScreenController>(
        init: SearchScreenController(),
        builder: (controller) => SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Image(
                    image: const AssetImage("assets/back_arrow.png"),
                    height: 24.h,
                    width: 24.w,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  shrinkWrap: true,
                  children: [
                    SearchTextField(controller: controller),
                    SizedBox(height: 20.h),
                    const Text(
                      "Categories",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20.h),
                    HorizontalDesign(controller: controller),
                    SizedBox(height: 20.h),
                    const Text(
                      "Courses",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20.h),
                    TrendingCourses(controller: searchScreenController),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

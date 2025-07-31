import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cources/cources.dart';
import '../utils/api_constant.dart';
import '../utils/cache_api_service.dart';
import 'category_wise_courses.dart';
import 'filter_sheet.dart';
import 'search_screen_controller.dart';

class SearchTextField extends StatelessWidget {
  final SearchScreenController controller;

  const SearchTextField({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      child: TextFormField(
        controller: controller.searchController,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0XFF00AFEE), width: 1.w),
            borderRadius: BorderRadius.circular(22.h),
          ),
          hintText: 'Search',
          hintStyle: TextStyle(
            color: const Color(0XFF9B9B9B),
            fontSize: 15.sp,
            fontFamily: 'Gilroy',
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Image.asset('assets/search.png', height: 24.h, width: 24.w),
          suffixIcon: GestureDetector(
            onTap: () {
              final query = controller.searchController.text.trim();
              showModalBottomSheet(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22.h),
                ),
                context: context,
                builder: (context) => FilterSheet(
                  query: query,
                  categoryData: controller.categoryData,
                  subcategoriesData: controller.subcategoriesData,
                  onFilterApplied: (filteredCourses) {
                    controller.courseSuggestions = List<Map<String, dynamic>>.from(filteredCourses);
                    controller.courseResult = controller.courseSuggestions;
                    controller.update();
                    controller.searchController.clear();
                  },
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 5.h,
                width: 5.w,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/filtericon.png"),
                    colorFilter: ColorFilter.mode(
                      Color(0XFF00AFEE),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(22.h)),
        ),
      ),
    );
  }
}

class HorizontalDesign extends StatelessWidget {
  final SearchScreenController controller;

  const HorizontalDesign({Key? key, required this.controller}) : super(key: key);

  Future<List<dynamic>> fetchCategories() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = '${ApiConstant.baseUrl}category-list';

      final jsonData = await fetchDataWithCache(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (jsonData['success'] == true) {
        return jsonData['data']['data'] as List<dynamic>;
      } else {
        throw Exception('API returned success: false - ${jsonData['message']}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140.h,
      width: double.infinity,
      child: FutureBuilder<List<dynamic>>(
        future: fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No categories found'));
          }

          final categories = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            shrinkWrap: true,
            primary: false,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (BuildContext context, index) {
              final category = categories[index];
              final name = category['name']?.toString() ?? 'Unknown';
              final slug = category['slug']?.toString() ?? '';
              final imageUrl = category['image_url']?.toString() ??
                  'https://tarbiah.online/uploads/default/no-image-found.png';

              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 0.w : 12.w),
                child: GestureDetector(
                  onTap: () {
                    Get.to(() =>CategoryWiseCourses(slug: slug, categoryName: name));
                  },
                  child: Container(
                    width: 110.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: NetworkImage(imageUrl),
                          height: 70.h,
                          width: 70.w,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 70.h,
                              width: 70.w,
                              color: Colors.grey,
                              child: const Center(child: Text('Image not found')),
                            );
                          },
                        ),
                        SizedBox(height: 8.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              name,
                              style: TextStyle(
                                color: const Color(0xFF000000),
                                fontSize: 14.sp,
                                fontFamily: 'Gilroy',
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
class TrendingCourses extends StatelessWidget {
  final SearchScreenController controller;

  const TrendingCourses({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller.courseResult.isEmpty) {
      return FutureBuilder(
        future: Future.delayed(Duration(seconds: 5)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00AFEE),
              ),
            );
          } else {
            return Center(
              child: Text(
                'No Result found',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }
        },
      );
    }
    return SizedBox(
      height: 260.h,
      width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.courseResult.length,
        itemBuilder: (BuildContext context, int index) {
          final courses = controller.courseResult[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: GestureDetector(
              onTap: () {
                final slug = courses['course_slug'];
                if (slug != null) {
                  Get.to(() => MyCources(slug: slug));
                } else {
                  print("Slug is null");
                }
              },
              child: Container(
                height:200.h,
                width: 275.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.h),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0XFF23408F).withOpacity(0.14),
                      offset: const Offset(-4, 5),
                      blurRadius: 16.h,
                    ),
                  ],
                  color: const Color(0XFFFFFFFF),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 200.h,
                      width: 275.w,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(courses['course_image'].toString()),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(12.h),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 6.w, ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 6.h),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              courses['course_title'].toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Nastaleeq',
                                color: const Color(0XFF000000),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


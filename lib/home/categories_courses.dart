import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:learn_megnagmet/home/category_wise_courses.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_constant.dart';

class HorizontalDesignList extends StatelessWidget {
  const HorizontalDesignList({Key? key}) : super(key: key);

  Future<List<dynamic>> fetchCategories() async {
    final url = Uri.parse('${ApiConstant.baseUrl}category-list');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          return jsonData['data']['data'] as List<dynamic>;
        } else {
          throw Exception('API returned success: false - ${jsonData['message']}');
        }
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
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
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_constant.dart';

class SearchScreenController extends GetxController {
  TextEditingController searchController = TextEditingController();
  Timer? debounce;
  List<Map<String, dynamic>> courseSuggestions = [];
  List<String> selectedCategory = [];
  Map<String, dynamic>? searchData;
  List<Map<String, dynamic>> categorywithimages = [];
  List<Map<String, dynamic>> categoryData = [];
  Map<String, List<dynamic>> subcategoriesData = {};
  List<Map<String, dynamic>> courseResult = [];
  String lastQuery = "";
  bool noResultsFound = false;
  bool isLoading = false;
  String errorMessage = '';

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      final query = searchController.text.trim();
      print('Check the query: $query');
      if (query != lastQuery) {
        onSearchTextChanged(query);
      }
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    debounce?.cancel();
    super.onClose();
  }

  Future<void> searchCourses({String query = ""}) async {
    isLoading = true;
    noResultsFound = false;
    update();
    print('Check query before API call: $query');

    String url = '${ApiConstant.baseUrl}search-course-list';
    try {
      // Retrieve token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final response = await http.post(
        Uri.parse(url),
        body: query.isNotEmpty ? json.encode({'keyword': query}) : null,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add token if required
        },
      );

      if (response.statusCode == 200) {
        print('Check the search text API response: ${response.statusCode}');
        final data = json.decode(response.body);
        print('Full API Data: ${json.encode(data)}'); // Log full response

        // Access the 'data' object first, then 'course_results'
        final responseData = data['data'] ?? {};

        if (responseData['course_results'] == null) {
          print('Warning: course_results key is missing in API response');
        }

        courseResult = List<Map<String, dynamic>>.from(responseData['course_results'] ?? []);
        courseSuggestions = courseResult; // Single assignment
        categorywithimages = List<Map<String, dynamic>>.from(responseData['categories_with_images'] ?? []);
        noResultsFound = courseResult.isEmpty && query.isNotEmpty;

        print('Course Result: $courseResult');
        print('No Results Found: $noResultsFound');
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        errorMessage = 'Failed to load courses: ${response.statusCode}';
      }
    } catch (error) {
      print('API Error: $error');
      errorMessage = 'Error fetching courses: $error';
    } finally {
      isLoading = false;
      update();
    }
  }  void onSearchTextChanged(String query) {
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      lastQuery = query;
      if (query.isNotEmpty) {
        searchCourses(query: query);
      } else {
        isLoading = false;
        courseSuggestions.clear();
        noResultsFound = false;
        searchCourses();
        update();
      }
    });
  }

  Future<void> fetchCategoriesAndSubcategories() async {
    isLoading = true;
    errorMessage = '';
    update();

    try {

      final response = await http.get(
        Uri.parse('${ApiConstant.baseUrl}frontend/all-categories-with-subcategories'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        categoryData = data
            .where((category) => category['category_name'] != null)
            .map((category) {
          final Map<String, dynamic> categoryMap = {
            'category_id': category['category_id'],
            'category_name': category['category_name'],
            'has_subcategories': false,
          };

          if (category['category_subcategories'] != null &&
              (category['category_subcategories'] as List).isNotEmpty) {
            categoryMap['has_subcategories'] = true;
            subcategoriesData[category['category_id'].toString()] =
            List<dynamic>.from(category['category_subcategories']);
          }

          return categoryMap;
        }).toList();
      } else {
        errorMessage = 'Failed to load categories';
      }
    } catch (e, stackTrace) {
      print('Error fetching data: $e');
      print('Stack trace: $stackTrace');
      errorMessage = 'Error: $e';
    } finally {
      isLoading = false;
      update();
    }
  }
  // New method to fetch category-wise courses
  Future<void> fetchCategoryWiseCourses(int categoryId) async {
    isLoading = true;
    errorMessage = '';
    update();

    String url = '${ApiConstant.baseUrl}frontend/all-categorywise-courses';
    try {
      // Retrieve the token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authtoken') ?? '';

      final response = await http.post(
        Uri.parse(url),
        body: json.encode({'category_id': categoryId}),
        headers: {
          'Authorization': 'Bearer $token', // Pass the token as a Bearer token
          'Content-Type': 'application/json', // Optional: Set content type
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: $data'); // Debug print
        courseResult = List<Map<String, dynamic>>.from(data['category_courses_section_data'] ?? []);
        print('Course Result: $courseResult'); // Debug print
        update();
      } else {
        errorMessage = 'Failed to load category-wise courses';
        print("Error: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print('Error fetching category-wise courses: $e');
      print('Stack trace: $stackTrace');
      errorMessage = 'Error: $e';
    } finally {
      isLoading = false;
      update();
    }
  }

}


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../cources/delete_recommendation_course_dialogbox.dart';
import '../utils/api_constant.dart'; // Assuming this contains the baseUrl

class RecommendedCoursesList extends StatefulWidget {
  RecommendedCoursesList({super.key});

  @override
  State<RecommendedCoursesList> createState() => _RecommendedCoursesListState();
}

class _RecommendedCoursesListState extends State<RecommendedCoursesList> {
  List<Map<String, String>>? _coursesData; // Variable to store API data
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourseRecommendations();
  }

  Future<void> _fetchCourseRecommendations() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = Uri.parse("${ApiConstant.baseUrl}course-recommendation-list");

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _coursesData = (data['data'] as List).map((item) => {
              'sr_no': item['sr_no'].toString(),
              'id': item['id'].toString(),
              'course_name': item['course_name'].toString(),
              'email': item['email'].toString(),
              'status': item['status'].toString(),
              'is_delete': item['is_delete'].toString(),
            }).toList();
          });
        }
      } else {
        print('Failed to fetch course recommendations: ${response.body}');
      }
    } catch (e) {
      print('Error fetching course recommendations: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Recommendation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0XFF00AFEE),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00AFEE)))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: _coursesData == null || _coursesData!.isEmpty
                  ? const Center(child: Text('Recommended courses not available'))
                  : ListView.builder(
                itemCount: _coursesData!.length,
                itemBuilder: (context, index) {
                  final course = _coursesData![index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        _buildRow('No.', course['sr_no']!),
                        _buildRow('Course Name', course['course_name']!),
                        _buildRow('Sent Email', course['email']!),
                        _buildRow('Status', course['status']!,
                            statusColor: course['status'] == 'Pending' ? Colors.orange : Colors.green),
                        _buildRow('Action', '',
                            actionWidget: course['is_delete'] == '1'
                                ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.grey),
                              onPressed: () {
                                Get.dialog(
                                  DeleteRecommendationCourseDialogbox(
                                    onDelete: () async {
                                      await _fetchCourseRecommendations();
                                      if (mounted) {
                                        Get.snackbar(
                                          'Success',
                                          'Recommended course deleted successfully',
                                          snackPosition: SnackPosition.TOP,
                                          backgroundColor: Colors.green,
                                          colorText: Colors.white,
                                        );
                                      }
                                    },
                                    onCancel: () => Navigator.pop(context),
                                    recommendedCourseId: int.parse(course['id']!),
                                  ),
                                );
                              },
                            )
                                : null),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? statusColor, Widget? actionWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (statusColor != null && actionWidget == null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: statusColor.withOpacity(0.2),
              child: Text(
                value,
                style: TextStyle(color: statusColor),
              ),
            )
          else if (actionWidget != null)
            actionWidget
          else
            Text(value),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:learn_megnagmet/instructor/create_live_class.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_constant.dart';

class PastLiveScreen extends StatefulWidget {
  final List<Map<String, dynamic>> classes;
  final String courseuuid;

  const PastLiveScreen({super.key, required this.classes, required this.courseuuid});

  @override
  State<PastLiveScreen> createState() => _PastLiveScreenState();
}

class _PastLiveScreenState extends State<PastLiveScreen> {
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Missed':
        return Colors.red;
      case 'Pending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  Future<void> deleteLiveClass(String classuuid, int index) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('auth_token') ?? '';

      final response = await http.delete(
        Uri.parse('${ApiConstant.baseUrl}instructor/live-class/$classuuid/delete'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Delete live class api response: ${response.statusCode}');
        setState(() {
          widget.classes.removeAt(index); // Remove the class from the list
        });
        Get.snackbar('Successful', 'live class deleted successful',
            snackPosition: SnackPosition.TOP);

      } else {
        throw Exception('Failed to delete class: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting class: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting class: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      child: Column(
        children: [
          Expanded(
            child: widget.classes.isEmpty
                ? const Center(child: Text('No past live classes available'))
                : ListView.builder(
              itemCount: widget.classes.length,
              itemBuilder: (context, index) {
                final classData = widget.classes[index];
                final classuuid = classData['uuid'] ?? '';

                return Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Titles Column with fixed width
                          SizedBox(
                            width: 120.w, // Fixed width for titles
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 30.h,
                                  child: const Text(
                                    'Topic',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  height: 30.h,
                                  child: const Text(
                                    'Date & Time',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  height: 30.h,
                                  child: const Text(
                                    'Time Duration',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  height: 30.h,
                                  child: const Text(
                                    'Learning Tool',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  height: 30.h,
                                  child: const Text(
                                    'Status',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(height: 10.h,),
                                SizedBox(
                                  height: 40.h,
                                  child: const Text(
                                    'Action',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 50.w,),
                          // Information Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 30.h,
                                  child: Text(
                                    classData['class_topic']?.toString() ?? '',
                                    style: const TextStyle(color: Colors.black),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  height: 30.h,
                                  child: Text(
                                    '${classData['date']} ${classData['time']}',
                                  ),
                                ),
                                SizedBox(
                                  height: 30.h,
                                  child: Text('${classData['duration']} minutes'),
                                ),
                                SizedBox(
                                  height: 30.h,
                                  child: Text(
                                    classData['meeting_host_name']?.toString() ?? '',
                                  ),
                                ),
                                SizedBox(
                                  height: 30.h,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(classData['status']?.toString() ?? '').withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      classData['status']?.toString() ?? '',
                                      style: TextStyle(
                                        color: _getStatusColor(classData['status']?.toString() ?? ''),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 17.sp,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.h,),
                                SizedBox(
                                  height: 40.h,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (classuuid.isNotEmpty) {
                                        deleteLiveClass(classuuid, index);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Icon(Icons.delete, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CustomButton(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  buttonText: 'Back',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateLiveClass(courseuuid: widget.courseuuid),
                      ),
                    );
                  },
                  buttonText: 'Add Live Class',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

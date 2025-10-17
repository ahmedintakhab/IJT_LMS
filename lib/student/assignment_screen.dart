import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../assignment/assignment_details.dart';
import '../assignment/assignment_result.dart';
import '../utils/api_constant.dart';

class AssignmentPage extends StatefulWidget {
  final List<dynamic> assignmentData;
  final String courseId;


  const AssignmentPage({Key? key, required this.assignmentData,
    required this.courseId}) : super(key: key);

  @override
  _AssignmentPageState createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  bool _isLoadingDetails = false;
  bool _isLoadingResult = false;
  String? _currentDetailsAssignmentId;
  String? _currentResultAssignmentId;

  Future<Map<String, dynamic>> fetchAssignmentDetails(String assignmentId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('authToken') ?? '';

    final url = Uri.parse("${ApiConstant.baseUrl}student/course/assignment-detail");
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'assignment_id': assignmentId}),
    );

    if (response.statusCode == 200) {
      print('Check the assignment details api response: ${response.statusCode}');
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load assignment details: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchAssignmentResult(String assignmentId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('authToken') ?? '';

    final url = Uri.parse("${ApiConstant.baseUrl}student/course/assignment-result");
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'assignment_id': assignmentId}),
    );

    if (response.statusCode == 200) {
      print('Check the assignment result api response: ${response.statusCode}');
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load assignment result: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Check course id in assignment screen: ${widget.courseId}');
    print('Check assignment data from tab${widget.assignmentData}');

    return ListView.builder(
      itemCount: widget.assignmentData.length,
      itemBuilder: (context, index) {
        final assignment = widget.assignmentData[index];
        final assignmentId = assignment['assignment_id']?.toString() ?? '';
        print('Check the assignment id: $assignmentId');
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Assignment Topic',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(assignment['assignment_topic'] ?? 'N/A'),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Marks',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${assignment['assignment_total_marks'] ?? 'N/A'}'),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(

                    child: SizedBox(
                      height: 50.h, // Set height for View Details button
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomButton(
                            onTap: (_isLoadingDetails && _currentDetailsAssignmentId == assignmentId)
                                ? () {} // Disable button during loading
                                : () async {
                              setState(() {
                                _isLoadingDetails = true;
                                _currentDetailsAssignmentId = assignmentId;
                              });
                              try {
                                print('Starting API call for assignmentId: $assignmentId');
                                final assignmentDetails = await fetchAssignmentDetails(assignmentId);
                                print('API call completed');
                                if (mounted) {
                                  setState(() {
                                    _isLoadingDetails = false;
                                    _currentDetailsAssignmentId = null;
                                  });
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AssignmentDetails(
                                        assignmentDetails: assignmentDetails,courseId: widget.courseId,
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  setState(() {
                                    _isLoadingDetails = false;
                                    _currentDetailsAssignmentId = null;
                                  });
                                  Get.snackbar(
                                    'Error',
                                    'Failed to fetch details',
                                    snackPosition: SnackPosition.TOP,
                                  );
                                  print('Error fetching details: $e');
                                }
                              }
                            },
                            buttonText: (_isLoadingDetails && _currentDetailsAssignmentId == assignmentId)
                                ? '' // Hide text during loading
                                : 'View Detail',
                            buttonColor: const Color(0xFF00AFEE),
                            textColor: Colors.white,
                          ),
                          if (_isLoadingDetails && _currentDetailsAssignmentId == assignmentId)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.0,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 18.0),
                  Expanded(
                    child: SizedBox(
                      height: 50.h, // Set height for See Result button
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomButton(
                            onTap: (_isLoadingResult && _currentResultAssignmentId == assignmentId)
                                ? () {} // Disable button during loading
                                : () async {
                              setState(() {
                                _isLoadingResult = true;
                                _currentResultAssignmentId = assignmentId;
                              });
                              try {
                                print('Starting API call for assignment result: $assignmentId');
                                final assignmentResult = await fetchAssignmentResult(assignmentId);
                                print('API call completed');
                                if (mounted) {
                                  setState(() {
                                    _isLoadingResult = false;
                                    _currentResultAssignmentId = null;
                                  });
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AssignmentResult(
                                        assignmentResult: assignmentResult,
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  setState(() {
                                    _isLoadingResult = false;
                                    _currentResultAssignmentId = null;
                                  });
                                  Get.snackbar(
                                    'Error',
                                    'Failed to fetch result',
                                    snackPosition: SnackPosition.TOP,
                                  );
                                  print('Error fetching result: $e');
                                }
                              }
                            },
                            buttonText: (_isLoadingResult && _currentResultAssignmentId == assignmentId)
                                ? '' // Hide text during loading
                                : 'See Result',
                          ),
                          if (_isLoadingResult && _currentResultAssignmentId == assignmentId)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.0,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
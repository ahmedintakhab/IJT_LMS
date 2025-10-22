import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:learn_megnagmet/create_assignment/assignment_tabbar_widget.dart';
import 'package:learn_megnagmet/create_assignment/delete_assignment_dialogbox.dart';
import 'package:learn_megnagmet/create_assignment/edit_assignment_form.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constant.dart';
import '../widget/button.dart';

class CreatedAssignmentListWidget extends StatefulWidget {
  final String courseId;
  const CreatedAssignmentListWidget({Key? key, required this.courseId}) : super(key: key);

  @override
  State<CreatedAssignmentListWidget> createState() => _CreatedAssignmentListWidgetState();
}

class _CreatedAssignmentListWidgetState extends State<CreatedAssignmentListWidget> {
  final Map<int, bool> _isLoadingAction = {};
  final Map<int, bool> _isLoadingLeaderboard = {};

  List<dynamic> assignmentData = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchassignmentList();
  }

  Future<void> _fetchassignmentList() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final String apiUrl =
          "${ApiConstant.baseUrl}instructor/course/assignment/${widget.courseId}";

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Assignment list fetched successfully: ${response.body}');
        setState(() {
          assignmentData = data["assignments_list"] ?? [];
        });
      } else {
        print('Failed to fetch quiz list: ${response.body}');
      }
    } catch (e) {
      print('Error fetching quiz list: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00AFEE)));
    }

    if (assignmentData.isEmpty) {
      return const Center(child: Text("No assignments available."));
    }

    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: assignmentData.length,
          itemBuilder: (context, index) {
            final assignment = assignmentData[index];
            _isLoadingAction.putIfAbsent(index, () => false);
            _isLoadingLeaderboard.putIfAbsent(index, () => false);
            final assignmentUuid = assignment['uuid']?.toString() ?? '';
            final assignmentId = assignment['id'] ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Assignment Name', assignment['name']),
                  SizedBox(height: 10.h),

                  _buildInfoRow('Total Marks', assignment['marks']),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 250.w,height: 55.h,
                        child: CustomButton(
                          onTap: () {
                            Get.to(() => AssignmentTabWidget(assignmentId : assignmentId));

                            },
                          buttonText: 'Click Here',
                          buttonColor: Colors.blue[100]!,
                          textColor: Colors.blue,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_horiz, color: Colors.grey[600]),
                        onSelected: (String value) async {
                          switch (value) {
                            case 'edit':
                              await Get.to(() => EditAssignmentForm(
                                assignmentId: int.parse(assignmentId.toString()),
                              ));
                              _fetchassignmentList();
                              break;
                            case 'delete':
                            // ✅ FIXED: Proper Dialog Implementation
                              Get.dialog(
                                DeleteAssignmentDialogbox(
                                  onDelete: () async {
                                    await _fetchassignmentList(); // Refresh data from API
                                    if (mounted) {
                                      Get.snackbar(
                                        'Success',
                                        'Assignment deleted successfully',
                                        snackPosition: SnackPosition.TOP,
                                        backgroundColor: Colors.green,
                                        colorText: Colors.white,
                                      );
                                    }
                                  },
                                  onCancel: () => Navigator.pop(context),
                                  assignmentId: int.parse(assignmentId.toString()), // Pass assignment id
                                ),
                              );
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style:  TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600])),
        value is Widget ? value : Text(
          value?.toString() ?? '',
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
      ],
    );
  }

}
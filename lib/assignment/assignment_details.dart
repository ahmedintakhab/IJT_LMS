import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:learn_megnagmet/assignment/upload_assignment.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignmentDetails extends StatelessWidget {
  final Map<String, dynamic> assignmentDetails;
  final String courseId;

  const AssignmentDetails({Key? key, required this.assignmentDetails,
    required this.courseId}) : super(key: key);

  // Function to launch URL for downloading PDF
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract data from assignmentDetails
    final String assignmentFileUrl = assignmentDetails['assignment_file'] ?? '';
    final String submittedFileUrl = assignmentDetails['your_submitted_file'] ?? '';
    final String assignmentId = assignmentDetails['assignment_id']?.toString() ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Details'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Color(0xFF78A03F),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assignment Topic',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              assignmentDetails['assignment_topic'] ?? 'N/A',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              'Assignment Description',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              assignmentDetails['assignment_description'] ?? 'N/A',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Marks',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        assignmentDetails['marks']?.toString() ?? '0',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assignment File',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            if (assignmentFileUrl.isNotEmpty) {
                              try {
                                await _launchUrl(assignmentFileUrl);
                              } catch (e) {
                                print('Error opening file: $e');
                                Get.snackbar('Error', 'Error opening file',
                                    snackPosition: SnackPosition.TOP);
                              }
                            } else {
                              Get.snackbar('Not Find', 'No submitted file available',
                                  snackPosition: SnackPosition.TOP);
                            }
                          },
                          child: Text(
                            assignmentDetails['assignment_file_name'] ?? 'N/A',
                            style: const TextStyle(fontSize: 16, color: Colors.blue,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.blue,
                              decorationThickness: 2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Submit File',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            if (submittedFileUrl.isNotEmpty) {
                              try {
                                await _launchUrl(submittedFileUrl);
                              } catch (e) {
                                print('Error opening file: $e');
                                Get.snackbar('Error', 'Error opening file',
                                    snackPosition: SnackPosition.TOP);

                              }
                            } else {
                              Get.snackbar('Not Find', 'No submitted file available',
                                  snackPosition: SnackPosition.TOP);

                            }
                          },
                          child: Text(
                            assignmentDetails['your_submitted_file_name'] ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.blue,
                              decorationThickness: 2,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 120.w,
                  height: 55.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text(
                      'Back',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  width: 230.w,
                  height: 55.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            UploadAssignment(courseId: courseId,assignmentId : assignmentId)),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF78A03F)),
                    child: const Text(
                      'SUBMIT ASSIGNMENT',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:learn_megnagmet/widget/button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'instructor_dropdown.dart';
import '../utils/api_constant.dart';

class InstructorsScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback? onBack;

  const InstructorsScreen({super.key, required this.onComplete, this.onBack});

  @override
  State<InstructorsScreen> createState() => _InstructorsScreenState();
}

class _InstructorsScreenState extends State<InstructorsScreen> {
  List<Map<String, dynamic>> selectedInstructors = [];
  int? courseId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCourseId();
  }

  Future<void> _fetchCourseId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      courseId = prefs.getInt('courseId');
      print('Fetched courseId: $courseId');
    });
    if (courseId != null) {
      await _fetchSelectedInstructors();
    }
  }

  Future<void> _fetchSelectedInstructors() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = Uri.parse('${ApiConstant.baseUrl}instructor/course/step-three-edit-data/$courseId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('GET API Response Status: ${response.statusCode}');
      print('GET API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
          List<dynamic> instructors = jsonResponse['data'][0]['instructors'];
          setState(() {
            selectedInstructors = instructors.map<Map<String, dynamic>>((i) => {
              'id': i['id'],
              'name': i['name'],
            }).toList();
            print('Loaded selectedInstructors: $selectedInstructors');
          });
        } else {
          print('No instructors found or API returned unsuccessful: ${jsonResponse['message']}');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load instructors: HTTP ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error fetching instructors: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching instructors')),
      );
    }
  }

  Future<void> _submitInstructors() async {
    print('Selected Instructors: $selectedInstructors');
    if (courseId == null || selectedInstructors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one instructor')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = Uri.parse('${ApiConstant.baseUrl}instructor/course/update-instructors');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'course_id': courseId,
          'instructor_id': selectedInstructors.map((i) => i['id']).toList(),
        }),
      );

      print('POST API Response Status: ${response.statusCode}');
      print('POST API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          Get.snackbar(
            'Successful',
            'Instructors assigned successfully!',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          widget.onComplete();
        } else {
          print('Failed to update instructors: ${jsonResponse['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update instructors: ${jsonResponse['message']}')),
          );
        }
      } else {
        print('Failed to update instructors: HTTP ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update instructors: HTTP ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error updating instructors: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating instructors')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building UI with selectedInstructors: $selectedInstructors');
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Instructors',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add course instructors information',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDEDEDE), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedInstructors.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedInstructors.map((instructor) {
                        return Chip(
                          label: Text(instructor['name'] ?? 'Unknown'),
                          onDeleted: () {
                            setState(() {
                              selectedInstructors.remove(instructor);
                              print('Removed instructor: $instructor');
                              print('Updated selectedInstructors: $selectedInstructors');
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  InstructorDropdown(
                    hint: 'Select Instructors',
                    value: null,
                    onChanged: (value, id) {
                      if (value != null && id != null) {
                        print('Dropdown selected: name=$value, id=$id');
                        if (!selectedInstructors.any((i) => i['id'] == id)) {
                          setState(() {
                            selectedInstructors.add({'id': id, 'name': value});
                            print('Added instructor: {id: $id, name: $value}');
                            print('Current selectedInstructors: $selectedInstructors');
                          });
                        } else {
                          print('Instructor with id $id already selected');
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 100,
                    child: CustomButton(
                      onTap: () {
                        if (widget.onBack != null) {
                          widget.onBack!();
                        }
                      },
                      buttonText: 'Back',
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: CustomButton(
                      onTap: _submitInstructors,
                      buttonText: 'Save and Continue',
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learn_megnagmet/instructor/student_information_dialogbox.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/api_constant.dart';

class AllStudents extends StatefulWidget {
  const AllStudents({super.key});

  @override
  _AllStudentsState createState() => _AllStudentsState();
}

class _AllStudentsState extends State<AllStudents> {
  List<dynamic> students = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    String apiUrl = "${ApiConstant.baseUrl}instructor/all-enroll";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('authToken') ?? '';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('All students API response: ${response.statusCode}');
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          setState(() {
            students = data['data'];
            isLoading = false;
          });
        } else {
          throw Exception('Failed to load students');
        }
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching student: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching students: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Students',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFF00AFEE),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00AFEE)))
          : students.isEmpty
          ? const Center(child: Text('No students found'))
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120.0,
                    child: Text(
                      'Image',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: student['image'] != null
                          ? NetworkImage(student['image'])
                          : null,
                      child: student['image'] == null
                          ? const Icon(Icons.person, size: 20)
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120.0,
                    child: Text(
                      'Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(student['name']),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120.0,
                    child: Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(student['email']),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120.0,
                    child: Text(
                      'Course Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      student['course_title'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120.0,
                    child: Text(
                      'Enroll Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(student['enrolled_date']),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => StudentInformationDialog(student: student),
                    );
                  },
                  buttonText: 'View Details',
                ),
              ),
              ],
            ),
          ),
          );
        },
      ),
    );
  }
}
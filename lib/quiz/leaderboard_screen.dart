import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_constant.dart';
import 'all_student_leaderboard_container.dart';
import 'leaderboard_container.dart';

class LeaderboardScreen extends StatefulWidget {
  final String quizId;
  const LeaderboardScreen({Key? key, required this.quizId}) : super(key: key);

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  Map<String, dynamic>? leaderboardData;
  List<dynamic>? meritList;
  List<dynamic>? allLeaderboard;

  Future<Map<String, dynamic>> _fetchLeaderboardData(String quizId) async {
    const String apiUrl = '${ApiConstant.baseUrl}student/course/quiz-leaderboard';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'quiz_id': quizId}),
      );

      if (response.statusCode == 200) {
        print('Check the leaderboard api response: ${response.statusCode}');
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load leaderboard data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    print("Check the quiz id: ${widget.quizId}");
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await _fetchLeaderboardData(widget.quizId);
      setState(() {
        leaderboardData = data['student_leaderboard_section'];
        meritList = data['merit_list_leaderboard_section'];
        allLeaderboard = data['leaderboard_for_all'];
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Color(0xFF00AFEE),
          fontSize: 26.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: leaderboardData == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00AFEE),))
          : SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E90FF),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
                    ),
                    child: const Text(
                      'Your Position  Student Quiz Marks Your Marks Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8.0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          leaderboardData!['your_position'].toString(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20.r,
                              backgroundImage: NetworkImage(leaderboardData!['student_image']),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              leaderboardData!['student_name'],
                              style: TextStyle(fontSize: 16.sp, color: Colors.blue),
                            ),
                          ],
                        ),
                        Text(
                          leaderboardData!['quiz_total_marks'],
                          style: TextStyle(fontSize: 16.sp, color: Colors.blue),
                        ),
                        Text(
                          leaderboardData!['your_marks'],
                          style: TextStyle(fontSize: 16.sp, color: Colors.blue),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: leaderboardData!['status'] == 'Passed'
                                ? Colors.lightGreen[100]
                                : Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            leaderboardData!['status'],
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: leaderboardData!['status'] == 'Passed'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
            LeaderboardContainer(meritList: meritList),
            SizedBox(height: 20.h),
            AllStudentLeaderboardContainer(leaderboard: allLeaderboard),
          ],
        ),
      ),
    );
  }
}
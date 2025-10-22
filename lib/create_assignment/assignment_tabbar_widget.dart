import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constant.dart';
import 'pending_assignment.dart';
import 'done_assignment.dart';

class AssignmentTabWidget extends StatefulWidget {
  final int assignmentId;
  const AssignmentTabWidget({Key? key, required this.assignmentId}) : super(key: key);

  @override
  _AssignmentTabWidgetState createState() => _AssignmentTabWidgetState();
}

class _AssignmentTabWidgetState extends State<AssignmentTabWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  List<dynamic> pendingAssignmentSubmissions = [];
  List<dynamic> doneAssignmentSubmissions = [];
  int totalSubmissions = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController();
    _fetchAssignmentData();
  }

  Future<void> _fetchAssignmentData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('authToken') ?? '';
    final String apiUrl =
        "${ApiConstant.baseUrl}instructor/course/assignment/assessment/${widget.assignmentId}";

    try {
      setState(() => isLoading = true);
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          pendingAssignmentSubmissions = data['data']['pending_assignment_submissions'];
          doneAssignmentSubmissions = data['data']['done_assignment_submissions'];
          totalSubmissions = data['data']['total_assignment_submissions'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Assessments',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Gilroy',
                color: Colors.white,
              ),
            ),
            SizedBox(width: 56.w),
            Text(
              'Total: $totalSubmissions Persons',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Gilroy',
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00AFEE),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          SizedBox(height: 12.h),
          Container(
            height: 56.h,
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00AFEE).withOpacity(0.20),
                  blurRadius: 16,
                ),
              ],
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(6.h),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                fontFamily: 'Gilroy',
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                fontFamily: 'Gilroy',
              ),
              indicator: BoxDecoration(
                color: const Color(0xFF00AFEE),
                borderRadius: BorderRadius.circular(6.h),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: "Pending"),
                Tab(text: "Done"),
              ],
              onTap: (value) {
                _pageController.animateToPage(
                  value,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              },
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (value) {
                _tabController.animateTo(
                  value,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              },
              itemCount: 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return PendingAssignment(
                    pendingData: pendingAssignmentSubmissions,
                    isLoading: isLoading,
                  );
                }
                return DoneAssignment(
                  doneData: doneAssignmentSubmissions,
                  isLoading: isLoading,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
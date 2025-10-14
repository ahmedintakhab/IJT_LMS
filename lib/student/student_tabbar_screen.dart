import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:learn_megnagmet/student/quiz_screen.dart';
import 'package:learn_megnagmet/student/resources_screen.dart';
import 'package:learn_megnagmet/student/review_screen.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../utils/api_constant.dart';
import 'assignment_screen.dart';
import 'discussion_screen.dart';
import 'live_screen.dart';
import 'notice_screen.dart';
import 'overview_screen.dart';

class TabBarDetails extends StatefulWidget {
  final String slug;
  TabBarDetails({Key? key, required this.slug}) : super(key: key);

  @override
  State<TabBarDetails> createState() => _TabBarDetailsState();
}

class _TabBarDetailsState extends State<TabBarDetails> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  // Initialize tabs
  final List<String> tabs = [
    'Overview',
    'Content',
    'Quiz',
    'Assignment',
    'Notice',
    'Live Class',
    'Discussion',
    'Certificate',
    'Review',
  ];
  late List<Widget> pages;

  // API Data
  Map<String, dynamic>? apiData;
  bool isLoading = true;
  String courseId = '';
  String courseTitle = '';
  double progress = 0.0;


  // Data arrays
  List<dynamic> courseContent = [];
  Map<String, dynamic> overviewData = {};
  List<dynamic> noticeData = [];
  List<dynamic> discussionData = [];
  Map<String, dynamic> reviewsData = {};
  List<dynamic> quizData = [];
  List<dynamic> assignmentData = [];
  Map<String, dynamic> liveClassData = {};

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: tabs.length, vsync: this);
    _pageController = PageController();

    // Initialize empty pages
    pages = List<Widget>.filled(tabs.length, const SizedBox());

    // Fetch data after the page is fully loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchCourseDetails();
    });
  }

  // Fetch data from API
  Future<void> fetchCourseDetails() async {
    final String apiUrl = '${ApiConstant.baseUrl}student/my-course/${widget.slug}';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print("Student course details Api response: ${response.statusCode}");
        setState(() {
          apiData = json.decode(response.body);
          courseTitle = apiData?['data']['title']?.toString() ?? '';
          courseId = apiData?['data']['id']?.toString() ?? '';
          progress = (apiData?['data']['progress'] ?? 0) / 100.0;
          print('Check progress: $progress');
          print('Check the student course detail api data: $apiData');

          // Extract data
          courseContent = apiData?['data']['lessons'] ?? [];
          overviewData = apiData?['data']['overview'] ?? {'description': apiData?['data']['description'] ?? '', 'key_points': []};
          noticeData = apiData?['data']['notices'] ?? [];
          discussionData = apiData?['data']['discussions'] ?? [];
          reviewsData = apiData?['data']['reviews'] ?? {
            'average_rating': apiData?['data']['average_rating'] ?? '0.0',
            'total_user_reviews': apiData?['data']['total_review'] ?? 0,
            'user_reviews': apiData?['data']['reviews']?['reviews']?['data'] ?? [],
            'five_star_percentage': apiData?['data']['reviews']?['five_star_percentage'] ?? 0,
            'four_star_percentage': apiData?['data']['reviews']?['four_star_percentage'] ?? 0,
            'three_star_percentage': apiData?['data']['reviews']?['three_star_percentage'] ?? 0,
            'two_star_percentage': apiData?['data']['reviews']?['two_star_percentage'] ?? 0,
            'first_star_percentage': apiData?['data']['reviews']?['first_star_percentage'] ?? 0,
          };
          quizData = apiData?['data']['course_quiz_tab'] ?? [];
          print('Check quizzes data from api$quizData');
          assignmentData = apiData?['data']['course_assignment_tab'] ?? [];
          liveClassData = apiData?['data']['live_classes'] ?? {'upcoming_live_classes': [], 'current_live_classes': [], 'past_live_classes': []};

          isLoading = false;
        });
        updatePages();
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void handleLectureOpen() {
    // Refresh the data when a lecture is opened
    fetchCourseDetails();
  }

  // Update pages with fetched data
  void updatePages() {
    if (apiData != null) {
      setState(() {
        pages = [
          OverviewPage(overviewData: overviewData),
          ResourcesScreen(
            courseContent: courseContent,
            onLectureOpen: handleLectureOpen,
          ),
           QuizPage(quizData: quizData),
           AssignmentPage(assignmentData: assignmentData, courseId: courseId,),
          NoticePage(noticeData: noticeData),
          LiveClassPage(liveClassData: liveClassData),
          DiscussionPage(discussionData: discussionData, courseId: courseId),
          Container(), // CertificatePage placeholder
          ReviewPage(reviewsData: reviewsData, courseId: courseId),
        ];
      });
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
      body: Column(
        children: [
           SizedBox(height: 30.h),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                courseTitle,
                style:  TextStyle(fontWeight: FontWeight.w700, fontSize: 26.sp),
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
           SizedBox(height: 20.h),
          _buildTabBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00AFEE),))
                : _buildTabBarPages(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        color: Colors.white,
        child: LinearPercentIndicator(
          padding: EdgeInsets.zero,
          // width: MediaQuery.of(context).size.width - 40, // Adjust width to fit padding
          lineHeight: 16.0.h,
          width: 310.0.w,

          percent: progress,
          trailing: Padding(
            padding: EdgeInsets.only(left: 14),
            child: Text(
              "${(progress * 100).toInt()}%",
              style: const TextStyle(
                fontFamily: 'Gilroy',
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          backgroundColor: const Color(0XFFDEDEDE),
          progressColor: const Color(0XFF00AFEE),
          barRadius: const Radius.circular(22),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return  Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00AFEE).withOpacity(0.14),
              offset: const Offset(-4, 5),
              blurRadius: 16,
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            fontFamily: 'Gilroy',
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            fontFamily: 'Gilroy',
          ),
          indicator: BoxDecoration(
            color: const Color(0xFF00AFEE),
            borderRadius: BorderRadius.circular(6),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          tabAlignment: TabAlignment.start,
          tabs: tabs.map((tab) => Tab(
            child: Container(
              alignment: Alignment.center,
              child: Text(tab),
            ),
          )).toList(),
          onTap: (index) {
            _pageController.jumpToPage(index);
          },
        ),
      );
  }

  Widget _buildTabBarPages() {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        _tabController.animateTo(index);
      },
      children: pages,
    );
  }
}
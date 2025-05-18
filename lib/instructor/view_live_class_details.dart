import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learn_megnagmet/instructor/upcoming_live_class.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../utils/api_constant.dart';
import 'current_live_class.dart';
import 'past_live_class.dart';



class ViewLiveClassDetails extends StatefulWidget {
  final String courseuuid; // Add uuid parameter

  const ViewLiveClassDetails({Key? key, required this.courseuuid}) : super(key: key);

  @override
  State<ViewLiveClassDetails> createState() => _ViewLiveClassDetailsState();
}

class _ViewLiveClassDetailsState extends State<ViewLiveClassDetails> with TickerProviderStateMixin {
  late TabController _tabController;

  String courseTitle = '';
  List<Map<String, dynamic>> upcomingData = [];
  List<Map<String, dynamic>> currentData = [];
  List<Map<String, dynamic>> pastData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.index = 0;
    fetchLiveClasses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchLiveClasses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('authToken') ?? '';

    String apiUrl = "${ApiConstant.baseUrl}instructor/live-class-list/${widget.courseuuid}";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print("View Live classes API response:${response.statusCode}");
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            courseTitle = data['data']['course']['title'];
            upcomingData = List<Map<String, dynamic>>.from(data['data']['upcoming_live_classes']);
            currentData = List<Map<String, dynamic>>.from(data['data']['current_live_classes']);
            pastData = List<Map<String, dynamic>>.from(data['data']['past_live_classes']);
            isLoading = false;
          });
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load live classes: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching live classes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching live classes: $e')),
      );
    }
  }


  List<Widget> _buildTabs() {
    return [
      Tab(text: 'Upcoming'),
      Tab(text: 'Current'),
      Tab(text: 'Past'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(courseTitle,style: TextStyle(color: Color(0XFF00AFEE),
            fontSize: 22.sp,fontWeight: FontWeight.bold),maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0XFF00AFEE),))
          :Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              height: 54.h,
              width: double.infinity,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00AFEE).withOpacity(0.14),
                    offset: const Offset(-4, 5),
                    blurRadius: 16.h,
                  ),
                ],
                color: Colors.white,
                borderRadius: BorderRadius.circular(6.h),
              ),
              child: TabBar(
                controller: _tabController,
                unselectedLabelColor: Colors.black,
                labelColor: Colors.white,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                  fontFamily: 'Gilroy',
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                  fontFamily: 'Gilroy',
                ),
                indicator: BoxDecoration(
                  color: const Color(0xFF00AFEE),
                  borderRadius: BorderRadius.circular(6.h),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: _buildTabs(),
                onTap: (index) {
                  setState(() {});
                },
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                UpcomingLiveScreen(classes: upcomingData,
                  courseuuid: widget.courseuuid,
                ),
                CurrentLiveScreen(classes: currentData),
                PastLiveScreen(classes: pastData,
                    courseuuid: widget.courseuuid
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




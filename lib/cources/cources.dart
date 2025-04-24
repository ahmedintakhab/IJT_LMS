import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/controller/controller.dart';
import 'package:learn_megnagmet/cources/discussion_tab.dart';
import 'package:learn_megnagmet/cources/lessons_screen.dart';
import 'package:learn_megnagmet/cources/overview_page.dart';
import 'package:learn_megnagmet/cources/review_screen.dart';
import 'package:learn_megnagmet/cources/tabbar_section.dart';
import 'package:learn_megnagmet/utils/screen_size.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:video_player/video_player.dart';
import 'package:learn_megnagmet/cources/choose_plane_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/api_constant.dart';

class MyCources extends StatefulWidget {
  final String slug;

  const MyCources({Key? key, required this.slug}) : super(key: key);

  @override
  State<MyCources> createState() => _MyCourcesState();
}

class _MyCourcesState extends State<MyCources> {
  final CourceController courceController = Get.put(CourceController());
  late FlickManager flickManager;
  List<Widget> pageclass = [
    const SizedBox(), // Temporary empty widgets
    const SizedBox(),
    const SizedBox(),
    const SizedBox(),
  ];
  Map<String, dynamic> courseData = {};
  Map<String, dynamic> overviewData = {};
  List<dynamic> lessonsData = [];
  bool isLoading = true;
  String courseTitle = "";
  String videoUrl = "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"; // Default video

  @override
  void initState() {
    super.initState();
    // Initialize with default video first
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(videoUrl),
      autoPlay: false,
    );
    fetchCourseDetails();
  }

  Future<void> fetchCourseDetails() async {
    try {
      final url = '${ApiConstant.baseUrl}course-details/${widget.slug}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Course details API response: ${response.statusCode}');
        final data = json.decode(response.body);
        print('Course details API data: $data');

        if (data != null) {
          setState(() {
            courseData = data;

            // Extract overview data
            if (data['overview'] != null) {
              overviewData = data['overview'];
              courseTitle = data['overview']['title'] ?? "Course";
            }
            print('Course overview data:$overviewData');

            // Extract lessons data
            if (data['lessons'] != null) {
              lessonsData = data['lessons'];
            }

            // Extract video URL
            if (data['course_preview_src'] != null && data['course_preview_src'].isNotEmpty) {
              videoUrl = data['course_preview_src'];
              print('video url: $videoUrl');

              // Dispose old flickManager and create a new one with updated video URL
              flickManager.dispose();
              flickManager = FlickManager(
                videoPlayerController: VideoPlayerController.network(videoUrl),
                autoPlay: false,
              );
            }

            // Initialize pages with course details
            pageclass = [
              Overview(overviewData: overviewData),
              Lesson(),
              Review(),
              Discussion(),
            ];
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load course details: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching data in Course details api: ${e.toString()}');
      Get.snackbar('Error', 'Failed to fetch course details: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initializeScreenSize(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0XFF00AFEE)))
            : GetBuilder<CourceController>(
          builder: (controller) => SafeArea(
            child: Column(
              children: [
                // Header Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Image.asset(
                          "assets/back_arrow.png",
                          height: 24.h,
                          width: 24.w,
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: Text(
                          courseTitle,
                          style: TextStyle(
                            fontFamily: 'Gilroy',
                            fontWeight: FontWeight.w700,
                            fontSize: 20.sp,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ],
                  ),
                ),

                // Video Player Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Container(
                    padding: EdgeInsets.all(12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0XFF00AFEE).withOpacity(0.1),
                          blurRadius: 16,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(22.h),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22.h),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: FlickVideoPlayer(flickManager: flickManager),
                      ),
                    ),
                  ),
                ),

                // Tabbar Section with Expanded
                Expanded(
                  child: TabbarSection(
                    courceController: controller,
                    pageclass: pageclass,
                  ),
                ),

                // Enroll Button
                Padding(
                  padding: EdgeInsets.only(bottom: 30.h),
                  child: CustomButton(
                    onTap: () => Get.to(const ChoosePlane()),
                    buttonText: 'Enroll Now',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
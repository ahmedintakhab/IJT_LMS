import 'package:cached_network_image/cached_network_image.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/controller/controller.dart';
import 'package:learn_megnagmet/cources/lessons_screen.dart';
import 'package:learn_megnagmet/cources/overview_page.dart';
import 'package:learn_megnagmet/cources/review_screen.dart';
import 'package:learn_megnagmet/cources/tabbar_section.dart';
import 'package:learn_megnagmet/student/student_tabbar_screen.dart';
import 'package:learn_megnagmet/utils/screen_size.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:convert';

import '../home/home_main.dart';
import '../login/login_empty_state.dart';
import '../utils/api_constant.dart';
import 'instructors_tab.dart';

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
  Map<String, dynamic> reviewsData = {};
  List<dynamic> lessonsData = [];
  List<dynamic> instructorsData = [];
  bool isLoading = true;
  String courseTitle = "";
  String courseId = "";
  String courseSlug = "";
  String btnText = '';
  bool isVideo = true;
  bool isMediaLoading = true;
  String videoUrl = "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"; // Default video
  // Add this helper method to check if URL is YouTube
  bool _isYoutubeUrl(String url) {
    return url.toLowerCase().contains('youtube.com') ||
        url.toLowerCase().contains('youtu.be');
  }

// Extract YouTube video ID from URL
  String? _getYoutubeId(String url) {
    if (url.contains('youtube.com/embed/')) {
      return url.split('youtube.com/embed/')[1].split('?')[0];
    } else if (url.contains('v=')) {
      return url.split('v=')[1].split('&')[0];
    } else if (url.contains('youtu.be/')) {
      return url.split('youtu.be/')[1].split('?')[0];
    }
    return null;
  }



  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(videoUrl),
      autoPlay: false,
    )..flickControlManager!.addListener(_checkVideoLoading);
    fetchCourseDetails();
  }

  void _checkVideoLoading() {
    if (flickManager.flickVideoManager!.isVideoInitialized && isMediaLoading) {
      setState(() => isMediaLoading = false);
    }
  }

  Future<void> fetchCourseDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = '${ApiConstant.baseUrl}course-details/${widget.slug}';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );


      if (response.statusCode == 200) {
        print('Course details API response: ${response.statusCode}');
        final data = json.decode(response.body);
        // print('Course details API data: $data');

        if (data != null) {
          setState(() {
            courseData = data;
            courseId = data['course_id'].toString() ?? '';
            courseSlug = data['course_slug'] ?? ''; // Add this line
            print('Course slug: $courseSlug');

            print('Check the course id on course details screen:$courseId ');
            btnText = data['btn_text'] ?? '';
            print('Check button Text:$btnText');

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
            // Extract instructors data
            if (data['instructors'] != null) {
              instructorsData = data['instructors'];
            }
            print('Course Instructors data:$instructorsData');

            // Extract instructors data
            if (data['reviews'] != null) {
              reviewsData = data['reviews'];
            }
            print('Course Instructors data:$reviewsData');


            if (data['course_preview_src'] != null && data['course_preview_src'].isNotEmpty) {
              videoUrl = data['course_preview_src'];
              print('media url: $videoUrl');

              if (_isYoutubeUrl(videoUrl)) {
                isVideo = true;
                // For YouTube, we'll handle it differently in the UI
                setState(() => isMediaLoading = false);
              } else if (_isImageUrl(videoUrl)) {
                isVideo = false;
                setState(() => isMediaLoading = false);
              } else {
                // Regular video URL
                isVideo = true;
                flickManager.dispose();
                flickManager = FlickManager(
                  videoPlayerController: VideoPlayerController.network(videoUrl),
                  autoPlay: false,
                )..flickControlManager!.addListener(_checkVideoLoading);
              }
            }



            // Initialize pages with course details
            pageclass = [
              Overview(overviewData: overviewData),
              Lesson(lessonsData: lessonsData,),
              Review(reviewsData: reviewsData,
                courseId: courseId,
              ),
              Instructors(instructorsData: instructorsData),
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

  bool _isImageUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.png') ||
        lowerUrl.endsWith('.jpg') ||
        lowerUrl.endsWith('.jpeg') ||
        lowerUrl.endsWith('.gif');
  }

  Future<void> _enrollCourse() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      if (token.isEmpty && btnText == "Enroll Now") {
        await prefs.setString('redirect_after_login', 'MyCources');
        await prefs.setString('course_slug', widget.slug);
        Get.to(() => const EmptyState());
        return;
      }

      if (btnText == "Enroll Now") {
        print('Token check: $token');

        final url = '${ApiConstant.baseUrl}student/add-to-cart';

        print("API URL: $url");
        print("Course ID: $courseId");
        print("Auth Token: $token");

        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'course_id': courseId,
          }),
        );

        print("Enroll API Response Code: ${response.statusCode}");
        print("Enroll API Response Body: ${response.body}");

        if (response.statusCode == 200) {
          Get.to(() => const HomeMainScreen());
          await fetchCourseDetails();

          print("API Successfully Enroll Course.");
          Get.snackbar(
            'Success',
            'Successfully enrolled in the course',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            borderRadius: 10,
            margin: EdgeInsets.all(15),
            duration: Duration(seconds: 3),
          );

          fetchCourseDetails();
        } else {
          throw Exception('Failed to enroll: ${response.statusCode}');
        }
      } else if (btnText == "Go to Course") {
        Get.to(() => TabBarDetails(slug: courseSlug));
      }
    } catch (e) {
      print('Error in enroll course: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to enroll: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.2),
        colorText: Colors.red,
      );
    }
  }
  // Method to reload media (image or video)
  void _reloadMedia() {
    setState(() {
      isMediaLoading = true; // Show loading indicator
      if (isVideo) {
        // Dispose and reinitialize FlickManager for video
        flickManager.dispose();
        flickManager = FlickManager(
          videoPlayerController: VideoPlayerController.network(videoUrl),
          autoPlay: false,
        )..flickControlManager!.addListener(_checkVideoLoading);
      } else {
        // For images, reset loading state to trigger reload
        isMediaLoading = false;
      }
    });
  }

  @override
  void dispose() {
    flickManager.flickControlManager?.removeListener(_checkVideoLoading);
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
                            fontFamily: 'Nastaleeq',
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
                          child: Stack(
                              alignment: Alignment.center,
                              children: [
                          // Media content
                                isMediaLoading
                                    ? const Center(child: CircularProgressIndicator(color: Color(0XFF00AFEE)))
                                    : isVideo
                                    ? _isYoutubeUrl(videoUrl)
                                    ? YoutubePlayer(
                                  controller: YoutubePlayerController(
                                    initialVideoId: _getYoutubeId(videoUrl)!,
                                    flags: const YoutubePlayerFlags(
                                      autoPlay: false,
                                      mute: false,
                                    ),
                                  ),
                                  aspectRatio: 16/9,
                                )
                                    : FlickVideoPlayer(flickManager: flickManager)
                                    : CachedNetworkImage(
                                  imageUrl: videoUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0XFF00AFEE),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Center(
                                    child: GestureDetector(
                                      onTap: _reloadMedia,
                                      child: const Text(
                                        'Retry',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                )

                              ]
                               )
                               )
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
                  padding: EdgeInsets.only(bottom: 30.h,left: 10.w, right: 10.w),
                  child: CustomButton(
                    onTap: _enrollCourse,
                    buttonText: btnText ?? '', // Use the dynamic button text
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
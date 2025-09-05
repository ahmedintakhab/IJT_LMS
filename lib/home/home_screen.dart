import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:learn_megnagmet/controller/controller.dart';
import 'package:learn_megnagmet/home/recent_added_list.dart';
import 'package:learn_megnagmet/home/recently_added_cources.dart';
import 'package:learn_megnagmet/home/search_screen.dart';
import 'package:learn_megnagmet/home/trending_cource.dart';
import 'package:learn_megnagmet/home/trending_courses_list.dart';
import 'package:learn_megnagmet/models/design_list.dart';
import 'package:learn_megnagmet/models/home_slider.dart';
import 'package:learn_megnagmet/utils/slider_page_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/api_constant.dart';
import '../utils/cache_api_service.dart';
import '../utils/screen_size.dart';
import 'categories_courses.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<HomeSlider> pages = [];
  List<Design> design = Utils.getDesign();
  List<Map<String, dynamic>> trendingCource = [];
  List<Map<String, dynamic>> recentAdded = [];
  List<bool> trendingButtonStatuses = [];
  List<bool> recentButtonStatuses = [];
  Map<String, dynamic>? bannerData;
  List<Map<String, dynamic>> banners = [];
  HomeController homecontroller = Get.put(HomeController());
  PageController controller = PageController();
  List userDetail = Utils.getUser();
  bool isLoading = true;
  String? errorMessage;
  String? userName;
  String? userImage;
  String? slug;


  @override
  void initState() {
    pages = Utils.getHomeSliderPages();
    fetchCourses();
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'User';
      userImage = prefs.getString('image') ?? '';
    });
  }

  Future<void> fetchCourses() async {
    try {
      final url = '${ApiConstant.baseUrl}home/courses';
      final jsonData = await fetchDataWithCache(url); // ✅ use cache

      if (jsonData['success'] == true) {
        final featureCategories = jsonData['data']['featureCategories'];

        setState(() {
          // Get banner data
          bannerData = jsonData['data']['banner'];
          if (bannerData != null) {
            banners = [bannerData!];
          }
          trendingCource = List<Map<String, dynamic>>.from(
              featureCategories['Nisab-e-Rukniyat Courses'] ?? []);
          trendingButtonStatuses =
          List<bool>.filled(trendingCource.length, false);
          slug = trendingCource.isNotEmpty
              ? trendingCource[0]['slug']?.toString() ?? ''
              : '';

          recentAdded = List<Map<String, dynamic>>.from(
              featureCategories['Nisab-e-Rafaqat Courses'] ?? []);
          recentButtonStatuses =
          List<bool>.filled(recentAdded.length, false);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = jsonData['message'] ?? 'Failed to load courses';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
  }

  void toggleTrending(int index) {
    setState(() {
      trendingButtonStatuses[index] = !trendingButtonStatuses[index];
    });
  }

  void toggleRecent(int index) {
    setState(() {
      recentButtonStatuses[index] = !recentButtonStatuses[index];
    });
  }
  Widget _buildShimmerEffect() {
    return SingleChildScrollView(
      child:Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            height: 150.h,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 100.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemBuilder: (context, index) {
                return Container(
                  width: 80.w,
                  margin: EdgeInsets.only(right: 15.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20.h),
          Container(
            height: 234.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  width: 177.w,
                  margin: EdgeInsets.only(right: 8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 172.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 16.h,
                        width: 120.w,
                        color: Colors.white,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20.h),
          Container(
            height: 323.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 2,
              itemBuilder: (context, index) {
                return Container(
                  width: 276.w,
                  margin: EdgeInsets.only(right: 8.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20.h,)
        ],
      ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    initializeScreenSize(context);
    // return WillPopScope(
    //   onWillPop: () => Future.value(false),
    //   child:

     return Scaffold(
        body: SafeArea(
          child: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: GetBuilder<HomeController>(
              init: HomeController(),
              builder: (controller) => isLoading
                  ?_buildShimmerEffect()
                  // : errorMessage != null
                  // ? Center(child: Text(errorMessage!))
                  : ListView(
                padding: EdgeInsets.zero,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SizedBox(height: 16.h),
                   Container(
                      height: 70,
                      color: Color(0XFF00AFEE), // Your specified color
                      child: Row(
                        children: [
                          // User image and welcome text
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                image: DecorationImage(
                                  image: NetworkImage(userImage!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            "Welcome,${userName}",
                            style: TextStyle(
                              fontFamily: 'Nastaleeq',
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          // Spacer to push the search icon to the right
                          Spacer(),

                          // Circular search icon container
                          Padding(
                            padding: EdgeInsets.only(right: 10.w),
                            child: GestureDetector(
                              onTap: () => Get.to(SearchScreen(slug: slug ?? '',
                              )),
                              child: Container(
                                height: 45.h,
                                width: 45.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,color: Color(0XFF00AFEE),
                                  border: Border.all(
                                    color: const Color(0XFF00AFEE),
                                    width: 1.w,
                                  ),
                                ),
                                child: Center(
                                  child: Image(
                                    image: AssetImage('assets/search.png'),
                                    height: 28.h,
                                    width: 28.w,color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                        // SizedBox(height: 40.h),
                        generatepage(),
                        // SizedBox(height: 20.h),
                        // indicator(),
                        SizedBox(height: 30.h),
                        HorizontalDesignList(),
                        SizedBox(height: 22.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Trending Course",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Nastaleeq',
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Get.to(const TrendingCource()),
                                child: Text(
                                  "See All",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontFamily: 'Nastaleeq',
                                      color: const Color(0XFF00AFEE),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TrendingCourceList(
                          trendingCource: trendingCource,
                          isLoading: isLoading, // Set this to true while loading data

                        ),
                        Padding(
                          padding:
                          EdgeInsets.symmetric(horizontal: 20.w),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Recently Added Course",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Nastaleeq',
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Get.to(const RecentlyAdded()),
                                child: Text(
                                  "See All",
                                  style: TextStyle(
                                    fontFamily: 'Nastaleeq',
                                    fontSize: 18.sp,
                                    color: const Color(0XFF00AFEE),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        RecentAddedList(
                          recentAdded: recentAdded,
                          buttonStatuses: recentButtonStatuses,
                          toggleRecent: toggleRecent,
                          isLoading: isLoading,
                        )
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget generatepage() {
    if (isLoading || banners.isEmpty) {
      return Container(
        height: 180.h,
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    return CarouselSlider.builder(
      options: CarouselOptions(
        autoPlay: banners.length > 1, // Auto-play only if more than one banner
        enableInfiniteScroll: banners.length > 1, // Infinite scroll only if more than one banner
        initialPage: 0,
        height: 180.h,
        enlargeCenterPage: false,
        viewportFraction: 1.0, // Use full screen width
      ),
      itemBuilder: (BuildContext context, int index, int realIndex) {
        final banner = banners[index];
        return Container(
          width: MediaQuery.of(context).size.width,
          height: 180.h,
          margin: EdgeInsets.symmetric(horizontal: 0.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            image: DecorationImage(
              image: NetworkImage(banner['banner_image'] ?? ''),
              fit: BoxFit.cover, // Make sure image covers full width
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20.h, left: 25.w, right: 110.w),
                child: Text(
                  banner['banner_first_line_title'] ?? '',
                  style: TextStyle(
                    fontFamily: 'Nastaleeq',
                    color: Color(0XFF000000),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 29.sp),
              // Additional widgets here
            ],
          ),
        );
      },
      itemCount: banners.length,
    );  }

  Widget indicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pages.length, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 10.h,
            width: 10.w,
            decoration: BoxDecoration(
              color: (index == homecontroller.currentpage.value)
                  ? const Color(0XFF00AFEE)
                  : const Color(0XFFDEDEDE),
            ),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
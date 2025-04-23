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
import 'package:shimmer/shimmer.dart';
import '../utils/api_constant.dart';
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

  @override
  void initState() {
    pages = Utils.getHomeSliderPages();
    fetchCourses();
    super.initState();
  }

  Future<void> fetchCourses() async {
    try {
      final url = '${ApiConstant.baseUrl}home/courses';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Home Api response statuscode: ${response.statusCode}');
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final featureCategories = jsonData['data']['featureCategories'];

          setState(() {
            // Get banner data
            bannerData = jsonData['data']['banner'];
            if (bannerData != null) {
              banners = [bannerData!]; // Convert to list for carousel
            }
            trendingCource = List<Map<String, dynamic>>.from(
                featureCategories['Nisab-e-Rukniyat Courses | نصابِ رکنیت کورسز'] ?? []);
            trendingButtonStatuses = List<bool>.filled(trendingCource.length, false);
            print('Check trending courses: ${trendingCource}');
            recentAdded = List<Map<String, dynamic>>.from(
                featureCategories['Nisab-e-Rafaqat Courses | نصابِ رفاقت کورسز'] ?? []);
            recentButtonStatuses = List<bool>.filled(recentAdded.length, false);
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = jsonData['message'] ?? 'Failed to load courses';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to fetch data: ${response.statusCode}';
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
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          // Banner Shimmer
          Container(
            height: 150.h,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 30.h),

          // Design List Shimmer
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
          SizedBox(height: 30.h),

          // Trending Courses Shimmer
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
          SizedBox(height: 30.h),

          // Recently Added Shimmer
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    initializeScreenSize(context);
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        body: SafeArea(
          child: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: GetBuilder<HomeController>(
              init: HomeController(),
              builder: (controller) => isLoading
                  ?_buildShimmerEffect()
                  : errorMessage != null
                  ? Center(child: Text(errorMessage!))
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      children: [
                        Image(
                          image: AssetImage(userDetail[0].image),
                          height: 50.h,
                          width: 49.93.w,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          "Welcome,${userDetail[0].name}",
                          style: TextStyle(
                            fontFamily: 'Gilroy',
                            color: const Color(0XFF000000),
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      primary: true,
                      children: [
                        Container(
                          height: 50.h,
                          child: Padding(
                            padding:
                            EdgeInsets.symmetric(horizontal: 20.w),
                            child: TextFormField(
                              onTap: () => Get.to(SearchScreen()),
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: const Color(0XFF00AFEE),
                                    width: 1.w,
                                  ),
                                  borderRadius:
                                  BorderRadius.circular(6),
                                ),
                                hintText: 'Search',
                                hintStyle: TextStyle(
                                  color: Color(0XFF9B9B9B),
                                  fontSize: 15.sp,
                                  fontFamily: 'Gilroy',
                                  fontWeight: FontWeight.w400,
                                ),
                                prefixIcon: Image(
                                  image:
                                  AssetImage('assets/search.png'),
                                  height: 24.h,
                                  width: 24.w,
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    height: 5.h,
                                    width: 5.w,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            "assets/filico.png"),
                                      ),
                                    ),
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        generatepage(),
                        SizedBox(height: 20.h),
                        indicator(),
                        SizedBox(height: 20.h),
                        HorizontalDesignList(design: design),
                        SizedBox(height: 22.h),
                        Padding(
                          padding:
                          EdgeInsets.symmetric(horizontal: 20.w),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Trending Course",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Gilroy',
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Get.to(const TrendingCource()),
                                child: Text(
                                  "See All",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontFamily: 'Gilroy',
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
                          buttonStatuses: trendingButtonStatuses,
                          toggle: toggleTrending,
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
                                  fontFamily: 'Gilroy',
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Get.to(const RecentlyAdded()),
                                child: Text(
                                  "See All",
                                  style: TextStyle(
                                    fontFamily: 'Gilroy',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget generatepage() {
    if (isLoading || banners.isEmpty) {
      return Container(
        height: 150.h,
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    return CarouselSlider.builder(
      options: CarouselOptions(
        autoPlay: false,
        enableInfiniteScroll: true,
        initialPage: 0,
        height: 150.0.h,
        enlargeCenterPage: false,
        viewportFraction: 0.84,
        // onPageChanged: (index, reason) {
        //   homecontroller.onChange(index.obs);
        // },
      ),
      itemBuilder: (BuildContext context, int index, int realIndex) {
        final banner = banners[index];
        return Padding(
          padding: EdgeInsets.only(
            left: index == 0 ? 0.w : 12.w,
            right: index == banners.length - 1 ? 12.w : 0.w,
          ),
          child: Container(
            height: 150.h,
            width: 352.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              image: DecorationImage(
                image: NetworkImage(banner['banner_image'] ?? ''),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                  EdgeInsets.only(top: 20.h, left: 25.w, right: 110.w),
                  child: Text(
                    banner['banner_first_line_title'] ?? '',
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      color: Color(0XFF000000),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 29.sp),
                Padding(
                  padding: EdgeInsets.only(left: 25.w),
                  // child: Text(
                  //   "Get Start",
                  //   style: TextStyle(
                  //     color: const Color(0XFF00AFEE),
                  //     fontWeight: FontWeight.w700,
                  //     fontFamily: 'Gilroy',
                  //     fontSize: 18.sp,
                  //   ),
                  // ),
                ),
              ],
            ),
          ),
        );
      },
      itemCount: banners.length,
    );
  }

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
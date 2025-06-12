import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/home/search_courses_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/controller.dart';
import '../models/design_list.dart';
import '../models/recently_added.dart';
import '../models/trending_cource.dart';
import '../utils/api_constant.dart';
import '../utils/screen_size.dart';
import '../utils/slider_page_data_model.dart';
import 'categories_courses.dart';
import 'filter_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  SearchScreenController searchScreenController =
      Get.put(SearchScreenController());
  List<String> categoryList = [
    "UI/UX",
    "Design",
    "3D Design",
  ];
  List<String> selectedCategory = [];
  List<Design> design = Utils.getDesign();
  List<Trending> cource = Utils.getTrending();
  List<Recent> recentAdded = Utils.getRecentAdded();
  List<dynamic> courses = [];
  bool isLoading = true;
  String errorMessage = '';
  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final response = await GetConnect().get(
        '${ApiConstant.baseUrl}search-course-list',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body['success'] == true) {
          setState(() {
            courses = response.body['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = response.body['message'] ?? 'Failed to load courses';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load courses: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeScreenSize(context);

    return WillPopScope(
      onWillPop: (){
        return Future.value(false);
      },
      child: Scaffold(
        body: GetBuilder<SearchScreenController>(
            init: SearchScreenController(),
            builder: (controller) => SafeArea(
              child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: GestureDetector(
                            onTap: () {
                              Get.back();
                            },
                            child: Image(
                              image: const AssetImage("assets/back_arrow.png"),
                              height: 24.h,
                              width: 24.w,
                            )),
                      ),
                      SizedBox(height: 20.h),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          shrinkWrap: true,
                          //padding: EdgeInsets.zero,
                          primary: true,
                          children: [
                            search_text_field(),
                            //SizedBox(height: 20),
                            // Wrap(
                            //   alignment: WrapAlignment.start,
                            //   children: [
                            //     for (final i in List.generate(
                            //         categoryList.length, (index) => index))
                            //       Padding(
                            //         padding: EdgeInsets.only(
                            //             top: 12.h,
                            //             bottom: 12.h,
                            //             right: 3.w,
                            //             left: 3.w),
                            //         child: Wrap(
                            //           children: [
                            //             GestureDetector(
                            //               onTap: () {
                            //                 setState(() {
                            //                   if (!selectedCategory
                            //                       .contains(categoryList[i])) {
                            //                     selectedCategory
                            //                         .add(categoryList[i]);
                            //                   } else {
                            //                     selectedCategory
                            //                         .remove(categoryList[i]);
                            //                   }
                            //                 });
                            //               },
                            //               child: Container(
                            //                 padding: EdgeInsets.symmetric(
                            //                     vertical: 6.h, horizontal: 13.w),
                            //                 decoration: BoxDecoration(
                            //                   color: selectedCategory
                            //                           .contains(categoryList[i])
                            //                       ? Color(0XFFE5ECFF)
                            //                       : Colors.white,
                            //                   borderRadius:
                            //                       BorderRadius.circular(6.h),
                            //                   border: Border.all(
                            //                       color: selectedCategory
                            //                               .contains(categoryList[i])
                            //                           ? Color(0XFF00AFEE)
                            //                           : Color(0XFF6E758A),
                            //                       width: 1.w),
                            //                 ),
                            //                 child: Text(
                            //                   categoryList[i],
                            //                   style: selectedCategory
                            //                           .contains(categoryList[i])
                            //                       ? TextStyle(
                            //                           fontSize: 15.sp,
                            //                           fontWeight: FontWeight.w700,
                            //                           color: Color(0XFF00AFEE),
                            //                           fontFamily: 'Gilroy')
                            //                       : TextStyle(
                            //                           fontSize: 15.sp,
                            //                           fontWeight: FontWeight.w700,
                            //                           color: Color(0XFF6E758A),
                            //                           fontFamily: 'Gilroy'),
                            //                 ),
                            //               ),
                            //             ),
                            //           ],
                            //         ),
                            //       )
                            //   ],
                            // ),
                            SizedBox(height: 20.h),
                            HorizontalDesignList(),
                            SizedBox(height: 20.h),
                            // trending_cource(),
                            SearchCoursesList(
                              courses: courses,
                              isLoading: isLoading,
                              errorMessage: errorMessage,
                            ),
                            SizedBox(height: 20.h),
                            // recent_added_list(),
                          ],
                        ),
                      )
                    ],
                  ),
            )),
      ),
    );
  }

  Widget search_text_field() {
    return Container(
      height: 50.h,
      child: TextFormField(
          decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0XFF00AFEE), width: 1.w),
                  borderRadius: BorderRadius.circular(6.h)),
              hintText: 'Search',
              hintStyle: TextStyle(
                  color: const Color(0XFF9B9B9B),
                  fontSize: 15.sp,
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w400),
              prefixIcon: Image(
                image: AssetImage('assets/search.png'),
                height: 24.h,
                width: 24.w,
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.h),
                      ),
                      context: context,
                      builder: (context) => const FilterSheet());
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 3.h,
                    width: 3.w,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/filtericon.png"),
                        colorFilter: ColorFilter.mode(
                          Color(0xFF00AFEE), // Apply the color 0xFF00AFEE
                          BlendMode.srcIn, // Blend mode to tint the image
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(6.h)))),
    );
  }

  Widget horizontal_disidn() {
    return Container(
      //color: Colors.red,
      height: 100.h,
      width: double.infinity.w,
      child: ListView.builder(
          shrinkWrap: true,
          primary: false,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: design.length,
          itemBuilder: (BuildContext context, index) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0.w : 6.w),
                  child: Image(
                    image: AssetImage(design[index].image!),
                    height: 110.h,
                    width: 110.w,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 60.h),
                  child: Text(
                    design[index].name!,
                    style: TextStyle(
                        color: Color(0XFF000000),
                        fontSize: 14.sp,
                        fontFamily: 'Gilroy',
                        fontWeight: FontWeight.w700),
                  ),
                )
              ],
            );
          }),
    );
  }

  Widget trending_cource() {
    return SizedBox(
      height: 302.h,
      width: 178.w,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            //height: 302,
            width: 177.w,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.h),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0XFF00AFEE).withOpacity(0.14),
                      offset: const Offset(-4, 5),
                      blurRadius: 16.h),
                ],
                color: const Color(0XFFFFFFFF)),
            child: Column(
              children: [
                Container(
                  height: 165.h,
                  width: 190.w,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(cource[index].image!),
                        fit: BoxFit.cover),
                    borderRadius: BorderRadius.circular(6.h),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0XFF00AFEE).withOpacity(0.14),
                          offset: const Offset(-4, 5),
                          blurRadius: 16),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 10.h, left: 10.w, bottom: 130.h, right: 130.w),
                    child: Container(
                        height: 30.h,
                        width: 30.w,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        child: Center(
                            child: Image(
                          image: const AssetImage("assets/like.png"),
                          height: 13.08.h,
                          width: 13.08.w,
                        ))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 6.w, right: 6.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6.h),
                      Text(
                        cource[index].title!,
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Gilroy',
                            color: const Color(0XFF000000)),
                      ),
                      Text(
                        cource[index].subtitle!,
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Gilroy',
                            color: Color(0XFF000000)),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 12.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 27.h,
                              width: 50.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6.h),
                                color: const Color(0XFFFAF4E1),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image(
                                    image: AssetImage("assets/staricon.png"),
                                    height: 15.h,
                                    width: 15.w,
                                  ),
                                  Text(
                                    cource[index].review!,
                                    style: TextStyle(
                                        color: const Color(0XFFFFC403),
                                        fontFamily: 'Gilroy',
                                        fontSize: 14.sp),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 6.w),
                              child: SizedBox(
                                height: 21.h,
                                width: 76.w,
                                //color: Colors.red,
                                child: Row(
                                  children: [
                                    Image(
                                      image: AssetImage("assets/clock.png"),
                                      height: 17.h,
                                      width: 17.w,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      cource[index].time!,
                                      style: TextStyle(
                                          fontSize: 13.sp,
                                          color: const Color(0XFF000000),
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Gilroy'),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Image(
                            image: AssetImage(cource[index].circleimage!),
                            height: 30.h,
                            width: 30.w,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            cource[index].personname!,
                            style: TextStyle(
                                color: const Color(0XFF00AFEE),
                                fontSize: 14.sp,
                                fontFamily: 'Gilroy'),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget recent_added_list() {
    return SizedBox(
      height: 323.h,
      width: double.infinity.w,
      child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          primary: false,
          shrinkWrap: true,
          itemCount: 1,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, index) {
            return Container(
              //height: 323,
              width: 276.w,

              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.h),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0XFF00AFEE).withOpacity(0.14),
                        offset: const Offset(-4, 5),
                        blurRadius: 16.h),
                  ],
                  color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 158.h,
                    width: 276.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      image: DecorationImage(
                          image: AssetImage(
                            recentAdded[index].image!,
                          ),
                          fit: BoxFit.cover),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: 230.w, bottom: 120.h, top: 10.h),
                      child: Container(
                          height: 20.h,
                          width: 20.w,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
                          child: IconButton(
                              splashRadius: 10,
                              onPressed: () {},
                              icon: Center(
                                  child: Image(
                                image: const AssetImage("assets/saveicon.png"),
                                height: 13.h,
                                width: 13.w,
                              )))),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10.w, top: 10.h),
                        child: Container(
                          height: 25.h,
                          width: 58.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.h),
                            color: const Color(0XFFFAF4E1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Image(
                                image: const AssetImage("assets/staricon.png"),
                                height: 17.h,
                                width: 17.w,
                              ),
                              Text(
                                recentAdded[index].review!,
                                style: TextStyle(
                                    fontFamily: 'Gilroy',
                                    color: const Color(0XFFFFC403),
                                    fontSize: 15.sp),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 5.w),
                        child: Row(
                          children: [
                            Image(
                              image: const AssetImage("assets/clock.png"),
                              height: 17.h,
                              width: 17.w,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              recentAdded[index].time!,
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  color: Color(0XFF000000),
                                  fontFamily: 'Gilroy'),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 11.h),
                  Padding(
                    padding: EdgeInsets.only(left: 10.w, right: 10.w),
                    child: Text(
                      recentAdded[index].title!,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                          color: const Color(0XFF000000),
                          fontFamily: 'Gilroy'),
                    ),
                  ),
                  SizedBox(height: 11.h),
                  Padding(
                    padding: EdgeInsets.only(left: 10.w, right: 10.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image(
                              image:
                                  AssetImage(recentAdded[index].circleimage!),
                              height: 40.h,
                              width: 40.w,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              recentAdded[index].personname!,
                              style: TextStyle(
                                  fontFamily: 'Gilroy',
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0XFF00AFEE),
                                  fontSize: 15.sp),
                            ),
                          ],
                        ),
                        Container(
                          height: 33.h,
                          width: 76.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.h),
                            color: const Color(0XFFE5ECFF),
                          ),
                          child: Center(
                              child: Text(
                            recentAdded[index].price!,
                            style: TextStyle(
                                color: Color(0XFF00AFEE),
                                fontFamily: 'Gilroy',
                                fontSize: 19.sp,
                                fontWeight: FontWeight.w400),
                          )),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          }),
    );
  }
}

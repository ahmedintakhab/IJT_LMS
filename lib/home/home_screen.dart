import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:learn_megnagmet/controller/controller.dart';
import 'package:learn_megnagmet/cources/cources.dart';
import 'package:learn_megnagmet/home/recent_added_cource_detail.dart';
import 'package:learn_megnagmet/home/recent_added_list.dart';

import 'package:learn_megnagmet/home/recently_added_cources.dart';
import 'package:learn_megnagmet/home/search_screen.dart';
import 'package:learn_megnagmet/home/trending_cource.dart';
import 'package:learn_megnagmet/home/trending_courses_list.dart';
import 'package:learn_megnagmet/models/design_list.dart';
import 'package:learn_megnagmet/models/home_slider.dart';
import 'package:learn_megnagmet/models/recently_added.dart';
import 'package:learn_megnagmet/models/trending_cource.dart';

import 'package:learn_megnagmet/utils/slider_page_data_model.dart';


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
  List<Trending> trendingCource = Utils.getTrending();
  List<Recent> recentAdded =Utils.getRecentAdded();
  HomeController homecontroller = Get.put(HomeController());

  // int currentpage = 0;
  PageController controller = PageController();
  bool buttonvalue= false;
  int currentvalue = 0;
  List userDetail = Utils.getUser();
  @override
  void initState() {
    pages = Utils.getHomeSliderPages();
    super.initState();
  }
  toggle(int index){
   setState(() {

     if(trendingCource[index].buttonStatus==true){
    trendingCource[index].buttonStatus = false;
   }
   else{
       trendingCource[index].buttonStatus = true;
     }});
  }
  toggleRecent(int index){
    setState(() {

      if(recentAdded[index].buttonStatus==true){
        recentAdded[index].buttonStatus = false;
      }
      else{
        recentAdded[index].buttonStatus = true;
      }});
  }


  @override
  Widget build(BuildContext context) {
    initializeScreenSize(context);
    return WillPopScope(
      onWillPop: (){
        return Future.value(false);
      },
      child: Scaffold(
        body: SafeArea(
          child: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: GetBuilder<HomeController>(
              init: HomeController(),
              builder: (controller) => SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     SizedBox(height: 16.h),
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(children: [
                        Image(image: AssetImage(userDetail[0].image),height: 50.h,width: 49.93.w,),
                         SizedBox(width: 10.w),
                        Text("Welcome,${userDetail[0].name}",
                            style:  TextStyle(
                                fontFamily: 'Gilroy',
                                color: const Color(0XFF000000),
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700))
                      ]),
                    ),
                     SizedBox(height: 30.h),
                    Expanded(
                      child: ListView(
                        // physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        primary: true,
                        children: [
                          Container(

                            height: 50.h,
                            child: Padding(
                              padding:  EdgeInsets.symmetric(horizontal: 20.w),
                              child: TextFormField(
                                  onTap: () {
                                    Get.to(SearchScreen());
                                  },
                                  decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                          borderSide:  BorderSide(
                                              color: const Color(0XFF00AFEE), width: 1.w),
                                          borderRadius: BorderRadius.circular(6)),
                                      hintText: 'Search',
                                      hintStyle:  TextStyle(
                                          color: Color(0XFF9B9B9B),
                                          fontSize: 15.sp,
                                          fontFamily: 'Gilroy',
                                          fontWeight: FontWeight.w400),
                                      prefixIcon:  Image(
                                        image: AssetImage('assets/search.png'),
                                        height: 24.h,
                                        width: 24.w,

                                      ),
                                      suffixIcon: GestureDetector(
                                        onTap: () {

                                        },
                                        child: Container(
                                          height: 5.h,
                                          width: 5.w,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage("assets/filico.png"),

                                            ),
                                          ),
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(6)))),
                            ),
                          ),
                           SizedBox(height: 20.h),
                          generatepage(),
                           SizedBox(height: 20.h),
                          indicator(),
                           SizedBox(height: 20.h),
                          HorizontalDesignList(design: design),                            SizedBox(height: 22.h),
                          Padding(
                            padding:  EdgeInsets.symmetric(horizontal: 20.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                 Text("Trending Course",
                                    style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Gilroy')),
                                TextButton(
                                    onPressed: () {
                                      Get.to(const TrendingCource());
                                    },
                                    child:  Text("See All",
                                        style: TextStyle(
                                            fontSize: 18.sp,
                                            fontFamily: 'Gilroy',
                                            color: const Color(0XFF00AFEE),
                                            fontWeight: FontWeight.bold)))
                              ],
                            ),
                          ),
                          TrendingCourceList(
                            trendingCource: trendingCource,
                            toggle: toggle,
                          ),                          Padding(
                            padding:  EdgeInsets.symmetric(horizontal: 20.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                 Text("Recently Added Course",
                                    style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Gilroy')),
                                TextButton(
                                    onPressed: () {
                                      Get.to(const RecentlyAdded());
                                    },
                                    child:  Text("See All",
                                        style: TextStyle(
                                            fontFamily: 'Gilroy',
                                            fontSize: 18.sp,
                                            color: const Color(0XFF00AFEE),
                                            fontWeight: FontWeight.w700)))
                              ],
                            ),
                          ),
                          RecentAddedList(
                            recentAdded: recentAdded,
                            toggleRecent: toggleRecent,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget generatepage() {
    return CarouselSlider.builder(
      options: CarouselOptions(
        autoPlay: false,
        enableInfiniteScroll: true,
        initialPage: 0,
        height: 150.0.h,
        enlargeCenterPage: false,
        viewportFraction: 0.84,
        onPageChanged: (index, reason) {
          homecontroller.onChange(index.obs);
        },
      ),
      itemBuilder: (BuildContext context, int index, int realIndex) {
        return Padding(
          padding: EdgeInsets.only(
              left: index == 0 ? 0.w : 12.w, right: index == 2 ? 12.w : 0.w),
          child: Container(
            height: 150.h,
            width: 322.w,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(pages[index].image!),
              ),
              // borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:  EdgeInsets.only(top: 20.h, left: 25.w, right: 110.w),
                  child: Text(
                    pages[index].title!,
                    style:  TextStyle(
                      fontFamily: 'Gilroy',
                        color: Color(0XFF000000),
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                 SizedBox(height: 29.sp),
                 Padding(
                  padding:  EdgeInsets.only(left: 25.w),
                  child: Text(
                    "Get Start",
                    style: TextStyle(
                        color: const Color(0XFF00AFEE),
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Gilroy',
                    fontSize: 18.sp),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      itemCount: pages.length,
    );
  }

  Widget indicator() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pages.length, (index) {
          return Padding(
            padding:  EdgeInsets.symmetric(horizontal: 6.w),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 10.h,
              width: 10.w,
              //margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 30),
              decoration: BoxDecoration(
                  // borderRadius: BorderRadius.circular(5),
                  color: (index == homecontroller.currentpage.value)
                      ? const Color(0XFF00AFEE)
                      : const Color(0XFFDEDEDE)),
            ),
          );
        }));
  }

  Widget design_list() {
    return Expanded(
      child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          primary: false,
          scrollDirection: Axis.horizontal,
          itemCount: design.length,
          itemBuilder: (BuildContext context, index) {
            return Stack(
              children: [Image(image: AssetImage(design[index].image!),height: 110.h,width: 110.h,)],
            );
          }),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // Widget horizontal_disidn() {
  //   return Container(
  //     //color: Colors.red,
  //     height: 100.h,
  //     width: double.infinity,
  //     child: ListView.builder(
  //         padding:  EdgeInsets.symmetric(horizontal: 20.w),
  //         shrinkWrap: true,
  //         primary: false,
  //         physics: const BouncingScrollPhysics(),
  //         scrollDirection: Axis.horizontal,
  //         itemCount: design.length,
  //         itemBuilder: (BuildContext context, index) {
  //           return Stack(
  //             alignment: Alignment.center,
  //             children: [
  //               Padding(
  //                 padding: EdgeInsets.only(left: index == 0 ? 0.w : 6.w),
  //                 child: Image(
  //                   image: AssetImage(design[index].image!),
  //                   height: 110.h,
  //                   width: 110.w,
  //                 ),
  //               ),
  //               Padding(
  //                 padding:  EdgeInsets.only(top: 60.h),
  //                 child: Text(
  //                   design[index].name!,
  //                   style:  TextStyle(
  //                       color: Color(0XFF000000),
  //                       fontSize: 14.sp,
  //                       fontFamily: 'Gilroy',
  //                       fontWeight: FontWeight.bold),
  //                 ),
  //               )
  //             ],
  //           );
  //         }),
  //   );
  // }
}

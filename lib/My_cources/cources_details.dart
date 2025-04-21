// ignore_for_file: non_constant_identifier_names


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/controller/controller.dart';
import 'package:learn_megnagmet/utils/slider_page_data_model.dart';

import '../models/my_cource.dart';

import '../utils/screen_size.dart';
import 'lesson_play.dart';
import 'ongoing_screen.dart';

class CourceDetail extends StatefulWidget {
  const CourceDetail({Key? key, required this.corcedetail}) : super(key: key);
  final OngoingCources corcedetail;

  @override
  State<CourceDetail> createState() => _CourceDetailState();
}

class _CourceDetailState extends State<CourceDetail> {
  List cource_detail = Utils.getCourceDetail();
  CourceDetailController courceDetailController =
      Get.put(CourceDetailController());

  @override
  void initState() {
    // cource_detail = Utils.getCourceDetail();
    cource_detail = cource_detail
        .where((element) => element.courceID == widget.corcedetail.id)
        .toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    initializeScreenSize(context);
    return Scaffold(
      body: GetBuilder(
          init: CourceDetailController(),
          builder: (courceDetailController) => Column(
            children: [
               SizedBox(height: 64.h),
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child:  Image(
                          image: AssetImage("assets/back_arrow.png"),
                          height: 24.h,
                          width: 24.w,
                        )),
                     SizedBox(width: 15.w),
                    Text(
                      "${widget.corcedetail.courceName}",
                      style:  TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 24.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: ListView.builder(
                    itemCount: cource_detail.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding:  EdgeInsets.only(
                            left: 20.w, right: 20.w, top: index==0?0.h:8.h, bottom: 8.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            index == 0
                                ? Padding(
                                    padding:  EdgeInsets.only(
                                      bottom: 20.h,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                         Text("Lesson 1 - Introducation",style: TextStyle(
                                            fontFamily:
                                            'Gilroy',
                                            color:
                                            Color(0XFF6E758A),
                                            fontSize: 15.sp,
                                        fontWeight: FontWeight.w700),),
                                        Container(
                                            height: 23.h,
                                            width: 53.w,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      22.h),
                                              color: const Color(0XFFE5ECFF),
                                            ),
                                            child:  Center(
                                              child: Text(
                                                "30 Min",
                                                style: TextStyle(
                                                    fontFamily:
                                                        'Gilroy',
                                                    color:
                                                        Color(0XFF00AFEE),
                                                    fontSize: 12.sp,

                                                    fontWeight: FontWeight.w700),
                                              ),
                                            ))
                                      ],
                                    ),
                                  )
                                : const SizedBox(),
                            index==3?Padding(
                              padding:  EdgeInsets.only(
                                bottom: 20.h,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                   Text("Lesson 2 - User Research",style: TextStyle(
                                      fontFamily:
                                      'Gilroy',
                                      color:
                                      Color(0XFF6E758A),
                                      fontSize: 15.sp,

                                      fontWeight: FontWeight.w700),),
                                  Container(
                                      height: 23.h,
                                      width: 53.w,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(
                                            22.h),
                                        color: const Color(0XFFE5ECFF),
                                      ),
                                      child:  Center(
                                        child: Text(
                                          "60 Min",
                                          style: TextStyle(
                                              fontFamily:
                                              'Gilroy',
                                              color:
                                              Color(0XFF00AFEE),
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ))
                                ],
                              ),
                            ):const SizedBox(),

                            Container(
                              height: 80.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22.h),
                                  boxShadow: [
                                    BoxShadow(
                                        color: const Color(0XFF00AFEE).withOpacity(0.14),
                                        offset: const Offset(-4, 5),
                                        blurRadius: 16),
                                  ],
                                  color: Colors.white),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                      height: 55.h,
                                      width: 33.w,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(22.h),
                                          color: const Color(0XFFE5ECFF)),
                                      child: Center(
                                        child: Text(
                                          "${cource_detail[index].lessonID}",
                                          style:  TextStyle(
                                              color: Color(0XFF00AFEE),
                                              fontSize: 15.sp,
                                              fontFamily: 'Gilroy',
                                              fontWeight:
                                                  FontWeight.w700),
                                        ),
                                      )),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                       SizedBox(height: 18.h),
                                      Text(
                                          cource_detail[index]
                                              .lessonName!,
                                          style:  TextStyle(
                                              color: Color(0XFF000000),
                                              fontSize: 14.sp,
                                              fontFamily: 'Gilroy',
                                              fontWeight:
                                                  FontWeight.w700)),
                                       SizedBox(height: 10.h),
                                      Text(cource_detail[index].time!,
                                          style:  TextStyle(
                                              color: Color(0XFF6E758A),
                                              fontSize: 14.sp,
                                              fontFamily: 'Gilroy',
                                            ))
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      index < 3
                                          ? GestureDetector(
                                              child: Image(
                                                image: AssetImage(
                                                    cource_detail[index]
                                                        .playIconImage!),
                                                height: 26.h,
                                                width: 26.w,
                                              ),
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            VidioPlay(
                                                                lessonplay:
                                                                    cource_detail[
                                                                        index])));
                                              },
                                            )
                                          : GestureDetector(
                                              child: Image(
                                                image: AssetImage(
                                                    cource_detail[index]
                                                        .lockImageImage!),
                                                height: 26.h,
                                                width: 26.w,
                                              ),
                                              onTap: () {
                                                Get.snackbar('error',
                                                    'This lesson is locked');
                                              },
                                            )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
              ),
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Padding(
                  padding:  EdgeInsets.only(bottom: 40.h, top: 15.h),
                  child: Container(
                    height: 56.h,
                    width: 374.w,
                    //color: Color(0XFF00AFEE),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.h),
                      color: const Color(0XFF00AFEE),
                    ),
                    child:  Center(
                      child: Text("Continue Course",
                          style: TextStyle(
                              color: Color(0XFFFFFFFF),
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Gilroy')),
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/cources/cources.dart';
import 'package:learn_megnagmet/models/trending_cource.dart';

class TrendingCourceList extends StatefulWidget {
  final List<Trending> trendingCource;
  final Function(int) toggle;

  const TrendingCourceList({
    Key? key,
    required this.trendingCource,
    required this.toggle,
  }) : super(key: key);

  @override
  State<TrendingCourceList> createState() => _TrendingCourceListState();
}

class _TrendingCourceListState extends State<TrendingCourceList> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 234.h,
      width: double.infinity.w,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        physics: const BouncingScrollPhysics(),
        primary: false,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (BuildContext context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: GestureDetector(
              onTap: () {
                Get.to(MyCources(trende: widget.trendingCource[index]));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 172.h,
                    width: 177.w,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(widget.trendingCource[index].image!),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.w, right: 147.w, bottom: 142.h),
                      child: Container(
                        height: 20.h,
                        width: 20.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              widget.toggle(index);
                            },
                            child: widget.trendingCource[index].buttonStatus == true
                                ? Image(
                              image: const AssetImage("assets/saveboldblue.png"),
                              height: 10.h,
                              width: 9.w,
                            )
                                : Image(
                              image: const AssetImage("assets/savebold.png"),
                              height: 10.h,
                              width: 9.w,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    widget.trendingCource[index].title!,
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                      color: const Color(0XFF000000),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    widget.trendingCource[index].subtitle!,
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                      color: const Color(0XFF000000),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
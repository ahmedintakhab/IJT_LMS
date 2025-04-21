import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/home/recent_added_cource_detail.dart';
import 'package:learn_megnagmet/models/recently_added.dart';

class RecentAddedList extends StatefulWidget {
  final List<Recent> recentAdded;
  final Function(int) toggleRecent;

  const RecentAddedList({
    Key? key,
    required this.recentAdded,
    required this.toggleRecent,
  }) : super(key: key);

  @override
  State<RecentAddedList> createState() => _RecentAddedListState();
}

class _RecentAddedListState extends State<RecentAddedList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0XFFFFFFFF),
      height: 323.h,
      width: double.infinity.w,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        physics: const BouncingScrollPhysics(),
        primary: false,
        shrinkWrap: true,
        itemCount: widget.recentAdded.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, index) {
          return GestureDetector(
            onTap: () {
              Get.to(RecentCourceDetail(corcedetail: widget.recentAdded[index]));
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Container(
                width: 276.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0XFF00AFEE).withOpacity(0.14),
                      offset: const Offset(-4, 5),
                      blurRadius: 16,
                    ),
                  ],
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 158.h,
                      width: 276.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: AssetImage(widget.recentAdded[index].image!),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(right: 230.w, bottom: 120.h, top: 10.h),
                        child: Container(
                          height: 20.h,
                          width: 20.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: IconButton(
                            splashRadius: 10,
                            onPressed: () {
                              widget.toggleRecent(index);
                            },
                            icon: Center(
                              child: widget.recentAdded[index].buttonStatus == true
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10.w, top: 10.h),
                          child: Container(
                            height: 25.h,
                            width: 58.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
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
                                  widget.recentAdded[index].review!,
                                  style: TextStyle(
                                    fontFamily: 'Gilroy',
                                    color: const Color(0XFFFFC403),
                                    fontSize: 15.sp,
                                  ),
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
                                widget.recentAdded[index].time!,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: const Color(0XFF000000),
                                  fontFamily: 'Gilroy',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 11.h),
                    Padding(
                      padding: EdgeInsets.only(left: 10.w, right: 10.w),
                      child: Text(
                        widget.recentAdded[index].title!,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                          color: const Color(0XFF000000),
                          fontFamily: 'Gilroy',
                        ),
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
                                image: AssetImage(widget.recentAdded[index].circleimage!),
                                height: 40.h,
                                width: 40.w,
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                widget.recentAdded[index].personname!,
                                style: TextStyle(
                                  fontFamily: 'Gilroy',
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0XFF00AFEE),
                                  fontSize: 15.sp,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 33.h,
                            width: 76.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0XFFE5ECFF),
                            ),
                            child: Center(
                              child: Text(
                                widget.recentAdded[index].price!,
                                style: TextStyle(
                                  color: const Color(0XFF00AFEE),
                                  fontFamily: 'Gilroy',
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
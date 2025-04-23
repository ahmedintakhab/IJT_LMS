import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class RecentAddedList extends StatefulWidget {
  final List<Map<String, dynamic>> recentAdded;
  final List<bool> buttonStatuses;
  final Function(int) toggleRecent;
  final bool isLoading;

  const RecentAddedList({
    Key? key,
    required this.recentAdded,
    required this.buttonStatuses,
    required this.toggleRecent,
    required this.isLoading,
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
      child: widget.isLoading
          ? Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          physics: const BouncingScrollPhysics(),
          primary: false,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: 3, // Show 3 shimmer items
          itemBuilder: (BuildContext context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Container(
                width: 276.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
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
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      height: 25.h,
                      width: 100.w,
                      color: Colors.white,
                      margin: EdgeInsets.only(left: 10.w),
                    ),
                    SizedBox(height: 11.h),
                    Container(
                      height: 20.h,
                      width: 200.w,
                      color: Colors.white,
                      margin: EdgeInsets.only(left: 10.w, right: 10.w),
                    ),
                    SizedBox(height: 11.h),
                    Container(
                      height: 40.h,
                      width: 250.w,
                      color: Colors.white,
                      margin: EdgeInsets.only(left: 10.w, right: 10.w),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        physics: const BouncingScrollPhysics(),
        primary: false,
        shrinkWrap: true,
        itemCount: widget.recentAdded.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, index) {
          final course = widget.recentAdded[index];
          return GestureDetector(
            onTap: () {
              // Get.to(RecentCourceDetail(corcedetail: course));
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
                          image: NetworkImage(course['image'] ?? ''),
                          fit: BoxFit.cover,
                          // errorBuilder: (context, error, stackTrace) {
                          //   return Container(
                          //     color: Colors.grey[200],
                          //     child: Icon(Icons.broken_image, size: 40.w),
                          //   );
                          // },
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: 230.w, bottom: 120.h, top: 10.h),
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
                              child: widget.buttonStatuses[index]
                                  ? Image.asset(
                                "assets/saveboldblue.png",
                                height: 10.h,
                                width: 9.w,
                              )
                                  : Image.asset(
                                "assets/savebold.png",
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
                        // Padding(
                        //   padding: EdgeInsets.only(left: 10.w, top: 10.h),
                        //   child: Container(
                        //     height: 25.h,
                        //     width: 58.w,
                        //     decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(20),
                        //       color: const Color(0XFFFAF4E1),
                        //     ),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //       children: [
                        //         Image.asset(
                        //           "assets/staricon.png",
                        //           height: 17.h,
                        //           width: 17.w,
                        //         ),
                        //         Text(
                        //           course['average_rating'] ?? '0.00',
                        //           style: TextStyle(
                        //             fontFamily: 'Gilroy',
                        //             color: const Color(0XFFFFC403),
                        //             fontSize: 15.sp,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // Padding(
                        //   padding: EdgeInsets.only(right: 5.w),
                        //   child: Row(
                        //     children: [
                        //       Image.asset(
                        //         "assets/clock.png",
                        //         height: 17.h,
                        //         width: 17.w,
                        //       ),
                        //       SizedBox(width: 4.w),
                        //       Text(
                        //         "00:00", // You can add duration from API if available
                        //         style: TextStyle(
                        //           fontSize: 15.sp,
                        //           color: const Color(0XFF000000),
                        //           fontFamily: 'Gilroy',
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.only(left: 10.w, right: 10.w),
                      child: Text(
                        course['title'] ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                          color: const Color(0XFF000000),
                          fontFamily: 'Gilroy',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.only(left: 10.w, right: 10.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Container(
                              //   height: 40.h,
                              //   width: 40.w,
                              //   decoration: const BoxDecoration(
                              //     shape: BoxShape.circle,
                              //     color: Colors.grey,
                              //   ),
                              //   // You can add author image here if available
                              // ),
                              SizedBox(width: 10.w),
                              Text(
                                course['author'] ?? '',
                                style: TextStyle(
                                  fontFamily: 'Gilroy',
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0XFF00AFEE),
                                  fontSize: 15.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                                course['price'] == "0.00"
                                    ? "Free"
                                    : "Rs. ${course['price']}",
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
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/cources/rating_row_widget.dart';
import 'package:learn_megnagmet/cources/review_dialog_box.dart';
import 'package:learn_megnagmet/models/riview_data.dart';
import 'package:learn_megnagmet/utils/slider_page_data_model.dart';
import '../controller/controller.dart';
import '../utils/screen_size.dart';

class ReviewPage extends StatefulWidget {
  final String courseId;
  final Map<String, dynamic> reviewData;

  const ReviewPage({Key? key, required this.reviewData, required this.courseId}) : super(key: key);

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  HomeController homecontroller = Get.put(HomeController());
  List<ReviewList> review = Utils.getReviewList();


  @override
  Widget build(BuildContext context) {
    print('check review data: ${widget.courseId}');
    initializeScreenSize(context);
    // Safely access review data
    Map<String, dynamic> reviewMap = {};
    if (widget.reviewData.isNotEmpty && widget.reviewData[0] is Map<String, dynamic>) {
      reviewMap = widget.reviewData[0];
    }

    return Scaffold(
      body: GetBuilder(
        init: HomeController(),
        builder: (controller) => Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Rating & Reviews",
                            style: TextStyle(
                                fontSize: 18.sp,
                                      fontFamily: 'Nastaleeq',
                                color: const Color(0XFF000000),
                                fontWeight: FontWeight.w500),
                          ),
                          Text("View All",
                              style: TextStyle(
                                  fontSize: 18.sp,
                                        fontFamily: 'Nastaleeq',
                                  color: const Color(0XFF000000))),
                        ],
                      ),
                      SizedBox(height: 15.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                reviewMap['average_rating']?.toString() ?? '0.0',
                                style: TextStyle(
                                          fontFamily: 'Nastaleeq',
                                    fontSize: 36.sp,
                                    color: const Color(0XFF000000),
                                    fontWeight: FontWeight.w700),
                              ),
                              Text(
                                "out of 5",
                                style: TextStyle(
                                          fontFamily: 'Nastaleeq',
                                    fontSize: 15.sp,
                                    color: Color(0XFF000000),
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              RatingRowWidget(
                                initialRating: 5,
                                itemCount: 5,
                                percent: (reviewMap['five_star_percentage'] ?? 0) / 100,
                              ),
                              SizedBox(height: 10.h),
                              RatingRowWidget(
                                initialRating: 4,
                                itemCount: 4,
                                percent: (reviewMap['four_star_percentage'] ?? 0) / 100,
                              ),
                              SizedBox(height: 10.h),
                              RatingRowWidget(
                                initialRating: 3,
                                itemCount: 3,
                                percent: (reviewMap['three_star_percentage'] ?? 0) / 100,
                              ),
                              SizedBox(height: 10.h),
                              RatingRowWidget(
                                initialRating: 2,
                                itemCount: 2,
                                percent: (reviewMap['two_star_percentage'] ?? 0) / 100,
                              ),
                              SizedBox(height: 10.h),
                              RatingRowWidget(
                                initialRating: 1,
                                itemCount: 1,
                                percent: (reviewMap['first_star_percentage'] ?? 0) / 100,
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Align(
                          child: Text(
                            '${reviewMap['total_user_reviews']} Reviews',
                            style: TextStyle(
                                      fontFamily: 'Nastaleeq',
                                fontSize: 14.sp,
                                color: Color(0XFF000000),
                                fontWeight: FontWeight.normal),
                          ),
                          alignment: Alignment.centerRight),
                      SizedBox(height: 12.h),

                      Row(
                        children: [
                          GestureDetector(onTap: (){
                            showDialog(context: context,
                              builder: (BuildContext context){
                                return WriteReviewDialog(courseId: widget.courseId); // Pass courseID here
                              }, );
                          },
                            child:Text(
                              "Write A Review",
                              style: TextStyle(
                                        fontFamily: 'Nastaleeq',
                                  fontSize: 18.sp,
                                  color: const Color(0XFF000000),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: reviewMap['user_reviews']?.length ?? 0,
                        itemBuilder: (context, index) {
                          final userReviews = reviewMap['user_reviews'];
                          if (userReviews == null) return const SizedBox.shrink();

                          final userReview = userReviews[index];
                          if (userReview == null) return const SizedBox.shrink();

                          return Padding(
                            padding: EdgeInsets.only(left: 15.5.w),
                            child: SizedBox(
                              height: 62.h,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: userReview['user_image'] != null
                                            ? Image.network(
                                          userReview['user_image'].toString(),
                                          height: 32.h,
                                          width: 32.w,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              height: 32.h,
                                              width: 32.w,
                                              color: Colors.grey[300],
                                              child: Icon(Icons.person, color: Colors.grey[600]),
                                            );
                                          },
                                        )
                                            : Container(
                                          height: 32.h,
                                          width: 32.w,
                                          color: Colors.grey[300],
                                          child: Icon(Icons.person, color: Colors.grey[600]),
                                        ),
                                      ),
                                      SizedBox(width: 15.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            if (userReview['user_name'] != null)
                                              Text(
                                                userReview['user_name'].toString(),
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: const Color(0XFF292929),
                                                        fontFamily: 'Nastaleeq',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            if (userReview['comment'] != null)
                                              Text(
                                                userReview['comment'].toString(),
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: const Color(0XFF292929),
                                                        fontFamily: 'Nastaleeq',
                                                  fontStyle: FontStyle.normal,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (userReview['created_at'] != null)
                                        Text(
                                          userReview['created_at'].toString(),
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Color(0XFF5E8421),
                                                  fontFamily: 'Nastaleeq',
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Spacer(),
            // Padding(padding: EdgeInsets.symmetric(horizontal: 20.w),
            //   // Using the footer with footerData
            //   child:  widget.reviewData.containsKey('footer_section')
            //       ? CourseFooter(footerData: widget.reviewData['footer_section'])
            //       : CourseFooter(), // Fallback to static data if API data not available
            // ),
            SizedBox(height: 30,)
          ],
        ),
      ),
    );
  }
}

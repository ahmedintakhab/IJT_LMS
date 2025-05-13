import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RatingRowWidget extends StatelessWidget {
  final double initialRating;
  final int itemCount;
  final double percent;

  const RatingRowWidget({
    Key? key,
    required this.initialRating,
    required this.itemCount,
    required this.percent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RatingBar.builder(
          initialRating: initialRating,
          glow: false,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: itemCount,
          itemSize: 10,
          itemPadding: EdgeInsets.symmetric(horizontal: 2.17.w),
          itemBuilder: (context, _) => const Icon(
            Icons.star_border,
            color: Color(0XFF78A03F),
          ),
          onRatingUpdate: (rating) {
            // Handle rating update
          },
        ),
        SizedBox(width: 10.w), // Add spacing if needed
        LinearPercentIndicator(
          width: 204.w,
          lineHeight: 4.h,
          percent: percent,
          backgroundColor: Colors.grey,
          progressColor: Colors.lightGreen,
        ),
      ],
    );
  }
}

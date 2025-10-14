import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LeaderboardContainer extends StatefulWidget {
  final List<dynamic>? meritList;
  const LeaderboardContainer({Key? key, this.meritList}) : super(key: key);

  @override
  State<LeaderboardContainer> createState() => _LeaderboardContainerState();
}

class _LeaderboardContainerState extends State<LeaderboardContainer> {
  @override
  Widget build(BuildContext context) {
    print('Check the meritlist data: ${widget.meritList}');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFFB300),
          borderRadius: BorderRadius.circular(8.0.r),
        ),
        padding: EdgeInsets.all(16.0.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Leaderboard',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16.h),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.meritList?.length ?? 0,
              itemBuilder: (context, index) {
                final data = widget.meritList![index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8.h),
                  padding: EdgeInsets.all(8.0.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 20.w,
                        child: Text(
                          data['position'].toString(),
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                      CircleAvatar(
                        radius: 20.r,
                        backgroundImage: NetworkImage(data['student_image']),
                      ),
                      SizedBox(
                        width: 80.w,
                        child: Text(
                          data['student_name'],
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                      SizedBox(
                        width: 70.w,
                        child: Text(
                          data['quiz_total_marks'],
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                      SizedBox(
                        width: 70.w,
                        child: Text(
                          data['obtained_marks'],
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.0.w, vertical: 4.0.h),
                        decoration: BoxDecoration(
                          color: data['status'] == 'Passed' ? Colors.green : Colors.redAccent,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          data['status'],
                          style: TextStyle(fontSize: 14.sp, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
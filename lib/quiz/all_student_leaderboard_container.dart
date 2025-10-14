import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AllStudentLeaderboardContainer extends StatelessWidget {
  final List<dynamic>? leaderboard;

  const AllStudentLeaderboardContainer({Key? key, this.leaderboard}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Check the all student quiz result data: $leaderboard');
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: leaderboard?.length ?? 0,
          itemBuilder: (context, index) {
            final data = leaderboard![index];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    data['position'].toString(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(data['student_image']),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        data['student_name'],
                        style: TextStyle(fontSize: 16.sp, color: Colors.blue),
                      ),
                    ],
                  ),
                  Text(
                    data['quiz_total_marks'].toString(),
                    style: TextStyle(fontSize: 16.sp, color: Colors.blue),
                  ),
                  Text(
                    data['obtained_marks'].toString(),
                    style: TextStyle(fontSize: 16.sp, color: Colors.blue),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
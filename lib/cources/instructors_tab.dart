import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Instructors extends StatelessWidget {
  final List<dynamic> instructorsData;

  const Instructors({Key? key, required this.instructorsData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                "Instructors",
                style: TextStyle(
                    fontFamily: 'Gilroy',
                    fontSize: 20.sp,
                    color: const Color(0XFF000000),
                    fontWeight: FontWeight.w700),
              ),
            ),
            ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: instructorsData.length,
                itemBuilder: (BuildContext context, int index) {
                  final instructor = instructorsData[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      top: index == 0 ? 0.h : 8.h,
                      bottom: index == instructorsData.length - 1 ? 0.h : 8.h,
                    ),
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22.h),
                            color: const Color(0XFFFFFFFF),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0XFF23408F).withOpacity(0.14),
                                blurRadius: 20.0.h,
                              ),
                            ]),
                        height: 95.h,
                        width: 374.w,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10.w, right: 10.w),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image(
                                  image: NetworkImage(instructor['image'] ?? ''),
                                  height: 71.h,
                                  width: 71.w),
                              SizedBox(width: 10.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    instructor['name'] ?? 'No Name',
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        color: const Color(0XFF000000),
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Gilroy'),
                                  ),
                                  Text(
                                    instructor['professional_title'] ?? '',
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        color: const Color(0XFF000000),
                                        fontFamily: 'Gilroy'),
                                  )
                                ],
                              )
                            ],
                          ),
                        )),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
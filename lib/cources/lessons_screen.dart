import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:learn_megnagmet/controller/controller.dart';
import 'package:learn_megnagmet/utils/slider_page_data_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/lesson.dart';
import '../utils/screen_size.dart';

class Lesson extends StatefulWidget {
  final List< dynamic> lessonsData;

  const Lesson({Key? key, required this.lessonsData}) : super(key: key);

  @override
  State<Lesson> createState() => _LessonState();
}

class _LessonState extends State<Lesson> {
  List<LessonList> lessonLists = Utils.getLesson();

  Widget build(BuildContext context) {
    print('Check lesson Data on lesson Screen: ${widget.lessonsData}');
    initializeScreenSize(context);
    return GetBuilder(
        init: HomeController(),
        builder: (controller) =>
            SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: widget.lessonsData.length,
                      itemBuilder: (BuildContext, index) {
                        var lesson = widget
                            .lessonsData[index]; // Get each lesson data
                        return Padding(
                          padding: EdgeInsets.only(top: index == 0 ? 0.h : 8.h,
                              bottom: 8.h,
                              left: 15.w,
                              right: 15.w),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.h),
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0XFF23408F).withOpacity(
                                        0.14),
                                    offset: const Offset(-4, 5),
                                    blurRadius: 16),
                              ],
                            ),
                            child: ExpansionTileCard(
                              trailing: Padding(
                                padding: EdgeInsets.only(right: 20.w),
                                child: Image.asset(
                                  "assets/down.png", height: 24.h,
                                  width: 24.w,
                                  color: Color(0XFF00AFEE),),
                              ),
                              animateTrailing: true,


                              // contentPadding: EdgeInsets.symmetric(
                              //     vertical: 5.h),
                              // borderRadius: BorderRadius.circular(22.h),
                              // leading: Image.asset(
                              //   lessonLists[index].image ?? 'assets/3rdlessondetail.png',
                              //   height: 66.h,
                              //   width: 66.w,
                              // ),

                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lesson['lesson_name'] ?? 'No Name',
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Color(0XFF000000),
                                        fontFamily: 'Nastaleeq',
                                        fontWeight: FontWeight.bold),
                                    textDirection: TextDirection.rtl,

                                  ),
                                  SizedBox(height: 4.h),
                                  Container(
                                    height: 20.h,
                                    width: 63.w,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            22.h),
                                        color: const Color(0XFF00AFEE)),
                                    child: Center(
                                        child: Text(
                                          'Lesson ${lesson['lesson_no']
                                              .toString()}',
                                          style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        )),
                                  ),
                                ],
                              ),
                              children: <Widget>[
                                Divider(
                                  thickness: 1.0,
                                  height: 1.0.h,
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16.0.w,
                                        vertical: 8.0.h
                                    ),
                                    child: lesson_detail(index),),
                                )
                              ],
                            ),
                          ),
                        );
                      }),

                ],
              ),
            ));
  }

  Widget lesson_detail(int index) {
    // Get the lectures data for the current lesson
    var lectures = widget.lessonsData[index]['lesson_lectures'] as List;

    return Column(
      children: List.generate(lectures.length, (lectureIndex) {
        var lecture = lectures[lectureIndex];

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Lecture icon with SVG support
                _buildLectureIcon(lecture['lecture_icon_src']),
                SizedBox(width: 10.w),

                Flexible(
                  child: Text(
                    lecture['lecture_title'] ?? 'No Title',
                    style: TextStyle(
                        fontSize: 14.sp, color: const Color(0XFF000000)),
                  ),
                ),
                SizedBox(width: 10.w),

                if (lecture['lecture_is'] == 'Locked')
                  Icon(
                    Icons.lock,
                    color: Colors.grey,
                    size: 20.h,
                  )
                else
                  if (lecture['lecture_is'] == 'Free')
                    Container(
                      width: 70,
                      height: 20,
                      child: ElevatedButton(
                        onPressed: () {
                          final url = lecture['lecture_preview_btn_src'];
                          if (url != null && url.isNotEmpty) {
                            launchUrl(Uri.parse(url));
                          } else {
                            print('Invalid or missing URL for lecture preview');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0XFF00AFEE),
                        ),
                        child: Text(
                          'Preview',
                          style: TextStyle(fontSize: 8.sp, color: Colors.white),
                        ),
                      ),
                    ),
              ],
            ),
            SizedBox(height: 5.h),
          ],
        );
      }),
    );
  }

  Future<String> _preprocessSvg(String svgUrl) async {
    try {
      final response = await http.get(Uri.parse(svgUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to load SVG');
      }

      String svgContent = response.body;

      // Fix rotation values using proper RegExp replacement
      svgContent =
          svgContent.replaceAll(RegExp(r'rotate\(\s*\d+deg\s*\)'), 'rotate(0)');
      svgContent = svgContent.replaceAllMapped(
          RegExp(r'(-?\d+)deg'),
              (match) => match.group(1) ?? '0'
      );

      return svgContent;
    } catch (e) {
      print('SVG Preprocessing Error: $e');
      rethrow;
    }
  }

  Widget _buildLectureIcon(String? iconUrl) {
    if (iconUrl == null || iconUrl.isEmpty) {
      return Icon(
        Icons.error,
        color: Colors.red,
        size: 20.h,
      );
    }

    if (iconUrl.toLowerCase().endsWith('.svg')) {
      return FutureBuilder<String>(
        future: _preprocessSvg(iconUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: 20.h,
              width: 20.w,
              child: const CircularProgressIndicator(color: Color(0XFF00AFEE),),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            print('SVG Loading Error: ${snapshot.error}');
            return Icon(
              Icons.error,
              color: Colors.red,
              size: 20.h,
            );
          }

          return SvgPicture.string(
            snapshot.data!,
            height: 20.h,
            width: 20.w,
            colorFilter: const ColorFilter.mode(
              Color(0XFF00AFEE),
              BlendMode.srcIn,
            ),
            theme: const SvgTheme(
              currentColor: Color(0XFF00AFEE),
              fontSize: 14,
              xHeight: 0,
            ),
          );
        },
      );
    } else {
      return Image.network(
        iconUrl,
        height: 20.h,
        width: 20.w,
        color: const Color(0XFF00AFEE),
        errorBuilder: (context, error, stackTrace) =>
            Icon(
              Icons.error,
              color: Colors.red,
              size: 20.h,
            ),
      );
    }
  }
}
















// import 'package:expansion_tile_card/expansion_tile_card.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:learn_megnagmet/controller/controller.dart';
// import 'package:learn_megnagmet/utils/slider_page_data_model.dart';
//
// import '../models/lesson.dart';
// import '../utils/screen_size.dart';
// import '../widget/button.dart';
//
// class Lesson extends StatefulWidget {
//   const Lesson({Key? key}) : super(key: key);
//
//   @override
//   State<Lesson> createState() => _LessonState();
// }
//
// class _LessonState extends State<Lesson> {
//   List<LessonList> lessonLists = Utils.getLesson();
//
//   Widget build(BuildContext context) {
//     initializeScreenSize(context);
//     return GetBuilder(
//         init: HomeController(),
//         builder: (controller) => SingleChildScrollView(
//               child: Column(
//                 children: [
//                   ListView.builder(
//                       physics: const NeverScrollableScrollPhysics(),
//                       scrollDirection: Axis.vertical,
//                       shrinkWrap: true,
//                       itemCount: lessonLists.length,
//                       itemBuilder: (BuildContext, index) {
//                         return Padding(
//                           padding:  EdgeInsets.only(top:index==0?0.h: 8.h,bottom: 8.h,left: 15.w,right: 15.w),
//                           child: Container(
//                             width: double.infinity,
//                             decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(12.h),
//                                 boxShadow: [
//                                   BoxShadow(
//                                       color: const Color(0XFF00AFEE).withOpacity(0.14),
//                                       offset: const Offset(-4, 5),
//                                       blurRadius: 16),
//                                 ],
//                                ),
//                             child: ExpansionTileCard(
//                               trailing:Padding(
//                                 padding:  EdgeInsets.only(right: 20.w),
//                                 child: Image.asset("assets/down.png",height: 24.h,width: 24.w),
//                               ),
//                               animateTrailing: true,
//
//
//
//                               contentPadding: EdgeInsets.symmetric(vertical: 5.h),
//                               borderRadius: BorderRadius.circular(22.h),
//                               leading: Image.asset(
//                                 lessonLists[index].image!,
//                                 height: 66.h,
//                                 width: 66.w,
//                               ),
//
//                               title: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     lessonLists[index].title!,
//                                     style:  TextStyle(
//                                         fontSize: 14.sp,
//                                         color: Color(0XFF000000),
//                                         fontFamily: 'Gilroy',
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                    SizedBox(height: 4.h),
//                                   Container(
//                                     height: 20.h,
//                                     width: 63.w,
//                                     decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(22.h),
//                                         color: const Color(0XFFE5ECFF)),
//                                     child: Center(
//                                         child: Text(
//                                       lessonLists[index].buttonName!,
//                                       style:  TextStyle(
//                                           fontSize: 12.sp,
//                                           fontWeight: FontWeight.bold,
//                                           color: const Color(0XFF00AFEE)),
//                                     )),
//                                   ),
//                                 ],
//                               ),
//                               children: <Widget>[
//                                  Divider(
//                                   thickness: 1.0,
//                                   height: 1.0.h,
//                                 ),
//                                 Align(
//                                   alignment: Alignment.centerLeft,
//                                   child: Padding(
//                                       padding:  EdgeInsets.symmetric(
//                                         horizontal: 16.0.w,
//                                         vertical: 8.0.h
//                                       ),
//                                       child: lesson_detail(index),),
//                                 )
//                               ],
//                             ),
//                           ),
//                         );
//                       }),
//
//                 ],
//               ),
//             ));
//   }
//
//
//
//   Widget lesson_detail(int index) {
//     return Column(
//       children: [
//         Column(
//           children: [
//             Row(
//               children: [
//                 Image.asset(
//                     lessonLists[index]
//                         .detailicon1!,
//                     height: 20.h,
//                     width: 20.w),
//                  SizedBox(width: 10.w),
//                 Flexible(
//                     child: Text(
//                       lessonLists[index]
//                           .detail1st!,
//                       style:  TextStyle(
//                           fontSize: 14.sp,
//                           color:
//                           Color(0XFF000000)),
//                     )),
//                  SizedBox(width: 10.w),
//                 Text(
//                   "${lessonLists[index].detail1stscore}",
//                   style:  TextStyle(
//                       fontSize: 14.sp,
//                       color:
//                       Color(0XFF00AFEE)),
//                 )
//               ],
//             ),
//              SizedBox(height: 5.h),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//
//                 Image.asset(
//                     lessonLists[index]
//                         .detailicon2!,
//                     height: 20.h,
//                     width: 20.w),
//                  SizedBox(width: 10.w),
//                 Flexible(
//                     child: Text(
//                         lessonLists[index]
//                             .detail2nd!)),
//                  SizedBox(width: 120.w),
//                 Text(
//                     "${lessonLists[index].detail2ndscore}")
//               ],
//             ),
//              SizedBox(height: 5.h),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Image.asset(
//                     lessonLists[index]
//                         .detailicon3!,
//                     height: 20.h,
//                     width: 20.w),
//                  SizedBox(width: 10.w),
//                 Flexible(
//                     child: Text(
//                         lessonLists[index]
//                             .detail3rd!)),
//                  SizedBox(width: 120.w),
//                 Text(
//                     "${lessonLists[index].detail3rdscore}")
//               ],
//             ),
//              SizedBox(height: 5.h),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Image.asset(
//                     lessonLists[index]
//                         .detailicon4!,
//                     height: 20.h,
//                     width: 20.w),
//                  SizedBox(width: 10.w),
//                 Flexible(
//                     child: Text(
//                         lessonLists[index]
//                             .detail4th!)),
//                  SizedBox(width: 110.w),
//                 Text(
//                     "${lessonLists[index].detail4thscore}")
//               ],
//             ),
//           ],
//         )
//       ],
//     );
//   }
// }

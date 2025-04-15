import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/controller/controller.dart';
import 'package:learn_megnagmet/utils/slider_page_data_model.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../utils/screen_size.dart';
import 'cources_details.dart';

class OngoingScreen extends StatefulWidget {
  const OngoingScreen({Key? key}) : super(key: key);

  @override
  State<OngoingScreen> createState() => _OngoingScreenState();
}

class _OngoingScreenState extends State<OngoingScreen> {
  OngoingController ongoingController = Get.put(OngoingController());
  List ongoingCource = Utils.getOngoingCource();

  @override
  Widget build(BuildContext context) {
    initializeScreenSize(context);
    return GetBuilder(
        init: OngoingController(),
        builder: (OngoingController) => ListView.builder(

            itemCount: ongoingCource.length,
            itemBuilder: (context, index) {
              return Padding(
                padding:  EdgeInsets.only(
                    top: 8.h, bottom: 8.h, right: 15.w, left: 15.w),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CourceDetail(
                                corcedetail:
                                    ongoingCource[index])));
                  },
                  child: Container(
                    height: 124,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0XFF23408F)
                                  .withOpacity(0.14),
                              offset: const Offset(-4, 5),
                              blurRadius: 16),
                        ],
                        color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10),
                      child: Row(
                        children: [
                          Image(
                            image: AssetImage(
                                ongoingCource[index].courceImage),
                            height: 100,
                            width: 100,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                ongoingCource[index].courceName,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Gilroy',
                                    fontStyle: FontStyle.normal),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "8 Lesson to go",
                                style: TextStyle(
                                    color: Color(0XFF292929)),
                              ),
                              const SizedBox(height: 15),
                              LinearPercentIndicator(
                                padding: EdgeInsets.zero,
                                width: 202.0,
                                lineHeight: 6.0,
                                percent: 0.5,
                                trailing: Padding(
                                  padding:  EdgeInsets.only(left: 4.w),
                                  child: Text("50%",style: TextStyle(fontFamily: 'Gilroy',fontSize: 14,fontWeight: FontWeight.w400),),
                                ),
                                backgroundColor:
                                    const Color(0XFFDEDEDE),
                                progressColor:
                                    const Color(0XFF23408F),
                                barRadius:
                                    const Radius.circular(22),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }));
  }
}

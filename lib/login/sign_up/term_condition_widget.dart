import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learn_megnagmet/login/sign_up/term_and_condition.dart';

class TermConditionCheckbox extends StatefulWidget {
  const TermConditionCheckbox({Key? key}) : super(key: key);

  @override
  _TermConditionCheckboxState createState() => _TermConditionCheckboxState();
}

class _TermConditionCheckboxState extends State<TermConditionCheckbox> {
  bool ischeaked = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          activeColor: const Color(0XFF00AFEE),
          side: const BorderSide(color: Color(0XFFDEDEDE)),
          value: ischeaked,
          onChanged: (value) {
            setState(() {
              ischeaked = value!;
            });
          },
        ),
        RichText(
          text: TextSpan(
            text: 'I Agree with ',
            style: TextStyle(
              color: Colors.black,
              fontSize: 15.sp,
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w400,
            ),
            children: [
              TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Get.to(const TermCondition());
                  },
                text: 'Terms and condition',
                style: const TextStyle(
                  color: Color(0XFF00AFEE),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Gilroy',
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextContentScreen extends StatelessWidget {
  final String title;
  final String htmlContent;

  const TextContentScreen({
    Key? key,
    required this.title,
    required this.htmlContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00AFEE),
        title: Directionality(
          textDirection: TextDirection.rtl,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Nastaleeq',
                fontSize: 26.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Html(
            data: htmlContent,
            style: {
              // Ensure spans use Nastaleeq font and RTL
              'span': Style(
                fontFamily: 'Nastaleeq',
                textAlign: TextAlign.right,
              ),
              // Ensure paragraphs are RTL
              'p': Style(
                textAlign: TextAlign.right,
              ),
            },
          ),
        ),
      ),
    );
  }
}
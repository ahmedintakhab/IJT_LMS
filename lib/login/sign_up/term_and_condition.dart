import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/screen_size.dart';
import '../../utils/api_constant.dart';

class TermCondition extends StatefulWidget {
  const TermCondition({Key? key}) : super(key: key);

  @override
  State<TermCondition> createState() => _TermConditionState();
}

class _TermConditionState extends State<TermCondition> {
  bool isLoading = true;
  String pageTitle = "";
  String description = "";

  @override
  void initState() {
    super.initState();
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ Check if cached data exists
    if (prefs.containsKey("terms_conditions")) {
      final cachedData = json.decode(prefs.getString("terms_conditions")!);
      setState(() {
        pageTitle = cachedData["pageTitle"] ?? "Terms & Conditions";
        description = cachedData["description"] ?? "";
        isLoading = false;
      });
    } else {
      // ❌ No cache → call API
      await _fetchTermsFromApi();
    }
  }

  Future<void> _fetchTermsFromApi() async {
    try {
      final response =
      await http.get(Uri.parse('${ApiConstant.baseUrl}terms-conditions'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print("Term and conditions api respose: ${response.statusCode}");

        if (jsonData['success'] == true) {
          final data = jsonData['data'];
          print("Term and conditions api data: $data");
          final parsedDescription =
          _parseHtmlString(data['policy']['description'] ?? "");

          setState(() {
            pageTitle = data['pageTitle'] ?? "Terms & Conditions";
            description = parsedDescription;
            isLoading = false;
          });

          // ✅ Save to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            "terms_conditions",
            json.encode({
              "pageTitle": pageTitle,
              "description": description,
            }),
          );
        } else {
          setState(() {
            description = "Failed to fetch Terms & Conditions.";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          description = "Error: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        description = "Something went wrong: $e";
        isLoading = false;
      });
    }
  }

  // helper function: strip HTML
  String _parseHtmlString(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text ?? "";
  }

  @override
  Widget build(BuildContext context) {
    initializeScreenSize(context);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 20.w, right: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30.h),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Image(
                    image: const AssetImage("assets/back_arrow.png"),
                    height: 24.h,
                    width: 24.w,
                  ),
                ),
                SizedBox(width: 15.w),
                Text(
                  pageTitle.isNotEmpty ? pageTitle : "Terms & Conditions",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 31.h),
            isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00AFEE),))
                : Expanded(
              child: SingleChildScrollView(
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w400,
                    color: const Color(0XFF6E758A),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

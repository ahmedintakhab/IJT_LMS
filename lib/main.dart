import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/splash/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

        theme:  ThemeData(
          fontFamily: 'Nastaleeq',
            scaffoldBackgroundColor: const Color(0xFFF5F5F5)),
    home: Directionality(
    textDirection: TextDirection.rtl, // Force Right-to-Left
    child: const Splashscreen(),
    )
    );
  }
}

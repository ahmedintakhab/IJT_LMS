import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/controller/controller.dart';
import 'package:learn_megnagmet/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../My_cources/my_learning_courses.dart';
import '../My_cources/ongoing_completed_main_screen.dart';
import '../chate/chate_screen.dart';
import '../instructor/instructor_dashboard.dart';
import '../profile/my_profile.dart';
import '../utils/slider_page_data_model.dart';

class HomeMainScreen extends StatefulWidget {
  const HomeMainScreen({Key? key}) : super(key: key);

  @override
  State<HomeMainScreen> createState() => _HomeMainScreenState();
}

class _HomeMainScreenState extends State<HomeMainScreen> {
  // int currentvalue = 0;
  List userDetail = Utils.getUser();

  HomeMainController controller = Get.put(HomeMainController());
  String role = '';
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final roleValue = prefs.getString('role');

    print('Loaded role from SharedPreferences: $roleValue'); // Debug

    setState(() {
      role = roleValue ?? "0"; // Default to "0" if null
    });
  }


  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeMainController>(
      init: HomeMainController(),
      builder: (controller) => Scaffold(
        body: _body(),
        bottomNavigationBar: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(22), topLeft: Radius.circular(22)),
              boxShadow: [
                BoxShadow(
                    color: const Color(0XFF00AFEE).withOpacity(0.12),
                    spreadRadius: 0,
                    blurRadius: 12),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22.0),
                topRight: Radius.circular(22.0),
              ),
              child: BottomNavigationBar(
                  backgroundColor: const Color(0XFFFFFFFF),
                  currentIndex: controller.position.value,
                  onTap: (index) {
                    // setState(() {
                    //   currentvalue = index;
                    // });
                    controller.onChange(index);
                  },
                  type: BottomNavigationBarType.fixed,
                items: [
              BottomNavigationBarItem(
              activeIcon: Column(
              children: [
                Icon(
                Icons.home,
                size: 24,
                color: Color(0XFF00AFEE),),
                SizedBox(height: 8.79),
                Container(
                  height: 1.75,
                  width: 24,
                  color: Color(0XFF00AFEE),)
                  ],
                ),
                icon: Icon(
                    Icons.home_outlined,
                    size: 24,
                    color: Colors.black), // Inactive color
                label: '',
              ),
              BottomNavigationBarItem(
                activeIcon: Column(
                  children: [
                    Icon(
                        Icons.menu_book,
                        size: 24,
                        color: Color(0XFF00AFEE)),
                    SizedBox(height: 8.79),
                    Container(
                        height: 1.75,
                        width: 24,
                        color: Color(0XFF00AFEE)),
                  ],
                ),
                icon: Icon(
                    Icons.menu_book_outlined,
                    size: 24,
                    color: Colors.black),
                label: '',
              ),
              BottomNavigationBarItem(
                activeIcon: Column(
                  children: [
                    Icon(
                        Icons.message,
                        size: 24,
                        color: Color(0XFF00AFEE)),
                    SizedBox(height: 8.79),
                    Container(
                        height: 1.75,
                        width: 24,
                        color: Color(0XFF00AFEE)),
                  ],
                ),
                icon: Icon(
                    Icons.message_outlined,
                    size: 24,
                    color: Colors.black),
                label: '',
              ),
              BottomNavigationBarItem(
                activeIcon: Column(
                  children: [
                    Icon(
                        Icons.person,
                        size: 24,
                        color: Color(0XFF00AFEE)),
                    SizedBox(height: 8.79),
                    Container(
                        height: 1.75,
                        width: 24,
                        color: Color(0XFF00AFEE)),
                  ],
                ),
                icon: Icon(
                    Icons.person_outline,
                    size: 24,
                    color: Colors.black),
                label: '',
              ),
              ],
              ),
            )),
      ),
    );
  }

  _body() {
    switch (controller.position.value) {
      case 0:
        //return Center(child: Container(child: Text("1")));
        return HomeScreen();
      case 1:
        //return Center(child: Container(child: Text("2")));
        return const MyLearningCourses();
    // return const OngoingCompletedScreen();
      case 2:
        //return Center(child: Container(child: Text("3")));
        return const ChateScreen();
      case 3:
// Check the role and navigate accordingly
        if (role == '2') {
          return InstructorPanel(user_detail: userDetail[0],); // Make sure to import InstructorPanel
        } else if (role == '3') {
          return MyProfile(user_detail: userDetail[0]);
        } else {
          // Default case if role doesn't match
          return const Center(
            child: Text("Access not available for your role"),
          );
        }      default:
        return const Center(
          child: Text("inavalid"),
        );
    }
  }
}

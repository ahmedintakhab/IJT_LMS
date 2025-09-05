import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learn_megnagmet/controller/controller.dart';
import 'package:learn_megnagmet/home/home_screen.dart';
import 'package:learn_megnagmet/login/login_empty_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../My_cources/my_learning_courses.dart';
import '../instructor/instructor_dashboard.dart';
import '../profile/my_profile.dart';
import '../utils/slider_page_data_model.dart';

class HomeMainScreen extends StatefulWidget {
  const HomeMainScreen({Key? key}) : super(key: key);

  @override
  State<HomeMainScreen> createState() => _HomeMainScreenState();
}

class _HomeMainScreenState extends State<HomeMainScreen> {
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
    print('Loaded role from SharedPreferences: $roleValue');
    setState(() {
      role = roleValue ?? "0"; // Default to "0" if null
    });
  }

  Future<void> _handleNavigation(int index) async {
    final validIndex = index.clamp(0, 2); // Now max index is 2
    if (validIndex  == 2) { // Profile tab (person_outline)
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';
      if (token.isEmpty) {
        // Store redirect information for profile tab
        await prefs.setString('redirect_after_login', 'ProfileTab');
        Get.to(() => const EmptyState());
        return;
      }
      // Reload role before navigating to profile tab to ensure it's up-to-date
      await _loadUserData();
    }
    controller.onChange(index);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeMainController>(
      init: HomeMainController(),
      builder: (controller) => Scaffold(
        body: _body(),
        bottomNavigationBar: Container(
          height: 75,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(22),
              topLeft: Radius.circular(22),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0XFF00AFEE).withOpacity(0.12),
                spreadRadius: 0,
                blurRadius: 12,
              ),
            ],
          ),
          child: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 15.0,
            color: Colors.white,
            child: SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Courses Tab
                  Expanded(
                    child: InkWell(
                      onTap: () => _handleNavigation(1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.menu_book,
                            color: controller.position.value == 1
                                ? const Color(0XFF00AFEE)
                                : Colors.black,
                          ),
                          Text(
                            "Courses",
                            style: TextStyle(
                              color: controller.position.value == 1
                                  ? const Color(0XFF00AFEE)
                                  : Colors.black,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 80), // space for FAB
                  // Profile Tab
                  Expanded(
                    child: InkWell(
                      onTap: () => _handleNavigation(2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person,
                            color: controller.position.value == 2
                                ? const Color(0XFF00AFEE)
                                : Colors.black,
                          ),
                          Text(
                            "Profile",
                            style: TextStyle(
                              color: controller.position.value == 2
                                  ? const Color(0XFF00AFEE)
                                  : Colors.black,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _handleNavigation(0),
          backgroundColor: const Color(0XFF00AFEE),
          child: const Icon(Icons.home, color: Colors.white),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _body() {
    switch (controller.position.value) {
      case 0:
        return HomeScreen();
      case 1:
        return const MyLearningCourses();
      // case 2:
      //   return const ChateScreen();
      case 2:
        if (role == '2') {
          return InstructorPanel(user_detail: userDetail.isNotEmpty ? userDetail[0] : {});
        } else if (role == '3') {
          return MyProfile(user_detail: userDetail.isNotEmpty ? userDetail[0] : {});
        } else {
          return const Center(child: Text("Access not available for your role"));
        }
      default:
        return const Center(child: Text("Invalid"));
    }
  }
}
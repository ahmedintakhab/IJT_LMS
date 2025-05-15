// live_class_page.dart
import 'package:flutter/material.dart';
import 'package:learn_megnagmet/student/past_live_class.dart';
import 'package:learn_megnagmet/student/upcoming_live_class.dart';
import 'current_live_class.dart';


class LiveClassPage extends StatelessWidget {
  final Map<String, dynamic> liveClassData;

  const LiveClassPage({Key? key, required this.liveClassData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      initialIndex: 0, // Default selected tab (Upcoming)
      child: Column(
        children: [
          SizedBox(height: 10,),

          // Scrollable TabBar
          Container(
            color: Colors.white,
            child: TabBar(
              tabAlignment: TabAlignment.center,
              labelPadding: EdgeInsets.symmetric(horizontal: 30),
              labelStyle: TextStyle(fontSize: 16),
              isScrollable: true, // Make the TabBar scrollable
              labelColor: Color(0xFF00AFEE), // Text color of the selected tab
              unselectedLabelColor: Colors.grey, // Text color of unselected tabs
              indicatorColor: const Color(0XFF00AFEE), // Indicator color
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 5,
              tabs: const [
                Tab(text: 'Upcoming'), // First tab
                Tab(text: 'Current'), // Second tab
                Tab(text: 'Past'), // Third tab
              ],
            ),
          ),
          // TabBarView to display the corresponding screens
          Expanded(
            child: TabBarView(
              children: [
                UpcomingScreen(), // Screen for Upcoming tab
                CurrentScreen(), // Screen for Current tab
                PastScreen(), // Screen for Past tab
              ],
            ),
          ),
        ],
      ),
    );
  }
}


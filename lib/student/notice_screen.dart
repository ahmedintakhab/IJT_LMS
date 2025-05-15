import 'package:flutter/material.dart';

class NoticePage extends StatelessWidget {
  final List<dynamic> noticeData;

  const NoticePage({Key? key, required this.noticeData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print("Check the notice data: $noticeData");
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Notice Board',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E), // Dark blue color
                ),
              ),
              const SizedBox(height: 20),
              // Notice List
              Expanded(
                child: ListView.builder(
                  itemCount: noticeData.length,
                  itemBuilder: (context, index) {
                    final notice = noticeData[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0), // Light orange background
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  notice['notice_topic'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            notice['notice_details'],
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            notice['created_at'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // const CourseFooter(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OverviewPage extends StatelessWidget {
  final Map<String, dynamic> overviewData;

  const OverviewPage({Key? key, required this.overviewData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract description and key points
    final String description = overviewData['description']?.toString() ?? '';
    final List<dynamic> keyPoints = overviewData['key_points'] ?? [];

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Key Points from API
            if (keyPoints.isNotEmpty)
              ...keyPoints.map((point) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)), // Bullet point
                    Expanded(
                      child: Text(
                        point['name']?.toString() ?? '',
                        style: TextStyle(fontSize: 22.sp),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
              )).toList(),
            if (keyPoints.isEmpty)
              const Text(
                'No key points available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            const SizedBox(height: 20),

            // Expandable Description
            ExpandableText(
              description,
              expandText: 'Learn more',
              collapseText: 'Learn less',
              maxLines: 5,
              linkColor: Colors.blue,
              style: TextStyle(
                fontSize: 18.sp,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 20), // Added space instead of Spacer
          ],
        ),
      ),
    );
  }
}
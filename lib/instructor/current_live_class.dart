import 'package:flutter/material.dart';

class CurrentLiveScreen extends StatelessWidget {
  final List<Map<String, dynamic>> classes;

  const CurrentLiveScreen({super.key, required this.classes});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Current Screen - To be implemented'),
    );
  }
}

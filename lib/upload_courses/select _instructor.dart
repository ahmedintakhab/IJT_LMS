import 'package:flutter/material.dart';
import 'package:learn_megnagmet/widget/custom_dropdown.dart';
import 'package:learn_megnagmet/widget/button.dart';

class InstructorsScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback? onBack;

  const InstructorsScreen({super.key, required this.onComplete, this.onBack});

  @override
  State<InstructorsScreen> createState() => _InstructorsScreenState();
}

class _InstructorsScreenState extends State<InstructorsScreen> {
  List<String> selectedInstructors = [];
  List<String> availableInstructors = [
    'Instructor 1',
    'Instructor 2',
    'Instructor 3',
    'Instructor 4',
    'Instructor 5'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text(
              'Instructors',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add course instructors information',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            // Updated dropdown with chips
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0XFFDEDEDE), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedInstructors.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedInstructors
                          .map((instructor) => Chip(
                        label: Text(instructor),
                        onDeleted: () {
                          setState(() {
                            selectedInstructors.remove(instructor);
                          });
                        },
                      ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  CustomDropdown(
                    hint: 'Select Instructors',
                    value: null,
                    items: availableInstructors
                        .where((instructor) => !selectedInstructors.contains(instructor))
                        .toList(),
                    onChanged: (value) {
                      if (value != null && !selectedInstructors.contains(value)) {
                        setState(() {
                          selectedInstructors.add(value);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Fixed buttons at the bottom
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 100,
                    child: CustomButton(
                      onTap: () {
                        if (widget.onBack != null) {
                          widget.onBack!();
                        }
                      },
                      buttonText: 'Back',
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: CustomButton(
                      onTap: widget.onComplete,
                      buttonText: 'Save and Continue',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
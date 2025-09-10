import 'package:flutter/material.dart';
import 'package:learn_megnagmet/upload_courses/select%20_instructor.dart';
import 'package:learn_megnagmet/upload_courses/submit_process.dart';
import 'package:learn_megnagmet/upload_courses/add_lesson_screen.dart';
import 'package:learn_megnagmet/upload_courses/upload_lesson_screen.dart';
import 'add_lecture_screen.dart';
import 'upload_course_details.dart';
import 'upload_course_category_tags.dart';

class UploadCourseScreen extends StatefulWidget {
  const UploadCourseScreen({super.key});

  @override
  State<UploadCourseScreen> createState() => _UploadCourseScreenState();
}

class _UploadCourseScreenState extends State<UploadCourseScreen> {
  int _currentStep = 0; // Default to first step
  bool _isCategoryStep = false; // Track if we are in "Category & Tags"
  int _lessonSubStep = 0; // Track sub-steps for Step 2 (0: Add Lesson, 1: Upload Lesson, 2: Add Lecture)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Progress Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 24.0),
            margin: const EdgeInsets.all(6.0),
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
            child: Stack(
              children: [
                // Full width connector line
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 2,
                    color: Colors.grey[300],
                  ),
                ),
                // Active progress line
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    width: _getProgressWidth(context),
                    height: 2,
                    color: const Color(0xFF00BCD4),
                  ),
                ),
                // Step indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStep(0, 'Course Overview'),
                    _buildStep(1, 'Upload Video'),
                    _buildStep(2, 'Instructors'),
                    _buildStep(3, 'Submit Process'),
                  ],
                ),
              ],
            ),
          ),
          // Content area
          Expanded(
            child: _buildStepContent(_currentStep),
          ),
        ],
      ),
    );
  }

  double _getProgressWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth - 72; // Account for container margins
    final stepWidth = 40;
    final availableWidth = containerWidth - (stepWidth * 2); // Space between first and last step centers

    if (_currentStep == 0 && _isCategoryStep) return availableWidth * 0.33;
    if (_currentStep == 1 && _lessonSubStep < 3) return availableWidth * 0.33;
    switch (_currentStep) {
      case 0:
        return 0;
      case 1:
        return _lessonSubStep == 3 ? availableWidth * 0.66 : availableWidth * 0.33;
      case 2:
        return availableWidth * 0.66;
      case 3:
        return availableWidth;
      default:
        return 0;
    }
  }

  Widget _buildStep(int step, String label) {
    final isCompleted = step < _currentStep || (step == 0 && _isCategoryStep) || (step == 1 && _lessonSubStep == 3);
    final isCurrent = (step == _currentStep && !_isCategoryStep && _lessonSubStep == 0) || (step == 0 && _isCategoryStep) || (step == 1 && _lessonSubStep > 0 && _lessonSubStep < 3);
    final isFuture = step > _currentStep && !(step == 0 && _isCategoryStep) && !(step == 1 && _lessonSubStep == 3);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? const Color(0xFF00BCD4)
                : isCurrent
                ? Colors.white
                : Colors.white,
            border: Border.all(
              color: isCompleted || isCurrent
                  ? const Color(0xFF00BCD4)
                  : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 20,
            )
                : Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent
                    ? const Color(0xFF00BCD4)
                    : Colors.transparent,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isCompleted || isCurrent
                  ? const Color(0xFF00BCD4)
                  : Colors.grey[400],
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        if (!_isCategoryStep) {
          return UploadCourseDetails(
            onComplete: () {
              setState(() {
                _isCategoryStep = true;
              });
            },
            onBack: () {},
          );
        } else {
          return UploadCourseCategoryTags(
            onComplete: () {
              setState(() {
                _isCategoryStep = false;
                _currentStep = 1;
                _lessonSubStep = 0; // Reset to first lesson sub-step
              });
            },
            onBack: () {
              setState(() {
                _isCategoryStep = false;
              });
            },
          );
        }
      case 1:
        if (_lessonSubStep == 0) {
          return AddLessonScreen(
            onComplete: () {
              setState(() {
                _lessonSubStep = 1; // Move to Upload Lesson
              });
            },
            onBack: () {
              setState(() {
                _currentStep = 0; // Move back to Category
              });
            },
          );
        } else if (_lessonSubStep == 1) {
          return UploadLessonScreen(
            onComplete: () {
              setState(() {
                _lessonSubStep = 2; // Move to Add Lecture
              });
            },
            onBack: () {
              setState(() {
                _lessonSubStep = 0; // Move back to Add Lesson
              });
            },
          );
        } else if (_lessonSubStep == 2) {
          return AddLectureScreen(
            onComplete: () {
              setState(() {
                _currentStep = 2; // Move to Instructors
                _lessonSubStep = 0; // Reset for next time
              });
            },
            onBack: () {
              setState(() {
                _lessonSubStep = 1; // Move back to Upload Lesson
              });
            },
          );
        }
      case 2:
        return InstructorsScreen(
          onComplete: () => setState(() => _currentStep = 3),
          onBack: () => setState(() => _currentStep = 1),
        );
      case 3:
        return SubmitProcessScreen(
          onSubmit: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Course Submitted Successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
          onBack: () => setState(() => _currentStep = 2),
        );
      default:
        return const SizedBox.shrink();
    }
    return const SizedBox.shrink(); // Fallback return to guarantee non-null Widget

  }
}
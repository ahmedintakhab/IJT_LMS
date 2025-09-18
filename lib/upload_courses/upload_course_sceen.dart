import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learn_megnagmet/upload_courses/select%20_instructor.dart';
import 'package:learn_megnagmet/upload_courses/submit_process.dart';
import 'package:learn_megnagmet/upload_courses/add_lesson_screen.dart';
import 'package:learn_megnagmet/upload_courses/upload_lesson_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_lecture_screen.dart';
import 'upload_course_details.dart';
import 'upload_course_category_tags.dart';

class UploadCourseScreen extends StatefulWidget {
  final int courseId;
  final int isEdit;
  const UploadCourseScreen({super.key, required this.isEdit, required this.courseId});

  @override
  State<UploadCourseScreen> createState() => _UploadCourseScreenState();
}

class _UploadCourseScreenState extends State<UploadCourseScreen> {
  int _currentStep = 0; // Default to first step
  bool _isCategoryStep = false; // Track if we are in "Category & Tags"
  int _lessonSubStep = 0; // Track sub-steps for Step 2 (0: Add Lesson, 1: Upload Lesson, 2: Add Lecture)
  int? totalLessons;
  int? totalLectures;
  int? _selectedLessonId; // Store the selected lessonId


  @override
  void initState() {
    super.initState();
    _loadLessonData();
  }

  Future<void> _loadLessonData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      totalLessons = prefs.getInt('totalLessons') ?? 0; // Default to 0 if null
      totalLectures = prefs.getInt('totalLectures') ?? 0; // Default to 0 if null
    });
  }

  @override
  Widget build(BuildContext context) {
    // print('Check course id and isEdit :${widget.courseId}, ${widget.isEdit}');
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
                    color: const Color(0xFF00AFEE),
                  ),
                ),
                // Step indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStep(0, 'Overview'),
                    _buildStep(1, 'Lectures'),
                    _buildStep(2, 'Instructors'),
                    _buildStep(3, 'Submit'),
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
                ? const Color(0xFF00AFEE)
                : isCurrent
                ? Colors.white
                : Colors.white,
            border: Border.all(
              color: isCompleted || isCurrent
                  ? const Color(0xFF00AFEE)
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
                    ? const Color(0xFF00AFEE)
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
                  ? const Color(0xFF00AFEE)
                  : Colors.grey[400],
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
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
            courseId: widget.courseId,
            isEdit: widget.isEdit,
            onComplete: () {
              setState(() {
                _isCategoryStep = true;
              });
            },
            onBack: () {},
          );
        } else {
          return UploadCourseCategoryTags(
            onComplete: () async {
              // Reload totalLessons from SharedPreferences
              await _loadLessonData();
              debugPrint('Updated totalLessons: $totalLessons');
              setState(() {
                _isCategoryStep = false;
                _currentStep = 1;
                _lessonSubStep = totalLessons == 0 ? 0 : 1; // Skip AddLessonScreen if totalLessons > 0
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
        if (_lessonSubStep == 0 && totalLessons == 0) {
          return AddLessonScreen(
            onComplete: () {
              setState(() {
                _lessonSubStep = 1; // Move to Upload Lesson
              });
            },
            onBack: () {
              setState(() {
                _currentStep = 0; // Move back to Category
                _isCategoryStep = true;
              });
            },
          );
        } else if (_lessonSubStep == 1 || (_lessonSubStep == 0 && totalLessons! > 0)) {
          return UploadLessonScreen(
            onComplete: (lessonId, isContinue) {
              if (isContinue) {
                // "Save and Continue" was clicked - go to InstructorsScreen
                setState(() {
                  _currentStep = 2; // Move to Instructors
                  _lessonSubStep = 0; // Reset sub-step
                });
              } else {
                // "Upload Lecture" was clicked - go to AddLectureScreen
                setState(() {
                  _selectedLessonId = lessonId;
                  _lessonSubStep = 2; // Move to Add Lecture
                });
              }
            },
            onBack: () {
              setState(() {
                if (totalLessons == 0) {
                  _lessonSubStep = 0; // Move back to Add Lesson if totalLessons == 0
                } else {
                  _currentStep = 0; // Move back to Category if totalLessons > 0
                  _isCategoryStep = true;
                }
              });
            },
          );
        } else if (_lessonSubStep == 2) {
          return AddLectureScreen(
            lessonId: _selectedLessonId ?? 0, // Pass the selected lessonId
            onComplete: () {
              // After saving, go back to UploadLessonScreen
              setState(() {
                _lessonSubStep = 1; // Go back to Upload Lesson screen
              });
            },
            onBack: () {
              setState(() {
                _lessonSubStep = 1; // Move back to Upload Lesson
              });
            },
          );
        }
        return const SizedBox.shrink(); // Fallback for invalid sub-step
      case 2:
        return InstructorsScreen(
          onComplete: () => setState(() => _currentStep = 3),
          onBack: () => setState(() {
            _currentStep = 1;
            _lessonSubStep = 1; // Go back to Upload Lesson
          }),
        );
      case 3:
        return SubmitProcessScreen(
          // onSubmit: () { Get.off(() => InstructorCourses());

            // Navigator.push(context, MaterialPageRoute(builder:
            //     (context)=>InstructorCourses()));

            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: const Text('Course Submitted Successfully!'),
            //     backgroundColor: Colors.green,
            //     behavior: SnackBarBehavior.floating,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //   ),
            // );
          onBack: () => setState(() => _currentStep = 2),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
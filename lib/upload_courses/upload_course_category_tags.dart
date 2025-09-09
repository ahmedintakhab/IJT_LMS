import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:learn_megnagmet/widget/custom_text_form_field.dart';
import '../widget/custom_dropdown.dart';

class UploadCourseCategoryTags extends StatefulWidget {
  final VoidCallback onComplete;

  const UploadCourseCategoryTags({super.key, required this.onComplete});

  @override
  State<UploadCourseCategoryTags> createState() =>
      _UploadCourseCategoryTagsState();
}

class _UploadCourseCategoryTagsState extends State<UploadCourseCategoryTags> {
  final _formKey = GlobalKey<FormState>();

  // Dropdown values
  String? selectedCategory;
  String? selectedSubCategory;
  List<String> selectedTags = [];
  String? selectedRequestCourseAs;
  String? selectedDripContent;
  String? selectedLearnersAccessibility;
  String? selectedLanguage;
  String? selectedDifficulty;
  String? selectedVideoOption; // "upload" or "youtube"
  File? introVideoFile;

  // Image Files
  File? courseImage;
  File? thumbnailImage;
  final ImagePicker _picker = ImagePicker();

  // Text Controllers
  final TextEditingController courseAccessPeriodController =
  TextEditingController();
  final TextEditingController coursePriceController = TextEditingController();
  final TextEditingController oldPriceController = TextEditingController();
  final TextEditingController youtubeIdController = TextEditingController();
  final TextEditingController accessPeriodController = TextEditingController();


  // Sample data
  final List<String> categories = [
    'Soft Skills',
    'Technical Skills',
    'Business Skills',
    'Creative Skills',
  ];

  final List<String> subCategories = [
    'Communication',
    'Leadership',
    'Time Management',
    'Problem Solving',
  ];

  final List<String> availableTags = [
    'Fiqh Courses',
    'Islamic History',
    'Arabic Language',
    'Quran Studies',
    'Hadith Studies',
    'Islamic Finance',
  ];

  final List<String> requestCourseAsOptions = [
    'Publish',
    'Upcoming',
    'Draft',
  ];

  final List<String> dripContentOptions = [
    'Show all lesson',
    'Sequential',
    'Scheduled',
  ];

  final List<String> learnersAccessibilityOptions = [
    'Public',
    'Private',
    'Restricted',
  ];

  final List<String> languageOptions = [
    'English',
    'Arabic',
    'Urdu',
    'Spanish',
    'French',
  ];

  final List<String> difficultyOptions = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  @override
  void dispose() {
    courseAccessPeriodController.dispose();
    coursePriceController.dispose();
    oldPriceController.dispose();
    super.dispose();
  }

  Future<void> pickImage(bool isThumbnail) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);

      // File size validation (max 1MB)
      final bytes = await file.length();
      final sizeInMB = bytes / (1024 * 1024);
      if (sizeInMB > 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isThumbnail
                  ? "Thumbnail size must be less than 1MB"
                  : "Course image size must be less than 1MB",
            ),
          ),
        );
        return;
      }

      setState(() {
        if (isThumbnail) {
          thumbnailImage = file;
        } else {
          courseImage = file;
        }
      });
    }
  }
  Future<void> pickIntroVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);

      // Validate video size (Max 50MB for example)
      final bytes = await file.length();
      final sizeInMB = bytes / (1024 * 1024);
      if (sizeInMB > 50) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Video must be less than 50MB")),
        );
        return;
      }

      setState(() {
        introVideoFile = file;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ---------------- Existing Code ----------------

                      Text(
                        'Course Category',
                        style: _titleStyle(),
                      ),
                      SizedBox(height: 12.h),

                      CustomDropdown(
                        hint: 'Soft Skills',
                        value: selectedCategory,
                        items: categories,
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                            selectedSubCategory = null;
                          });
                        },
                      ),

                      SizedBox(height: 24.h),

                      Text('Course Subcategory', style: _titleStyle()),
                      SizedBox(height: 12.h),

                      CustomDropdown(
                        hint: 'Select sub category',
                        value: selectedSubCategory,
                        items: subCategories,
                        onChanged: (value) {
                          setState(() {
                            selectedSubCategory = value;
                          });
                        },
                      ),

                      SizedBox(height: 24.h),

                      Text('Tags', style: _titleStyle()),
                      SizedBox(height: 12.h),

                      /// --- Tags Section UI ---
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0XFFDEDEDE), width: 1.w),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (selectedTags.isNotEmpty) ...[
                              Wrap(
                                spacing: 8.w,
                                runSpacing: 8.h,
                                children: selectedTags
                                    .map((tag) => Chip(
                                  label: Text(tag),
                                  onDeleted: () {
                                    setState(() {
                                      selectedTags.remove(tag);
                                    });
                                  },
                                ))
                                    .toList(),
                              ),
                              SizedBox(height: 12.h),
                            ],
                            CustomDropdown(
                              hint: 'Select tags',
                              value: null,
                              items: availableTags
                                  .where((tag) => !selectedTags.contains(tag))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null && !selectedTags.contains(value)) {
                                  setState(() {
                                    selectedTags.add(value);
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32.h),

                      Text('Request course as', style: _titleStyle()),
                      SizedBox(height: 12.h),
                      CustomDropdown(
                        hint: 'Publish',
                        value: selectedRequestCourseAs,
                        items: requestCourseAsOptions,
                        onChanged: (value) {
                          setState(() {
                            selectedRequestCourseAs = value;
                          });
                        },
                      ),

                      SizedBox(height: 20.h),

                      Text('Drip Content', style: _titleStyle()),
                      SizedBox(height: 12.h),
                      CustomDropdown(
                        hint: 'Show all lesson',
                        value: selectedDripContent,
                        items: dripContentOptions,
                        onChanged: (value) {
                          setState(() {
                            selectedDripContent = value;
                          });
                        },
                      ),
                      SizedBox(height: 20.h),
                      Text('Course Access Period', style: _titleStyle()),
                      SizedBox(height: 12.h),
                      CustomTextFormField(
                        controller: accessPeriodController,
                        hintText: 'If there is no expiry duration, leave the field blank',
                      ),
                      SizedBox(height: 20.h),

                      Text('Learners Accessibility', style: _titleStyle()),
                      SizedBox(height: 12.h),
                      CustomDropdown(
                        hint: 'Select Option',
                        value: selectedLearnersAccessibility,
                        items: learnersAccessibilityOptions,
                        onChanged: (value) {
                          setState(() {
                            selectedLearnersAccessibility = value;
                          });
                        },
                      ),

                      SizedBox(height: 20.h),

                      Text('Course Price', style: _titleStyle()),
                      SizedBox(height: 12.h),
                      CustomTextFormField(hintText: 'Price'),

                      SizedBox(height: 20.h),

                      Text('Old Price', style: _titleStyle()),
                      SizedBox(height: 12.h),
                      CustomTextFormField(hintText: 'Old Price'),

                      SizedBox(height: 20.h),

                      Text('Language', style: _titleStyle()),
                      SizedBox(height: 12.h),
                      CustomDropdown(
                        hint: 'Select language',
                        value: selectedLanguage,
                        items: languageOptions,
                        onChanged: (value) {
                          setState(() {
                            selectedLanguage = value;
                          });
                        },
                      ),

                      /// ---------------- New Additions ----------------

                      SizedBox(height: 20.h),

                      Text('Difficulty Level', style: _titleStyle()),
                      SizedBox(height: 12.h),
                      CustomDropdown(
                        hint: 'Select Difficulty Level',
                        value: selectedDifficulty,
                        items: difficultyOptions,
                        onChanged: (value) {
                          setState(() {
                            selectedDifficulty = value;
                          });
                        },
                      ),

                      SizedBox(height: 20.h),

                      Text('Course Image', style: _titleStyle()),
                      SizedBox(height: 12.h),
                      _imagePickerBox(courseImage, "Image", () => pickImage(false)),
                      SizedBox(height: 6.h),
                      Text(
                        "Recommended size: 575px X 450px (Max 1MB)\nAccepted: jpg, jpeg, png",
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),

                      SizedBox(height: 20.h),

                      Text('Course Thumbnail', style: _titleStyle()),
                      SizedBox(height: 12.h),
                      _imagePickerBox(thumbnailImage, "Thumbnail", () => pickImage(true)),
                      SizedBox(height: 6.h),
                      Text(
                        "Recommended size: 220px X 170px (Max 1MB)\nAccepted: jpg, jpeg, png",
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),

                      SizedBox(height: 40.h),
                      Text('Course Introduction Video (Optional)', style: _titleStyle()),
                      SizedBox(height: 12.h),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RadioListTile<String>(
                            value: "upload",
                            groupValue: selectedVideoOption,
                            title: Text("Video Upload", style: TextStyle(fontSize: 14.sp)),
                            activeColor: const Color(0xFF00AFEE),
                            onChanged: (value) {
                              setState(() {
                                selectedVideoOption = value;
                                youtubeIdController.clear();
                              });
                            },
                          ),
                          if (selectedVideoOption == "upload") ...[
                            Container(
                              margin: EdgeInsets.only(left: 20.w),
                              child: InkWell(
                                onTap: pickIntroVideo,
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFDEDEDE), width: 1.w),
                                    borderRadius: BorderRadius.circular(4.r),
                                    color: const Color(0xFFF5F5F5),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Choose File',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      if (introVideoFile != null)
                                        Padding(
                                          padding: EdgeInsets.only(left: 8.w),
                                          child: Text(
                                            introVideoFile!.path.split('/').last,
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (introVideoFile != null)
                              Padding(
                                padding: EdgeInsets.only(left: 20.w, top: 6.h),
                                child: Text(
                                  "Selected: ${introVideoFile!.path.split('/').last}",
                                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                                ),
                              ),
                          ],

                          RadioListTile<String>(
                            value: "youtube",
                            groupValue: selectedVideoOption,
                            title: const Text("Youtube Video (write only video ID)", style: TextStyle(fontSize: 14)),
                            activeColor: const Color(0xFF00AFEE),
                            onChanged: (value) {
                              setState(() {
                                selectedVideoOption = value;
                                introVideoFile = null;
                              });
                            },
                          ),
                          if (selectedVideoOption == "youtube") ...[
                            Padding(
                              padding: EdgeInsets.only(left: 20.w),
                              child: CustomTextFormField(
                                controller: youtubeIdController,
                                hintText: 'Enter YouTube Video ID',
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
            /// ---------------- Buttons ----------------
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 100.w,
                    child: CustomButton(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      buttonText: 'Back',
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: CustomButton(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          if (selectedCategory == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please select a category')),
                            );
                            return;
                          }
                          widget.onComplete();
                        }
                      },
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

  TextStyle _titleStyle() {
    return TextStyle(
      fontSize: 14.sp,
      fontFamily: 'Gilroy',
      color: const Color(0xFF00AFEE),
      fontWeight: FontWeight.w600,
    );
  }

  Widget _imagePickerBox(File? file, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 150.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0XFFDEDEDE), width: 1.w),
        ),
        child: file != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.file(file, fit: BoxFit.cover),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, color: Colors.grey),
            SizedBox(height: 6.h),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

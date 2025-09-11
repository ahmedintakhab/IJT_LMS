import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learn_megnagmet/upload_courses/sub_category_dropdown.dart';
import 'package:learn_megnagmet/upload_courses/tags_dropdown.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:learn_megnagmet/widget/custom_text_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widget/custom_dropdown.dart';
import 'category_dropdown.dart';
import 'difficulty_level_dropdown.dart';
import 'dropdown_items.dart';
import 'languages_dropdown.dart';
import 'lesson_dropdown.dart';

class UploadCourseCategoryTags extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback? onBack;

  const UploadCourseCategoryTags({super.key, required this.onComplete, this.onBack});

  @override
  State<UploadCourseCategoryTags> createState() => _UploadCourseCategoryTagsState();
}

class _UploadCourseCategoryTagsState extends State<UploadCourseCategoryTags> {
  final _formKey = GlobalKey<FormState>();

  String? selectedCategory;
  int? selectedCategoryId;
  String? selectedSubCategory;
  int? selectedSubCategoryId;
  List<String> selectedTags = [];
  List<int> selectedTagIds = [];
  String? selectedRequestCourseAs;
  int? selectedRequestCourseAsId;
  String? selectedDripContent;
  int? selectedDripContentId;
  String? selectedLearnersAccessibility;
  String? selectedLanguage;
  int? selectedLanguageId;
  String? selectedDifficultyName;
  int? selectedDifficultyId;
  String? selectedVideoOption;
  File? introVideoFile;
  int? courseId;

  File? courseImage;
  File? thumbnailImage;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController courseAccessPeriodController = TextEditingController();
  final TextEditingController coursePriceController = TextEditingController();
  final TextEditingController oldPriceController = TextEditingController();
  final TextEditingController youtubeIdController = TextEditingController();
  final TextEditingController accessPeriodController = TextEditingController();

  final List<String> requestCourseAsOptions = [
    'Publish',
    'Upcoming',
  ];

  // Map to convert requestCourseAsOptions name to ID
  final Map<String, int> requestCourseAsIdMap = {
    'Publish': 1,
    'Upcoming': 6,
  };

  final List<String> learnersAccessibilityOptions = [
    'Paid',
    'Free',
  ];

  @override
  void initState() {
    super.initState();
    _loadCourseId();
  }

  Future<void> _loadCourseId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      courseId = prefs.getInt('courseId');
    });
  }

  @override
  void dispose() {
    courseAccessPeriodController.dispose();
    coursePriceController.dispose();
    oldPriceController.dispose();
    youtubeIdController.dispose();
    accessPeriodController.dispose();
    super.dispose();
  }

  Future<void> pickImage(bool isThumbnail) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final bytes = await file.length();
      final sizeInMB = bytes / (1024 * 1024);
      if (sizeInMB > 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isThumbnail ? "Thumbnail size must be less than 1MB" : "Course image size must be less than 1MB",
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
                      Text('Course Category', style: _titleStyle()),
                      SizedBox(height: 12.h),
                      CategoryDropdown(
                        hint: 'Select Category',
                        value: selectedCategory,
                        onChanged: (name, id) {
                          setState(() {
                            selectedCategory = name;
                            selectedCategoryId = id;
                            selectedSubCategory = null;
                            selectedSubCategoryId = null;
                          });
                        },
                      ),
                      SizedBox(height: 24.h),
                      Text('Course Subcategory', style: _titleStyle()),
                      SizedBox(height: 12.h),
                      SubCategoryDropdown(
                        hint: 'Select Subcategory',
                        value: selectedSubCategory,
                        categoryId: selectedCategoryId,
                        onChanged: (name, id) {
                          setState(() {
                            selectedSubCategory = name;
                            selectedSubCategoryId = id;
                          });
                        },
                      ),
                      SizedBox(height: 24.h),
                      Text('Tags', style: _titleStyle()),
                      SizedBox(height: 12.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFDEDEDE), width: 1.w),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (selectedTags.isNotEmpty) ...[
                              Wrap(
                                spacing: 8.w,
                                runSpacing: 8.h,
                                children: selectedTags.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  String tag = entry.value;
                                  return Chip(
                                    label: Text(tag),
                                    onDeleted: () {
                                      setState(() {
                                        selectedTags.removeAt(index);
                                        selectedTagIds.removeAt(index);
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 12.h),
                            ],
                            TagsDropdown(
                              hint: 'Select tags',
                              value: null,
                              onChanged: (name, id) {
                                if (name != null && id != null && !selectedTags.contains(name)) {
                                  setState(() {
                                    selectedTags.add(name);
                                    selectedTagIds.add(id);
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
                        onChanged: (name) {
                          setState(() {
                            selectedRequestCourseAs = name;
                            selectedRequestCourseAsId = name != null ? requestCourseAsIdMap[name] : null;
                          });
                        },
                      ),
                      SizedBox(height: 20.h),
                      Text('Drip Content', style: _titleStyle()),
                      SizedBox(height: 12.h),
                      LessonsDropdown(
                        hint: 'Show all lesson',
                        value: selectedDripContent,
                        onChanged: (name, id) {
                          setState(() {
                            selectedDripContent = name;
                            selectedDripContentId = id;
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
                            // clear price fields if user switches to Free
                            if (value == "Free") {
                              coursePriceController.clear();
                              oldPriceController.clear();
                            }
                          });
                        },
                      ),
                      SizedBox(height: 20.h),
            // Show Price fields only if Paid
            if (selectedLearnersAccessibility == "Paid") ...[
          Text('Course Price', style: _titleStyle()),
                      SizedBox(height: 12.h),
                      CustomTextFormField(
                        controller: coursePriceController,
                        hintText: 'Price',
                      ),
                      SizedBox(height: 20.h),
                      Text('Old Price', style: _titleStyle()),
                      SizedBox(height: 12.h),
                      CustomTextFormField(
                        controller: oldPriceController,
                        hintText: 'Old Price',
                      ),
                      SizedBox(height: 20.h),
                      ],
                      Text('Language', style: _titleStyle()),
                      SizedBox(height: 12.h),
                      LanguagesDropdown(
                        hint: 'Select language',
                        value: selectedLanguage,
                        onChanged: (name, id) {
                          setState(() {
                            selectedLanguage = name;
                            selectedLanguageId = id;
                          });
                        },
                      ),
                      SizedBox(height: 20.h),
                      Text('Difficulty Level', style: _titleStyle()),
                      SizedBox(height: 12.h),
                      DifficultyDropdown(
                        hint: 'Select Difficulty Level',
                        value: selectedDifficultyName, // String? state variable for name
                        onChanged: (name, id) {
                          setState(() {
                            selectedDifficultyName = name; // e.g. "Medium"
                            selectedDifficultyId = id;     // e.g. 2
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
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 100.w,
                    child: CustomButton(
                      onTap: () {
                        if (widget.onBack != null) {
                          widget.onBack!();
                        }
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
                              const SnackBar(content: Text('Please select a category')),
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
          border: Border.all(color: const Color(0xFFDEDEDE), width: 1.w),
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
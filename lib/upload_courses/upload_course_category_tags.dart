import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:learn_megnagmet/upload_courses/sub_category_dropdown.dart';
import 'package:learn_megnagmet/upload_courses/tags_dropdown.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:learn_megnagmet/widget/custom_text_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constant.dart';
import '../widget/custom_dropdown.dart';
import 'category_dropdown.dart';
import 'difficulty_level_dropdown.dart';
import 'languages_dropdown.dart';
import 'lesson_dropdown.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UploadCourseCategoryTags extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback? onBack;

  const UploadCourseCategoryTags({super.key, required this.onComplete, this.onBack});

  @override
  State<UploadCourseCategoryTags> createState() => _UploadCourseCategoryTagsState();
}

class _UploadCourseCategoryTagsState extends State<UploadCourseCategoryTags> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // Added for loading state

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
  int? selectedVideoOptionId;
  File? introVideoFile;
  int? courseId;

  File? courseImage;
  File? thumbnailImage;
  final ImagePicker _picker = ImagePicker();

  // Validation error messages
  String? categoryError;
  String? requestCourseAsError;
  String? dripContentError;
  String? learnersAccessibilityError;
  String? languageError;
  String? difficultyLevelError;
  String? courseImageError;
  String? thumbnailImageError;
  String? coursePriceError;
  String? oldPriceError;

  final TextEditingController courseAccessPeriodController = TextEditingController();
  final TextEditingController coursePriceController = TextEditingController();
  final TextEditingController oldPriceController = TextEditingController();
  final TextEditingController youtubeIdController = TextEditingController();
  final TextEditingController accessPeriodController = TextEditingController();

  final List<String> requestCourseAsOptions = [
    'Publish',
    'Upcoming',
  ];

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

  void _clearValidationErrors() {
    setState(() {
      categoryError = null;
      requestCourseAsError = null;
      dripContentError = null;
      learnersAccessibilityError = null;
      languageError = null;
      difficultyLevelError = null;
      courseImageError = null;
      thumbnailImageError = null;
      coursePriceError = null;
      oldPriceError = null;
    });
  }

  bool _validateForm() {
    _clearValidationErrors();
    bool isValid = true;

    if (selectedCategory == null) {
      setState(() {
        categoryError = 'Please select a category';
      });
      isValid = false;
    }

    if (selectedRequestCourseAs == null) {
      setState(() {
        requestCourseAsError = 'Please select request course as option';
      });
      isValid = false;
    }

    if (selectedDripContent == null) {
      setState(() {
        dripContentError = 'Please select drip content option';
      });
      isValid = false;
    }

    if (selectedLearnersAccessibility == null) {
      setState(() {
        learnersAccessibilityError = 'Please select learners accessibility';
      });
      isValid = false;
    }

    if (selectedLearnersAccessibility == 'Paid') {
      if (coursePriceController.text.isEmpty) {
        setState(() {
          coursePriceError = 'Please enter the course price';
        });
        isValid = false;
      }
      if (oldPriceController.text.isEmpty) {
        setState(() {
          oldPriceError = 'Please enter the old price';
        });
        isValid = false;
      }
    }

    if (selectedLanguage == null) {
      setState(() {
        languageError = 'Please select a language';
      });
      isValid = false;
    }

    if (selectedDifficultyName == null) {
      setState(() {
        difficultyLevelError = 'Please select difficulty level';
      });
      isValid = false;
    }

    if (courseImage == null) {
      setState(() {
        courseImageError = 'Please select a course image';
      });
      isValid = false;
    }

    if (thumbnailImage == null) {
      setState(() {
        thumbnailImageError = 'Please select a thumbnail image';
      });
      isValid = false;
    }

    return isValid;
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
      if (isThumbnail) {
        // Check image dimensions for thumbnail
        final imageBytes = await file.readAsBytes();
        final decodedImage = img.decodeImage(imageBytes);
        if (decodedImage == null || decodedImage.width != 220 || decodedImage.height != 170) {
          setState(() {
            thumbnailImageError = 'Thumbnail image must be exactly 220px x 170px';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thumbnail image must be exactly 220px x 170px')),
          );
          return;
        }
      }
      setState(() {
        if (isThumbnail) {
          thumbnailImage = file;
          thumbnailImageError = null;
        } else {
          courseImage = file;
          courseImageError = null;
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || !_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Print all data for debugging
    debugPrint('Submitting data:');
    debugPrint('course_id: $courseId');
    debugPrint('category_id: $selectedCategoryId');
    debugPrint('subcategory_id: $selectedSubCategoryId');
    debugPrint('tags: $selectedTagIds');
    debugPrint('request_course: $selectedRequestCourseAsId');
    debugPrint('drip_content: $selectedDripContentId');
    debugPrint('access_period: ${accessPeriodController.text}');
    debugPrint('learner_accessibility: $selectedLearnersAccessibility');
    debugPrint('price: ${coursePriceController.text}');
    debugPrint('old_price: ${oldPriceController.text}');
    debugPrint('course_language_id: $selectedLanguageId');
    debugPrint('difficulty_level_id: $selectedDifficultyId');
    debugPrint('image: ${courseImage?.path}');
    debugPrint('thumbnail_image: ${thumbnailImage?.path}');
    debugPrint('intro_video_check: $selectedVideoOptionId');
    debugPrint('video: ${introVideoFile?.path}');
    debugPrint('youtube_video_id: ${youtubeIdController.text}');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = Uri.parse('${ApiConstant.baseUrl}instructor/course/update-category');
      var request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields['course_id'] = courseId?.toString() ?? '';
      request.fields['category_id'] = selectedCategoryId?.toString() ?? '';
      request.fields['subcategory_id'] = selectedSubCategoryId?.toString() ?? '';
      request.fields['tags[]'] = selectedTagIds.join(',');
      request.fields['request_course'] = selectedRequestCourseAsId?.toString() ?? '';
      request.fields['drip_content'] = selectedDripContentId?.toString() ?? '';
      request.fields['access_period'] = accessPeriodController.text;
      request.fields['learner_accessibility'] = selectedLearnersAccessibility ?? '';
      request.fields['price'] = coursePriceController.text;
      request.fields['old_price'] = oldPriceController.text;
      request.fields['course_language_id'] = selectedLanguageId?.toString() ?? '';
      request.fields['difficulty_level_id'] = selectedDifficultyId?.toString() ?? '';
      request.fields['intro_video_check'] = selectedVideoOptionId?.toString() ?? '';

      // Add YouTube video ID if selected
      if (selectedVideoOptionId == 2) {
        request.fields['youtube_video_id'] = youtubeIdController.text;
      }

      // Add image files
      if (courseImage != null) {
        request.files.add(await http.MultipartFile.fromPath('image', courseImage!.path));
      }
      if (thumbnailImage != null) {
        request.files.add(await http.MultipartFile.fromPath('thumbnail_image', thumbnailImage!.path));
      }
      if (selectedVideoOptionId == 1 && introVideoFile != null) {
        request.files.add(await http.MultipartFile.fromPath('video', introVideoFile!.path));
      }

      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        debugPrint(' Upload course tags API Response : ${response.statusCode}');
        debugPrint('API Response: $responseData');
        if (responseData['success'] == true) {
          int totalLessons = responseData['data']['total_lessons'];
          int totalLectures = responseData['data']['total_lectures'];
          await prefs.setInt('totalLessons', totalLessons);
          await prefs.setInt('totalLectures', totalLectures);
          debugPrint('Stored total lessons: $totalLessons');
          debugPrint('Stored total lectures: $totalLectures');
        }
        Get.snackbar(
          'Successful', 'Course Updated successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        widget.onComplete();
      } else {
        debugPrint('API Error: ${response.statusCode} - $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit data: ${responseData['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      debugPrint('Error submitting form: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while submitting the form')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildErrorMessage(String? errorMessage) {
    if (errorMessage == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Text(
        errorMessage,
        style: TextStyle(
          color: Colors.red,
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
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
                            categoryError = null;
                          });
                        },
                      ),
                      _buildErrorMessage(categoryError),
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
                            requestCourseAsError = null;
                          });
                        },
                      ),
                      _buildErrorMessage(requestCourseAsError),
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
                            dripContentError = null;
                          });
                        },
                      ),
                      _buildErrorMessage(dripContentError),
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
                            learnersAccessibilityError = null;
                            if (value == "Free") {
                              coursePriceController.clear();
                              oldPriceController.clear();
                              coursePriceError = null;
                              oldPriceError = null;
                            }
                          });
                        },
                      ),
                      _buildErrorMessage(learnersAccessibilityError),
                      SizedBox(height: 20.h),
                      if (selectedLearnersAccessibility == "Paid") ...[
                        Text('Course Price', style: _titleStyle()),
                        SizedBox(height: 12.h),
                        CustomTextFormField(
                          controller: coursePriceController,
                          hintText: 'Price',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the course price';
                            }
                            return null;
                          },
                        ),
                        _buildErrorMessage(coursePriceError),
                        SizedBox(height: 20.h),
                        Text('Old Price', style: _titleStyle()),
                        SizedBox(height: 12.h),
                        CustomTextFormField(
                          controller: oldPriceController,
                          hintText: 'Old Price',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the old price';
                            }
                            return null;
                          },
                        ),
                        _buildErrorMessage(oldPriceError),
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
                            languageError = null;
                          });
                        },
                      ),
                      _buildErrorMessage(languageError),
                      SizedBox(height: 20.h),
                      Text('Difficulty Level', style: _titleStyle()),
                      SizedBox(height: 12.h),
                      DifficultyDropdown(
                        hint: 'Select Difficulty Level',
                        value: selectedDifficultyName,
                        onChanged: (name, id) {
                          setState(() {
                            selectedDifficultyName = name;
                            selectedDifficultyId = id;
                            difficultyLevelError = null;
                          });
                        },
                      ),
                      _buildErrorMessage(difficultyLevelError),
                      SizedBox(height: 20.h),
                      Text('Course Image', style: _titleStyle()),
                      SizedBox(height: 12.h),
                      _imagePickerBox(courseImage, "Image", () => pickImage(false)),
                      _buildErrorMessage(courseImageError),
                      SizedBox(height: 6.h),
                      Text(
                        "Recommended size: 575px X 450px (Max 1MB)\nAccepted: jpg, jpeg, png",
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                      SizedBox(height: 20.h),
                      Text('Course Thumbnail', style: _titleStyle()),
                      SizedBox(height: 12.h),
                      _imagePickerBox(thumbnailImage, "Thumbnail", () => pickImage(true)),
                      _buildErrorMessage(thumbnailImageError),
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
                                selectedVideoOptionId = 1;
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
                                selectedVideoOptionId = 2;
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
                      onTap: _submitForm,
                      buttonText: 'Save and Continue',
                      isLoading: _isLoading,
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
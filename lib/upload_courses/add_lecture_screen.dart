import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:learn_megnagmet/widget/custom_text_form_field.dart';
import 'package:learn_megnagmet/widget/custom_dropdown.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:learn_megnagmet/utils/api_constant.dart';

class AddLectureScreen extends StatefulWidget {
  final int lessonId; // Added lessonId parameter
  final VoidCallback onComplete;
  final VoidCallback? onBack;

  const AddLectureScreen({super.key, required this.lessonId, required this.onComplete, this.onBack});

  @override
  State<AddLectureScreen> createState() => _AddLectureScreenState();
}

class _AddLectureScreenState extends State<AddLectureScreen> {
  String _selectedType = 'Video'; // Default to Video
  int? courseId;
  bool _isLoading = false;

  // Separate controllers for each content type
  final TextEditingController _videoTitleController = TextEditingController();
  final TextEditingController _pdfTitleController = TextEditingController();
  final TextEditingController _textTitleController = TextEditingController();
  final TextEditingController _textContentController = TextEditingController();
  final TextEditingController _imageTitleController = TextEditingController();
  final TextEditingController _slidesTitleController = TextEditingController();
  final TextEditingController _youtubeTitleController = TextEditingController();
  final TextEditingController _audioTitleController = TextEditingController();

  String? _videoType;
  String? _visibility;
  final TextEditingController _youtubeIdController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String _selectedVideoFileName = 'No File Chosen'; // Specific to Video
  String _selectedPDFFileName = 'No File Chosen'; // Specific to PDF
  String _selectedAudioFileName = 'No File Chosen'; // Specific to Audio
  String _selectedImageFileName = 'No File Chosen'; // Specific to Image
  final TextEditingController _slideEmbedCodeController = TextEditingController(); // For Slides

  // Validation errors
  String? _titleError;
  String? _visibilityError;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Allow all file types, user selects manually
      );
      if (result != null && result.files.isNotEmpty) {
        String fileName = result.files.first.name;
        String? fileExtension = result.files.first.extension?.toLowerCase();
        setState(() {
          if (_selectedType == 'Video' && (fileExtension == 'mp4' || fileExtension == 'avi' || fileExtension == 'mov')) {
            _selectedVideoFileName = fileName;
            _selectedPDFFileName = 'No File Chosen';
            _selectedAudioFileName = 'No File Chosen';
            _selectedImageFileName = 'No File Chosen';
          } else if (_selectedType == 'PDF' && fileExtension == 'pdf') {
            _selectedPDFFileName = fileName;
            _selectedVideoFileName = 'No File Chosen';
            _selectedAudioFileName = 'No File Chosen';
            _selectedImageFileName = 'No File Chosen';
          } else if (_selectedType == 'Image' && (fileExtension == 'jpg' || fileExtension == 'jpeg' || fileExtension == 'png')) {
            _selectedImageFileName = fileName;
            _selectedVideoFileName = 'No File Chosen';
            _selectedPDFFileName = 'No File Chosen';
            _selectedAudioFileName = 'No File Chosen';
          } else if (_selectedType == 'Audio' && (fileExtension == 'mp3' || fileExtension == 'wav')) {
            _selectedAudioFileName = fileName;
            _selectedVideoFileName = 'No File Chosen';
            _selectedPDFFileName = 'No File Chosen';
            _selectedImageFileName = 'No File Chosen';
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a valid file type for the chosen category.')),
            );
            return;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File selected: ${result.files.first.path}')),
        );
      }
    } catch (e) {
      print('Error picking file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick file. Please try again.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    print('AddLectureScreen received lessonId: ${widget.lessonId}');
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
    // Dispose all controllers
    _videoTitleController.dispose();
    _pdfTitleController.dispose();
    _textTitleController.dispose();
    _textContentController.dispose();
    _imageTitleController.dispose();
    _slidesTitleController.dispose();
    _youtubeTitleController.dispose();
    _audioTitleController.dispose();
    _youtubeIdController.dispose();
    _durationController.dispose();
    _slideEmbedCodeController.dispose();
    super.dispose();
  }

  // Helper method to get the appropriate title controller based on selected type
  TextEditingController _getTitleController() {
    switch (_selectedType) {
      case 'Video':
        return _videoTitleController;
      case 'PDF':
        return _pdfTitleController;
      case 'Text':
        return _textTitleController;
      case 'Image':
        return _imageTitleController;
      case 'Slides':
        return _slidesTitleController;
      case 'YouTube':
        return _youtubeTitleController;
      case 'Audio':
        return _audioTitleController;
      default:
        return _videoTitleController;
    }
  }

  // Helper method to get the appropriate hint text based on selected type
  String _getTitleHint() {
    switch (_selectedType) {
      case 'Video':
        return 'Enter Video Title';
      case 'PDF':
        return 'Enter PDF Title';
      case 'Text':
        return 'Enter Text Title';
      case 'Image':
        return 'Enter Image Title';
      case 'Slides':
        return 'Enter Slides Title';
      case 'YouTube':
        return 'Enter YouTube Video Title';
      case 'Audio':
        return 'Enter Audio Title';
      default:
        return 'Enter Lecture Title';
    }
  }

  // Validate form
  bool _validateForm() {
    bool isValid = true;

    // Validate title
    final title = _getTitleController().text;
    if (title.isEmpty) {
      setState(() {
        _titleError = 'Title is required';
      });
      isValid = false;
    } else {
      setState(() {
        _titleError = null;
      });
    }

    // Validate visibility
    if (_visibility == null) {
      setState(() {
        _visibilityError = 'Visibility is required';
      });
      isValid = false;
    } else {
      setState(() {
        _visibilityError = null;
      });
    }

    return isValid;
  }

  // Submit lecture data to API
  // Submit lecture data to API
  Future<void> _submitLecture() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = Uri.parse('${ApiConstant.baseUrl}instructor/course/upload-lecture');
      var request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add required fields
      request.fields['lesson_id'] = widget.lessonId.toString();
      request.fields['course_id'] = courseId?.toString() ?? '';
      request.fields['type'] = _selectedType;
      request.fields['title'] = _getTitleController().text;
      request.fields['visibility'] = _visibility ?? 'Show';

      // Add optional fields based on type
      if (_selectedType == 'Video' || _selectedType == 'Audio') {
        if (_videoType != null) {
          request.fields['video_type'] = _videoType!;
        }
      }

      if (_selectedType == 'YouTube') {
        if (_youtubeIdController.text.isNotEmpty) {
          request.fields['youtube_url_path'] = _youtubeIdController.text;
        }
        if (_durationController.text.isNotEmpty) {
          request.fields['youtube_file_duration'] = _durationController.text;
        }
      }

      if (_selectedType == 'Text') {
        if (_textContentController.text.isNotEmpty) {
          request.fields['text_description'] = _textContentController.text;
        }
      }

      if (_selectedType == 'Slides') {
        if (_slideEmbedCodeController.text.isNotEmpty) {
          request.fields['slide_document'] = _slideEmbedCodeController.text;
        }
      }

      // Add file names (mock, since actual file upload isn't here)
      if (_selectedType == 'Video' && _selectedVideoFileName != 'No File Chosen') {
        request.fields['video_file'] = _selectedVideoFileName;
      }
      if (_selectedType == 'PDF' && _selectedPDFFileName != 'No File Chosen') {
        request.fields['pdf'] = _selectedPDFFileName;
      }
      if (_selectedType == 'Image' && _selectedImageFileName != 'No File Chosen') {
        request.fields['image'] = _selectedImageFileName;
      }
      if (_selectedType == 'Audio' && _selectedAudioFileName != 'No File Chosen') {
        request.fields['audio'] = _selectedAudioFileName;
      }

      // ✅ Print the final data before API call
      debugPrint("📌 Data being sent to API:");
      request.fields.forEach((key, value) {
        debugPrint("$key: $value");
      });

      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          debugPrint(' Upload lecture  API Response : ${response.statusCode}');
          Get.snackbar(
            'Successful', 'Lecture added successfully!',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          if (widget.onBack != null) {
            widget.onBack!();
          }
        } else {
          Get.snackbar(
            responseData['message'], 'Failed to save lecture',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        print('Error: ${responseBody}');
      }
    } catch (e) {
      print('Error saving lecture: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(10.w),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Radio buttons for lecture types in rows
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildRadioOption('Video'),
                              _buildRadioOption('PDF'),
                              _buildRadioOption('Text'),
                              _buildRadioOption('Image'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildRadioOption('Slides'),
                              _buildRadioOption('YouTube'),
                              _buildRadioOption('Audio'),
                              const SizedBox.shrink(), // Placeholder to balance
                            ],
                          ),
                        ],
                      ),
                      // Container for file upload (shown for applicable types except Image and Slides)
                      if (_selectedType == 'Video')
                        Center(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(24.w),
                            margin: EdgeInsets.only(top: 16.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Upload Video',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: const Color(0xFF00AFEE),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Icon(
                                  Icons.videocam,
                                  size: 80.sp,
                                  color: Colors.pink[200],
                                ),
                                SizedBox(height: 10.h),
                                OutlinedButton.icon(
                                  onPressed: _pickFile,
                                  icon: const Icon(Icons.folder_open, color: Colors.black),
                                  label: Text(_selectedVideoFileName, style: const TextStyle(color: Colors.black)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.blue),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_selectedType == 'PDF')
                        Center(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(24.w),
                            margin: EdgeInsets.only(top: 16.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Upload PDF',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: const Color(0xFF00AFEE),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Icon(
                                  Icons.picture_as_pdf,
                                  size: 80.sp,
                                  color: Colors.pink[200],
                                ),
                                SizedBox(height: 10.h),
                                OutlinedButton.icon(
                                  onPressed: _pickFile,
                                  icon: const Icon(Icons.folder_open, color: Colors.black),
                                  label: Text(_selectedPDFFileName, style: const TextStyle(color: Colors.black)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.blue),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_selectedType == 'Audio')
                        Center(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(24.w),
                            margin: EdgeInsets.only(top: 16.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Upload Audio',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: const Color(0xFF00AFEE),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Icon(
                                  Icons.audiotrack,
                                  size: 80.sp,
                                  color: Colors.pink[200],
                                ),
                                SizedBox(height: 10.h),
                                OutlinedButton.icon(
                                  onPressed: _pickFile,
                                  icon: const Icon(Icons.folder_open, color: Colors.black),
                                  label: Text(_selectedAudioFileName, style: const TextStyle(color: Colors.black)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.blue),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Separate Choose Image UI for Image case
                      if (_selectedType == 'Image')
                        Center(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(24.w),
                            margin: EdgeInsets.only(top: 16.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Choose Image',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: const Color(0xFF00AFEE),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Icon(
                                  Icons.image,
                                  size: 80.sp,
                                  color: Colors.pink[200],
                                ),
                                SizedBox(height: 10.h),
                                OutlinedButton.icon(
                                  onPressed: _pickFile,
                                  icon: const Icon(Icons.folder_open, color: Colors.black),
                                  label: Text(_selectedImageFileName, style: const TextStyle(color: Colors.black)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.blue),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Hint text below Choose Image
                      if (_selectedType == 'Image')
                        Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            'Hint: Select an image file (e.g., JPG, PNG) from your gallery.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      // Single form for all types
                      Container(
                        padding: EdgeInsets.all(16.w),
                        margin: EdgeInsets.only(top: 16.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_selectedType == 'Video' || _selectedType == 'Audio')
                              CustomDropdown(
                                hint: 'Select Lecture Type',
                                value: _videoType,
                                items: ['Book', 'Summary', 'Notes'],
                                onChanged: (value) {
                                  setState(() {
                                    _videoType = value;
                                  });
                                },
                              ),
                            SizedBox(height: 16.h,),
                            if (_selectedType == 'Text')
                              Column(
                                children: [
                                  CustomTextFormField(
                                    controller: _textContentController,
                                    hintText: 'Enter Text Content',
                                    labelText: 'Text Content',
                                  ),
                                  SizedBox(height: 16.h),
                                ],
                              ),
                            if (_selectedType == 'Video' || _selectedType == 'PDF' || _selectedType == 'Image' || _selectedType == 'Slides' || _selectedType == 'Audio' || _selectedType == 'Text' || _selectedType == 'YouTube')
                              Column(
                                children: [
                                  CustomTextFormField(
                                    controller: _getTitleController(),
                                    hintText: _getTitleHint(),
                                    labelText: 'Title',
                                  ),
                                  if (_titleError != null)
                                    Padding(
                                      padding: EdgeInsets.only(top: 4.h),
                                      child: Text(
                                        _titleError!,
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            if (_selectedType == 'Video' || _selectedType == 'PDF' || _selectedType == 'Image' || _selectedType == 'Slides' || _selectedType == 'Audio' || _selectedType == 'Text' || _selectedType == 'YouTube')
                              SizedBox(height: 16.h),
                            if (_selectedType == 'Slides')
                              CustomTextFormField(
                                controller: _slideEmbedCodeController,
                                hintText: 'Slide Embeded Code',
                                labelText: 'Write your slide embedded code',
                              ),
                            if (_selectedType == 'Slides')
                              SizedBox(height: 16.h),
                            if (_selectedType == 'YouTube')
                              Column(
                                children: [
                                  CustomTextFormField(
                                    controller: _youtubeIdController,
                                    hintText: 'Enter YouTube ID',
                                    labelText: 'YouTube ID',
                                  ),
                                  SizedBox(height: 16.h),
                                  CustomTextFormField(
                                    controller: _durationController,
                                    hintText: 'Enter File Duration',
                                    labelText: 'File Duration (e.g., 10:00)',
                                  ),
                                  SizedBox(height: 16.h),
                                ],
                              ),
                            Column(
                              children: [
                                CustomDropdown(
                                  hint: 'Select Visibility',
                                  value: _visibility,
                                  items: ['Show', 'Lock'],
                                  onChanged: (value) {
                                    setState(() {
                                      _visibility = value;
                                      _visibilityError = null;
                                    });
                                  },
                                ),
                                if (_visibilityError != null)
                                  Padding(
                                    padding: EdgeInsets.only(top: 4.h),
                                    child: Text(
                                      _visibilityError!,
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Fixed buttons at the bottom
            Padding(
              padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
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
                      onTap: _submitLecture,
                      buttonText: 'Save',
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

  Widget _buildRadioOption(String value) {
    return Flexible(
      fit: FlexFit.tight,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = value;
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedType,
              onChanged: (newValue) {
                setState(() {
                  _selectedType = newValue!;
                });
              },
              activeColor: const Color(0xFF00AFEE),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: _selectedType == value ? const Color(0xFF00AFEE) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
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
  final int lessonId;
  final int? lectureId;
  final VoidCallback onComplete;
  final VoidCallback? onBack;

  const AddLectureScreen({
    super.key,
    required this.lessonId,
    required this.onComplete,
    this.onBack,
    this.lectureId,
  });

  @override
  State<AddLectureScreen> createState() => _AddLectureScreenState();
}

class _AddLectureScreenState extends State<AddLectureScreen> {
  String _selectedType = 'Video';
  int? courseId;
  bool _isLoading = false;
  int isEdit = 0;

  // Controllers
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
  final TextEditingController _slideEmbedCodeController = TextEditingController();

  // File data storage
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  String _selectedVideoFileName = 'No File Chosen';
  String _selectedPDFFileName = 'No File Chosen';
  String _selectedAudioFileName = 'No File Chosen';
  String _selectedImageFileName = 'No File Chosen';

  // Validation errors
  String? _titleError;
  String? _visibilityError;

  @override
  void initState() {
    super.initState();
    print('AddLectureScreen received lessonId: ${widget.lessonId}, lectureId: ${widget.lectureId}');
    _loadCourseId();
    if (widget.lectureId != null) {
      _fetchLectureData();
    }
  }

  Future<void> _loadCourseId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      courseId = prefs.getInt('courseId');
    });
  }

  Future<void> _fetchLectureData() async {
    if (widget.lectureId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = Uri.parse('${ApiConstant.baseUrl}instructor/course/edit-lecture-data/${widget.lectureId}');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Fetch lecture API Response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'].isNotEmpty) {
          final lectureData = responseData['data'][0];
          isEdit = lectureData['is_edit'];
          print('Check is edit 111 : $isEdit');
          final validVideoTypes = ['Book', 'Summary', 'Notes'];
          setState(() {
            _selectedType = lectureData['lecture_type'];
            _visibility = lectureData['learner_visibility'];

            // Populate fields based on lecture type
            switch (_selectedType) {
              case 'Video':
                _videoTitleController.text = lectureData['lesson_title'] ?? '';
                _videoType = validVideoTypes.contains(lectureData['video_type'])
                    ? lectureData['video_type']
                    : null;
                _selectedVideoFileName = lectureData['upload_video'] != null
                    ? lectureData['upload_video'].split('/').last
                    : 'No File Chosen';
                break;
              case 'Audio':
                _audioTitleController.text = lectureData['lesson_title'] ?? '';
                _videoType = validVideoTypes.contains(lectureData['audio_type'])
                    ? lectureData['audio_type']
                    : null;
                _selectedAudioFileName = lectureData['upload_audio'] != null
                    ? lectureData['upload_audio'].split('/').last
                    : 'No File Chosen';
                break;
              case 'Image':
                _imageTitleController.text = lectureData['lesson_title'] ?? '';
                _selectedImageFileName = lectureData['lesson_image'] != null
                    ? lectureData['lesson_image'].split('/').last
                    : 'No File Chosen';
                break;
              case 'PDF':
                _pdfTitleController.text = lectureData['lesson_title'] ?? '';
                _selectedPDFFileName = lectureData['upload_pdf'] != null
                    ? lectureData['upload_pdf'].split('/').last
                    : 'No File Chosen';
                break;
              case 'Text':
                _textTitleController.text = lectureData['lesson_title'] ?? '';
                _textContentController.text = lectureData['lesson_description'] ?? '';
                break;
              case 'YouTube':
                _youtubeTitleController.text = lectureData['lesson_title'] ?? '';
                _youtubeIdController.text = lectureData['youtube_video_id'] ?? '';
                _durationController.text = lectureData['file_duration'] ?? '';
                break;
              case 'Slides':
                _slidesTitleController.text = lectureData['lesson_title'] ?? '';
                _slideEmbedCodeController.text = lectureData['slide_document'] ?? '';
                break;
            }
          });
        } else {
          Get.snackbar(
            'Error',
            responseData['message'] ?? 'Failed to fetch lecture data',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to fetch lecture data',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error fetching lecture data: $e');
      Get.snackbar(
        'Error',
        'An error occurred while fetching lecture data',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        String fileName = file.name;
        String? fileExtension = file.extension?.toLowerCase();

        // Get file bytes
        Uint8List? fileBytes;
        if (file.bytes != null) {
          fileBytes = file.bytes; // Web platform
        } else if (file.path != null) {
          fileBytes = await File(file.path!).readAsBytes(); // Mobile platform
        }

        if (fileBytes == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to read file data.')),
          );
          return;
        }

        // Validate file type and set appropriate filename
        bool isValidFile = false;

        setState(() {
          if (_selectedType == 'Video' &&
              (fileExtension == 'mp4' || fileExtension == 'avi' || fileExtension == 'mov' || fileExtension == 'mkv')) {
            _selectedVideoFileName = fileName;
            _selectedPDFFileName = 'No File Chosen';
            _selectedAudioFileName = 'No File Chosen';
            _selectedImageFileName = 'No File Chosen';
            isValidFile = true;
          } else if (_selectedType == 'PDF' && fileExtension == 'pdf') {
            _selectedPDFFileName = fileName;
            _selectedVideoFileName = 'No File Chosen';
            _selectedAudioFileName = 'No File Chosen';
            _selectedImageFileName = 'No File Chosen';
            isValidFile = true;
          } else if (_selectedType == 'Image' &&
              (fileExtension == 'jpg' || fileExtension == 'jpeg' || fileExtension == 'png')) {
            _selectedImageFileName = fileName;
            _selectedVideoFileName = 'No File Chosen';
            _selectedPDFFileName = 'No File Chosen';
            _selectedAudioFileName = 'No File Chosen';
            isValidFile = true;
          } else if (_selectedType == 'Audio' &&
              (fileExtension == 'mp3' || fileExtension == 'wav' || fileExtension == 'aac')) {
            _selectedAudioFileName = fileName;
            _selectedVideoFileName = 'No File Chosen';
            _selectedPDFFileName = 'No File Chosen';
            _selectedImageFileName = 'No File Chosen';
            isValidFile = true;
          }

          if (isValidFile) {
            _selectedFileBytes = fileBytes;
            _selectedFileName = fileName;
          }
        });

        if (isValidFile) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File selected: $fileName')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please select a valid ${_selectedType.toLowerCase()} file.')),
          );
        }
      }
    } catch (e) {
      print('Error picking file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick file. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
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

  bool _validateForm() {
    bool isValid = true;

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

    // Validate file selection for types that require files
    if (['Video', 'PDF', 'Image', 'Audio'].contains(_selectedType) && _selectedFileBytes == null && widget.lectureId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a ${_selectedType.toLowerCase()} file.')),
      );
      isValid = false;
    }

    return isValid;
  }

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

      request.headers['Authorization'] = 'Bearer $token';

      // Add required fields
      request.fields['lesson_id'] = widget.lessonId.toString();
      request.fields['course_id'] = courseId?.toString() ?? '';
      request.fields['type'] = _selectedType;
      request.fields['title'] = _getTitleController().text;
      request.fields['visibility'] = _visibility ?? 'Show';

      // Add optional fields based on type
      if (_selectedType == 'Video') {
        if (_videoType != null) {
          request.fields['video_type'] = _videoType!;
        }
      }

      if (_selectedType == 'Audio') {
        if (_videoType != null) {
          request.fields['audio_type'] = _videoType!; // 👈 pass audio_type instead of video_type
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

      // Add actual file uploads
      if (_selectedFileBytes != null && _selectedFileName != null) {
        String fieldName;
        switch (_selectedType) {
          case 'Video':
            fieldName = 'video_file';
            break;
          case 'PDF':
            fieldName = 'pdf';
            break;
          case 'Image':
            fieldName = 'image';
            break;
          case 'Audio':
            fieldName = 'audio';
            break;
          default:
            fieldName = 'file';
        }

        request.files.add(
          http.MultipartFile.fromBytes(
            fieldName,
            _selectedFileBytes!,
            filename: _selectedFileName!,
          ),
        );
      }

      debugPrint("📌 Data being sent to API:");
      request.fields.forEach((key, value) {
        debugPrint("$key: $value");
      });

      if (request.files.isNotEmpty) {
        debugPrint("📎 Files being uploaded:");
        for (var file in request.files) {
          debugPrint("Field: ${file.field}, Filename: ${file.filename}, Size: ${file.length} bytes");
        }
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);

      debugPrint('Upload lecture API Response: ${response.statusCode}');
      debugPrint('Response body: $responseBody');

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          Get.snackbar(
            'Successful',
            'Lecture added successfully!',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          widget.onComplete();
          if (widget.onBack != null) {
            widget.onBack!();
          }
        } else {
          Get.snackbar(
            responseData['message'] ?? 'Error',
            'Failed to save lecture',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        String errorMessage = 'Failed to save lecture';
        if (responseData.containsKey('error')) {
          // Handle validation errors
          Map<String, dynamic> errors = responseData['error'];
          List<String> errorMessages = [];
          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.map((e) => e.toString()));
            }
          });
          errorMessage = errorMessages.join('\n');
        }

        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print('Error: ${responseBody}');
      }
    } catch (e) {
      print('Error saving lecture: $e');
      Get.snackbar(
        'Error',
        'An error occurred while saving the lecture',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<void> _updateLecture() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final url = Uri.parse('${ApiConstant.baseUrl}instructor/course/update-lecture');
      var request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = 'Bearer $token';

      // Add required fields
      request.fields['lecture_id'] = widget.lectureId.toString();
      request.fields['type'] = _selectedType;
      request.fields['title'] = _getTitleController().text;
      request.fields['visibility'] = _visibility ?? 'Show';

      // Add optional fields based on type
      if (_selectedType == 'Video') {
        if (_videoType != null) {
          request.fields['video_type'] = _videoType!;
        }
      }

      if (_selectedType == 'Audio') {
        if (_videoType != null) {
          request.fields['audio_type'] = _videoType!; // 👈 pass audio_type instead of video_type
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

      // Add actual file uploads
      if (_selectedFileBytes != null && _selectedFileName != null) {
        String fieldName;
        switch (_selectedType) {
          case 'Video':
            fieldName = 'video_file';
            break;
          case 'PDF':
            fieldName = 'pdf';
            break;
          case 'Image':
            fieldName = 'image';
            break;
          case 'Audio':
            fieldName = 'audio';
            break;
          default:
            fieldName = 'file';
        }

        request.files.add(
          http.MultipartFile.fromBytes(
            fieldName,
            _selectedFileBytes!,
            filename: _selectedFileName!,
          ),
        );
      }

      debugPrint("📌 Data being sent to API:");
      request.fields.forEach((key, value) {
        debugPrint("$key: $value");
      });

      if (request.files.isNotEmpty) {
        debugPrint("📎 Files being uploaded:");
        for (var file in request.files) {
          debugPrint("Field: ${file.field}, Filename: ${file.filename}, Size: ${file.length} bytes");
        }
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);

      debugPrint('Upload lecture API Response: ${response.statusCode}');
      debugPrint('Response body: $responseBody');

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          Get.snackbar(
            'Successful',
            'Lecture updated successfully!',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          widget.onComplete();
          if (widget.onBack != null) {
            widget.onBack!();
          }
        } else {
          Get.snackbar(
            responseData['message'] ?? 'Error',
            'Failed to save lecture',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        String errorMessage = 'Failed to save lecture';
        if (responseData.containsKey('error')) {
          // Handle validation errors
          Map<String, dynamic> errors = responseData['error'];
          List<String> errorMessages = [];
          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.map((e) => e.toString()));
            }
          });
          errorMessage = errorMessages.join('\n');
        }

        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print('Error: ${responseBody}');
      }
    } catch (e) {
      print('Error saving lecture: $e');
      Get.snackbar(
        'Error',
        'An error occurred while saving the lecture',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    print('Check is edit 111 : $isEdit');
    print('Check lecture id in add lecture screen: ${widget.lectureId}');
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                              const SizedBox.shrink(),
                            ],
                          ),
                        ],
                      ),
                      // Container for file upload (shown for applicable types)
                      if (_selectedType == 'Video')
                        _buildFileUploadContainer('Upload Video', Icons.videocam, _selectedVideoFileName),
                      if (_selectedType == 'PDF')
                        _buildFileUploadContainer('Upload PDF', Icons.picture_as_pdf, _selectedPDFFileName),
                      if (_selectedType == 'Audio')
                        _buildFileUploadContainer('Upload Audio', Icons.audiotrack, _selectedAudioFileName),
                      if (_selectedType == 'Image')
                        _buildFileUploadContainer('Choose Image', Icons.image, _selectedImageFileName),

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
                            if (_selectedType == 'Video' || _selectedType == 'Audio')
                              SizedBox(height: 16.h),
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
                            SizedBox(height: 16.h),
                            if (_selectedType == 'Slides')
                              Column(
                                children: [
                                  CustomTextFormField(
                                    controller: _slideEmbedCodeController,
                                    hintText: 'Slide Embeded Code',
                                    labelText: 'Write your slide embedded code',
                                  ),
                                  SizedBox(height: 16.h),
                                ],
                              ),
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
                      onTap: () {
                        if (isEdit == 0) {
                          _submitLecture();
                        } else {
                          _updateLecture();
                        }
                      },
                      buttonText: 'Update',
                      // onTap: _submitLecture,
                      // buttonText: widget.lectureId != null ? 'Update' : 'Save',
                      // isLoading: _isLoading,
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

  Widget _buildFileUploadContainer(String title, IconData icon, String fileName) {
    return Center(
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
              title,
              style: TextStyle(
                fontSize: 18.sp,
                color: const Color(0xFF00AFEE),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            Icon(
              icon,
              size: 80.sp,
              color: Colors.pink[200],
            ),
            SizedBox(height: 10.h),
            OutlinedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.folder_open, color: Colors.black),
              label: Text(
                fileName,
                style: const TextStyle(color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
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
    );
  }

  Widget _buildRadioOption(String value) {
    return Flexible(
      fit: FlexFit.tight,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = value;
            // Reset file selection when type changes
            _selectedFileBytes = null;
            _selectedFileName = null;
            _selectedVideoFileName = 'No File Chosen';
            _selectedPDFFileName = 'No File Chosen';
            _selectedAudioFileName = 'No File Chosen';
            _selectedImageFileName = 'No File Chosen';
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
                  // Reset file selection when type changes
                  _selectedFileBytes = null;
                  _selectedFileName = null;
                  _selectedVideoFileName = 'No File Chosen';
                  _selectedPDFFileName = 'No File Chosen';
                  _selectedAudioFileName = 'No File Chosen';
                  _selectedImageFileName = 'No File Chosen';
                });
              },
              activeColor: const Color(0xFF00AFEE),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                color: _selectedType == value ? const Color(0xFF00AFEE) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
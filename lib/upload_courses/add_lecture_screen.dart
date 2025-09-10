import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:learn_megnagmet/widget/custom_text_form_field.dart';
import 'package:learn_megnagmet/widget/custom_dropdown.dart';
import 'package:file_picker/file_picker.dart';

class AddLectureScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback? onBack;

  const AddLectureScreen({super.key, required this.onComplete, this.onBack});

  @override
  State<AddLectureScreen> createState() => _AddLectureScreenState();
}

class _AddLectureScreenState extends State<AddLectureScreen> {
  String _selectedType = 'Video'; // Default to Video
  final TextEditingController _titleController = TextEditingController();
  String? _videoType;
  String? _visibility;
  final TextEditingController _youtubeIdController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String _selectedVideoFileName = 'No File Chosen'; // Specific to Video
  String _selectedPDFFileName = 'No File Chosen'; // Specific to PDF
  String _selectedAudioFileName = 'No File Chosen'; // Specific to Audio
  String _selectedImageFileName = 'No File Chosen'; // Specific to Image
  final TextEditingController _slideEmbedCodeController = TextEditingController(); // For Slides

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
  void dispose() {
    _titleController.dispose();
    _youtubeIdController.dispose();
    _durationController.dispose();
    _slideEmbedCodeController.dispose(); // Dispose new controller
    super.dispose();
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
                            if (_selectedType == 'Video' || _selectedType == 'PDF' || _selectedType == 'Image' || _selectedType == 'Slides' || _selectedType == 'Audio')
                              SizedBox(height: 16.h),
                            CustomTextFormField(
                              controller: _titleController,
                              hintText: 'Enter Lecture Title',
                              labelText: 'Lecture Title',
                            ),
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
                              CustomTextFormField(
                                controller: _youtubeIdController,
                                hintText: 'Enter YouTube ID',
                                labelText: 'YouTube ID',
                              ),
                            if (_selectedType == 'YouTube')
                              SizedBox(height: 16.h),
                            if (_selectedType == 'YouTube')
                              CustomTextFormField(
                                controller: _durationController,
                                hintText: 'Enter File Duration',
                                labelText: 'File Duration (e.g., 10:00)',
                              ),
                            if (_selectedType == 'YouTube')
                              SizedBox(height: 16.h),
                            CustomDropdown(
                              hint: 'Select Visibility',
                              value: _visibility,
                              items: ['Show', 'Lock'],
                              onChanged: (value) {
                                setState(() {
                                  _visibility = value;
                                });
                              },
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
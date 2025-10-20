import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';

class FileChoosenWidget extends StatefulWidget {
  final Function(String?) onFileSelected; // Callback to pass the file path
  final String? errorText; // For validation error text
  final String? originalFileName; // ✅ NEW: Original file name
  final bool showOriginalFile;    // ✅ NEW: Show original file

  const FileChoosenWidget({
    Key? key,
    required this.onFileSelected,
    this.errorText,
    this.originalFileName,        // ✅ NEW
    this.showOriginalFile = false, // ✅ NEW
  }) : super(key: key);

  @override
  _FileChoosenWidgetState createState() => _FileChoosenWidgetState();
}

class _FileChoosenWidgetState extends State<FileChoosenWidget> {
  String? _fileName;
  String? _filePath;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'zip'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _fileName = result.files.single.name;
          _filePath = result.files.single.path;
        });
        widget.onFileSelected(_filePath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ NEW: Show Original File (TOP)
        if (widget.showOriginalFile && widget.originalFileName != null && widget.originalFileName!.isNotEmpty) ...[
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.green[50],
              border: Border.all(color: Colors.green!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.description, color: Colors.green, size: 16.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Current: ${widget.originalFileName}',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    widget.onFileSelected(null); // Replace current file
                  },
                  icon: Icon(Icons.close, size: 16.sp, color: Colors.red),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
        ],

        // ✅ YOUR EXISTING CODE (Upload File Label)
        const Text(
          'Upload File',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),

        // ✅ YOUR EXISTING CODE (Choose Button + Display)
        Row(
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _fileName != null ? 'Change File' : 'Choose File',
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _fileName ?? 'No file chosen',
                  style: TextStyle(
                    color: _fileName == null ? Colors.grey : Colors.black,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),

        // ✅ YOUR EXISTING CODE (Accepted files)
        Text(
          'Accepted files (PDF or ZIP)',
          style: TextStyle(color: Colors.grey, fontSize: 12.sp),
        ),

        // ✅ YOUR EXISTING CODE (Error)
        if (widget.errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              widget.errorText!,
              style: TextStyle(color: Colors.red, fontSize: 12.sp),
            ),
          ),
      ],
    );
  }
}
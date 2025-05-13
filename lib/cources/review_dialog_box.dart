import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/api_constant.dart';


class WriteReviewDialog extends StatefulWidget {
  final String courseId;
  const WriteReviewDialog({Key? key, required this.courseId}) : super(key: key);

  @override
  _WriteReviewDialogState createState() => _WriteReviewDialogState();
}

class _WriteReviewDialogState extends State<WriteReviewDialog> {
  double? _selectedRating; // For storing the selected rating
  final TextEditingController _feedbackController = TextEditingController(); // Controller for feedback
  bool _isSubmitPressed = false; // Track if submit button was pressed
  String? _snackbarMessage; // Message to show
  Color _snackbarColor = Colors.transparent; // Snackbar background color
  bool _showSnackbar = false; // Control visibility of the snackbar
  double _snackbarTopPosition = -50; // Initial top position of the snackbar

  Future<void> _submitReview() async {
    setState(() {
      _isSubmitPressed = true;
    });

    final isFeedbackValid = _feedbackController.text.isNotEmpty;

    if (_selectedRating == null || !isFeedbackValid) {
      // Show error snackbar
      _showCustomSnackBar("Please select Star and give feedback", Colors.red);
    } else {
      // Fetch the token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('auth_token') ?? '';

      // API URL
      String url = "${ApiConstant.baseUrl}student/course/review-create";

      // API Request Body
      Map<String, dynamic> requestBody = {
        "course_id": widget.courseId, // Use the dynamic course ID
        "rating": _selectedRating?.toInt(),
        "comment": _feedbackController.text,
      };

      try {
        // Make the POST request
        final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: json.encode(requestBody),
        );

        // Handle API response
        if (response.statusCode == 200) {
          _showCustomSnackBar("Your review submitted successfully", Colors.green);
          print('Reponse of Review API: ${response.statusCode}');
          print('Successfully submitted review');
          print("Check the selected Rating: $_selectedRating");
          print('show the feedbackcontroller: $_feedbackController');

          // Reset form
          Future.delayed(const Duration(milliseconds: 500), () {
            setState(() {
              _selectedRating = null;
              _feedbackController.clear();
              _isSubmitPressed = false;
            });
            Navigator.of(context).pop(); // Close the dialog
          });
        }
        else {
          _showCustomSnackBar("Already you have reviewed. Thank you.", Colors.red);
          print('Failed to submit review: ${response.body}');
        }
      } catch (e) {
        _showCustomSnackBar("An error occurred: $e", Colors.red);
      }
    }
  }

  void _showCustomSnackBar(String message, Color color) {
    setState(() {
      _snackbarMessage = message;
      _snackbarColor = color;
      _snackbarTopPosition = 0; // Show the snackbar from the top
      _showSnackbar = true;
    });

    // Snackbar stays for 3 seconds and then hides
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _snackbarTopPosition = -50; // Move the snackbar back up
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        // Hide snackbar after animation
        setState(() {
          _showSnackbar = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Write a Review",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Select Rating",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                RatingBar(
                  initialRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 21,
                  glow: false,
                  ratingWidget: RatingWidget(
                    full: const Image(
                      image: AssetImage("assets/courcesreviewfillicon.png"),
                      height: 21,
                      width: 21,
                    ),
                    half: const Image(
                      image: AssetImage("assets/courcesreviewemptyicon.png"),
                      height: 21,
                      width: 21,
                    ),
                    empty: const Image(
                      image: AssetImage("assets/courcesreviewemptyicon.png"),
                      height: 21,
                      width: 21,
                    ),
                  ),
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _selectedRating = rating;
                    });
                  },
                ),
                if (_isSubmitPressed && _selectedRating == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Please select a star rating",
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 15),
                const Text(
                  "Feedback",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _feedbackController,
                  maxLines: 5,
                  cursorColor: const Color(0xFF78A03F),
                  decoration: InputDecoration(
                    hintText: "Please write your feedback here",
                    hintStyle: const TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _feedbackController.text.isNotEmpty
                            ? const Color(0XFF8CC13F)
                            : Colors.red,
                        width: 1,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _isSubmitPressed &&
                            _feedbackController.text.isEmpty
                            ? Colors.red
                            : Colors.grey,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF8CC13F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _submitReview,
                      child: const Text(
                        "Submit Review",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: _snackbarTopPosition,
            left: 0,
            right: 0,
            child: _showSnackbar
                ? Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 12, horizontal: 16),
              color: _snackbarColor,
              child: Text(
                _snackbarMessage ?? "",
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

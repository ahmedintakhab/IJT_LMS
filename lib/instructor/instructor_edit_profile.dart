
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learn_megnagmet/models/new_user_detail.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../controller/controller.dart';
import '../utils/api_constant.dart';
import '../utils/screen_size.dart';
import '../widget/custom_dropdown.dart';
import '../widget/custom_text_form_field.dart';

class InstructorEditScreen extends StatefulWidget {
  const InstructorEditScreen({Key? key, required User user}) : super(key: key);

  @override
  State<InstructorEditScreen> createState() => _InstructorEditScreenState();
}

class _InstructorEditScreenState extends State<InstructorEditScreen> {
  EditScreenController editScreenController = Get.put(EditScreenController());
  late TextEditingController firstnameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController lastNameController;
  late TextEditingController professionalTitleController;
  late TextEditingController avatarUrlController;
  late TextEditingController phoneNumberController;
  late TextEditingController bioController;
  late TextEditingController skillsController;
  late TextEditingController facebookController;
  late TextEditingController twitterController;
  late TextEditingController linkedinController;
  late TextEditingController pinterestController;
  String? avatarUrl;
  File? _selectedImage;
  String? _selectedGender;
  final List<String> _gender = ['Male', 'Female', 'Others'];
  final ImagePicker _picker = ImagePicker();
  bool isLoading = true; // Loading state
  bool isUpdating = false;
  String? instructorUuid;

  @override
  void initState() {
    super.initState();
    firstnameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    lastNameController = TextEditingController();
    professionalTitleController = TextEditingController();
    avatarUrlController = TextEditingController();
    phoneNumberController = TextEditingController();
    bioController = TextEditingController();
    skillsController = TextEditingController();
    skillsController = TextEditingController();
    facebookController = TextEditingController();
    twitterController = TextEditingController();
    linkedinController = TextEditingController();
    pinterestController = TextEditingController();
    _fetchProfileData();
  }
  Future<void> _fetchProfileData() async {
    final String apiUrl = "${ApiConstant.baseUrl}instructor/profile";
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        print("Fetch Instructor Profile data API response: ${response.statusCode}");

        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          final instructorData = jsonResponse['data']['instructor'];
          setState(() {
            instructorUuid = instructorData['uuid']; // Fetch and store UUID
            firstnameController.text = instructorData['first_name'] ?? '';
            lastNameController.text = instructorData['last_name'] ?? '';
            emailController.text = instructorData['email'] ?? '';
            phoneNumberController.text = instructorData['phone'] ?? '';
            professionalTitleController.text = instructorData['professional_title'] ?? '';
            bioController.text = instructorData['bio'] ?? '';
            _selectedGender = instructorData['gender'] ?? '';
            avatarUrl = instructorData['image_url'] ?? '';
            // facebookController.text = instructorData['social_link']['facebook'] ?? '';
            // twitterController.text = instructorData['social_link']['twitter'] ?? '';
            // linkedinController.text = instructorData['social_link']['linkedin'] ?? '';
            // pinterestController.text = instructorData['social_link']['pinterest'] ?? '';
            // skillsController.text = (instructorData['skills'] as List<dynamic>?)?.join(', ') ?? '';
            isLoading = false; // Data fetched, stop loading
          });
        } else {
          print("API Error: ${jsonResponse['message']}");
          setState(() {
            isLoading = false; // Stop loading even if there's an error
          });
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
        setState(() {
          isLoading = false; // Stop loading even if there's an error
        });
      }
    } catch (e) {
      print("Error fetching profile data: $e");
    }setState(() {
      isLoading = false; // Stop loading even if there's an error
    });
  }
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('avatar', image.path);
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }
  Future<void> _updateProfile() async {
    if (instructorUuid == null) {
      print("Instructor UUID is not available");
      return;
    }

    setState(() {
      isUpdating = true; // Start loading
    });

    final String apiUrl = "${ApiConstant.baseUrl}instructor/profile/update/$instructorUuid";
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Add text fields
      request.fields['email'] = emailController.text;
      request.fields['first_name'] = firstnameController.text;
      request.fields['last_name'] = lastNameController.text;
      request.fields['professional_title'] = professionalTitleController.text;
      request.fields['phone_number'] = phoneNumberController.text;
      request.fields['about_me'] = bioController.text;
      request.fields['gender'] = _selectedGender ?? '';

      // Add image if selected
      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(respStr);
        if (jsonResponse['success'] == true) {
          print("Profile updated successfully: ${jsonResponse['message']}");
          Get.snackbar("Success", "Profile updated successfully");
        } else {
          print("API Error: ${jsonResponse['message']}");
        }
      } else {
        print("HTTP Error: ${response.statusCode}, Response: $respStr");
      }
    } catch (e) {
      print("Error updating profile: $e");
    } finally {
      setState(() {
        isUpdating = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeScreenSize(context);
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
            children: [
              if (!isLoading)
                SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(left: 20.w, right: 20.w),
                  child: SingleChildScrollView(
                      child:Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.h),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Get.back();
                                  },
                                  child: const Icon(Icons.arrow_back_ios),
                                ),
                                SizedBox(width: 16.w),
                                Text(
                                  "Edit Profile",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24.sp,
                                    fontFamily: 'Gilroy',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10.h),
                                Center(
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      CircleAvatar(
                                        radius: 50.h,
                                        backgroundImage: _selectedImage != null
                                            ? FileImage(_selectedImage!)
                                            : (avatarUrl != null && avatarUrl!.isNotEmpty
                                            ? NetworkImage(avatarUrl!)
                                            : const AssetImage("assets/person.png")) as ImageProvider,
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: _pickImage,
                                          child: CircleAvatar(
                                            radius: 17.h,
                                            backgroundColor: Color(0XFF78A03F),
                                            child: Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 20.h,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5.h),
                                Center(
                                  child: Text(
                                    "Accepted image files: .JPEG, .JPG, .PNG\nAccepted Size: 300 x 300 (1MB)",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontFamily: 'Gilroy',
                                      color: Colors.black54,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildLabel("First Name", true),
                                          SizedBox(height: 10.h),
                                          CustomTextFormField(
                                            controller: firstnameController,
                                            hintText: "First Name",
                                            validator: (value) => value!.isEmpty ? "Enter your name" : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          _buildLabel("Last Name", true),
                                          SizedBox(height: 10.h),
                                          CustomTextFormField(
                                            controller: lastNameController,
                                            hintText: "Last Name",
                                            validator: (value) => value!.isEmpty ? "Enter your last name" : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.h),
                                _buildLabel("Email", true),
                                SizedBox(height: 10.h),
                                CustomTextFormField(
                                  controller: emailController,
                                  hintText: "Email",
                                  validator: (value) => value!.isEmpty ? "Enter your email" : null,
                                ),
                                SizedBox(height: 20.h),
                                _buildLabel("Professional Title", false),
                                SizedBox(height: 10.h),
                                CustomTextFormField(
                                  controller: professionalTitleController,
                                  hintText: "Title",
                                  validator: (value) => null,
                                ),
                                SizedBox(height: 20.h),
                                _buildLabel("Phone Number", true),
                                SizedBox(height: 10.h),
                                CustomTextFormField(
                                  controller: phoneNumberController,
                                  hintText: "3035454888",
                                  validator: (value) => value!.isEmpty ? "Enter your phone number" : null,
                                ),
                                SizedBox(height: 20.h),
                                _buildLabel("Bio", false),
                                SizedBox(height: 10.h),
                                CustomTextFormField(
                                  controller: bioController,
                                  hintText: "Bio",
                                  validator: (value) => null,
                                ),
                                SizedBox(height: 20.h),
                                _buildLabel("Gender", false),
                                SizedBox(height: 10.h),
                                CustomDropdown(
                                  hint: 'Select Gender',
                                  value: _selectedGender,
                                  items: _gender,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedGender = newValue;
                                    });
                                  },
                                ),
                                SizedBox(height: 20.h),
                                _buildLabel("Social Links", false),
                                _buildLabel("Facebook", false),
                                SizedBox(height: 10.h),
                                CustomTextFormField(
                                  controller: TextEditingController(),
                                  hintText: "https://facebook.com",
                                  validator: (value) => null,
                                ),
                                SizedBox(height: 20.h),
                                _buildLabel("Linkedin", false),
                                SizedBox(height: 10.h),
                                CustomTextFormField(
                                  controller: TextEditingController(),
                                  hintText: "https://linkedin.com",
                                  validator: (value) => null,
                                ),
                                SizedBox(height: 20.h),
                                _buildLabel("Twitter", false),
                                SizedBox(height: 10.h),
                                CustomTextFormField(
                                  controller: TextEditingController(),
                                  hintText: "https://twitter.com",
                                  validator: (value) => null,
                                ),
                                SizedBox(height: 20.h),
                                _buildLabel("Pinterest", false),
                                SizedBox(height: 10.h),
                                CustomTextFormField(
                                  controller: TextEditingController(),
                                  hintText: "https://pinterest.com",
                                  validator: (value) => null,
                                ),
                                SizedBox(height: 20.h),
                                _buildLabel("Skills", false),
                                SizedBox(height: 10.h),
                                CustomTextFormField(
                                  controller: skillsController,
                                  hintText: "",
                                  validator: (value) => null,
                                ),
                                SizedBox(height: 40.h),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CustomButton(
                                      onTap: _updateProfile,
                                      buttonText: isUpdating ? '' : 'Update Profile',
                                    ),
                                    if (isUpdating)
                                      const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                  ],
                                ),
                                SizedBox(height: 20.h),
                              ],
                            ),
                          ]
                      )

                  ),
                ),
              ),
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF00AFEE),
                    strokeWidth: 4,
                  ),
                ),
            ]
        ),
      ),
    );
  }
}

Widget _buildLabel(String label, bool isRequired) {
  return Row(
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Gilroy',
          color: const Color(0xFF000080),
        ),
      ),
      if (isRequired)
        Text(
          " *",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Gilroy',
            color: Colors.red,
          ),
        ),
    ],
  );
}
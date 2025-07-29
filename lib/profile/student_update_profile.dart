import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learn_megnagmet/models/new_user_detail.dart';
import 'package:learn_megnagmet/widget/button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../controller/controller.dart';
import '../home/home_main.dart';
import '../utils/api_constant.dart';
import '../utils/screen_size.dart';
import '../widget/custom_dropdown.dart';
import '../widget/custom_text_form_field.dart';
import '../profile/my_profile.dart'; // Import MyProfile screen

class StudentUpdateProfile extends StatefulWidget {
  const StudentUpdateProfile({Key? key}) : super(key: key);

  @override
  State<StudentUpdateProfile> createState() => _StudentUpdateProfileState();
}

class _StudentUpdateProfileState extends State<StudentUpdateProfile> {
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

  String? avatarUrl;
  File? _selectedImage;
  String? _selectedGender;
  final List<String> _gender = ['Male', 'Female', 'Others'];
  final ImagePicker _picker = ImagePicker();
  bool isLoading = true;
  bool isUpdating = false;
  String? studentUuid;

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

    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    final String apiUrl = "${ApiConstant.baseUrl}student/profile";
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
        print("Fetch Profile Data API response: ${response.statusCode}");
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          final studentData = jsonResponse['data']['student'];
          setState(() {
            studentUuid = studentData['uuid'];
            firstnameController.text = studentData['first_name'] ?? '';
            lastNameController.text = studentData['last_name'] ?? '';
            emailController.text = studentData['email'] ?? '';
            phoneNumberController.text = studentData['phone'] ?? '';
            professionalTitleController.text = studentData['professional_title'] ?? '';
            bioController.text = studentData['bio'] ?? '';
            _selectedGender = (studentData['gender'] != null && studentData['gender'].isNotEmpty)
                ? studentData['gender']
                : null;
            avatarUrl = (studentData['image_url'] != null && studentData['image_url'].isNotEmpty)
                ? studentData['image_url']
                : null;
            isLoading = false;
          });
        } else {
          print("API Error: ${jsonResponse['message']}");
          Get.snackbar(
            'Error',
            'Failed to fetch profile data: ${jsonResponse['message']}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
        Get.snackbar(
          'Error',
          'Failed to fetch profile data: ${response.statusCode}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching profile data: $e");
      Get.snackbar(
        'Error',
        'Error fetching profile data: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        isLoading = false;
      });
    }
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
      Get.snackbar(
        'Error',
        'Error picking image: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _fetchProfileImage() async {
    final String apiUrl = "${ApiConstant.baseUrl}student/show-profile-image";
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        print("Profile Image API response status: ${response.statusCode}");
        print("Profile Image API response body: ${response.body}");
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          final profileImage = jsonResponse['data']['profile_image'] ?? '';
          final userName = jsonResponse['data']['user_name'] ?? '';
          final userEmail = jsonResponse['data']['user_email'] ?? '';
          if (profileImage.isNotEmpty) {
            await prefs.setString('image', profileImage);
            await prefs.setString('userName', userName);
            await prefs.setString('userEmail', userEmail);
            print("Profile data saved to SharedPreferences: $profileImage $userEmail $userName");
          } else {
            print("No profile image URL in response");
          }
        } else {
          print("API Error: ${jsonResponse['message']}");
        }
      } else {
        print("HTTP Error: ${response.statusCode}, Response: ${response.body}");
      }
    } catch (e) {
      print("Error fetching profile image: $e");
    }
  }

  Future<void> _updateProfile() async {
    if (studentUuid == null) {
      print("Student UUID is not available");
      Get.snackbar(
        'Error',
        'Student UUID is not available',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      isUpdating = true;
    });

    final String apiUrl = "${ApiConstant.baseUrl}student/save-profile/$studentUuid";
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('authToken') ?? '';
      print("Updating profile with token: $token");

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['email'] = emailController.text;
      request.fields['first_name'] = firstnameController.text;
      request.fields['last_name'] = lastNameController.text;
      request.fields['mobile_number'] = phoneNumberController.text;
      request.fields['about_me'] = bioController.text;
      request.fields['gender'] = _selectedGender ?? '';

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));
        print("Image file added to request: ${_selectedImage!.path}");
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      print("Profile Update API response status: ${response.statusCode}");
      print("Profile Update API response body: $respStr");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(respStr);
        if (jsonResponse['success'] == true) {
          print("Profile updated successfully: ${jsonResponse['message']}");
          Get.snackbar(
            "Success",
            "Profile updated successfully",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Fetch profile image after successful update
          await _fetchProfileImage();
          Get.off(() => const HomeMainScreen());

          // Navigator.of(context).pop();
        } else {
          print("API Error: ${jsonResponse['message']}");
          Get.snackbar(
            'Error',
            'Failed to update profile: ${jsonResponse['message']}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        print("HTTP Error: ${response.statusCode}, Response: $respStr");
        Get.snackbar(
          'Error',
          'Failed to update profile: ${response.statusCode}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error updating profile: $e");
      Get.snackbar(
        'Error',
        'Error updating profile: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isUpdating = false;
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
                    child: Column(
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
                                        backgroundColor: const Color(0XFF78A03F),
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
                            _buildLabel("Profile Page Meta Title", false),
                            SizedBox(height: 10.h),
                            CustomTextFormField(
                              controller: skillsController,
                              hintText: "Meta Title",
                              validator: (value) => null,
                            ),
                            SizedBox(height: 20.h),
                            _buildLabel("Profile Page Meta Description", false),
                            SizedBox(height: 10.h),
                            CustomTextFormField(
                              controller: professionalTitleController,
                              hintText: "Meta Description",
                              validator: (value) => null,
                            ),
                            SizedBox(height: 20.h),
                            _buildLabel("Profile Page Keywords", false),
                            SizedBox(height: 10.h),
                            CustomTextFormField(
                              controller: professionalTitleController,
                              hintText: "Meta Keywords",
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
                      ],
                    ),
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
          ],
        ),
      ),
    );
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
}
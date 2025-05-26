import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widget/custom_dropdown.dart';

class AffiliationField extends StatefulWidget {
  const AffiliationField({super.key, required TextEditingController controller});

  @override
  AffiliationFieldState createState() => AffiliationFieldState();
}

class AffiliationFieldState extends State<AffiliationField> {
  bool _hasAffiliation = false; // Default to "No"
  String? _selectedMemberLevel; // To store the selected dropdown value

  @override
  void initState() {
    super.initState();
    // Load the saved affiliation value from SharedPreferences when the widget initializes
    _loadAffiliation();
  }

  // Load the affiliation value from SharedPreferences
  Future<void> _loadAffiliation() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAffiliation = prefs.getInt('has_affiliation');
    if (savedAffiliation != null) {
      setState(() {
        _hasAffiliation = savedAffiliation == 1;
      });
    }
  }

  // Save the affiliation value to SharedPreferences
  Future<void> _saveAffiliation(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    // Store 1 for "Yes" and 0 for "No"
    await prefs.setInt('has_affiliation', value ? 1 : 0);
    print('saveAffiliation: Saved has_affiliation: ${value ? 1 : 0}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: _hasAffiliation,
              onChanged: (value) {
                setState(() {
                  _hasAffiliation = value!;
                  if (!value) {
                    _selectedMemberLevel = null; // Reset dropdown when "No" is selected
                  }
                });
                // Save the value to SharedPreferences (1 for "Yes")
                _saveAffiliation(value!);
              },
              activeColor: const Color(0xFF00AFEE),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity(
                horizontal: VisualDensity.minimumDensity,
                vertical: VisualDensity.minimumDensity,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Yes, I have affiliation with Islami Jamiat-e-Talaba',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Gilroy',
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Radio<bool>(
              value: false,
              groupValue: _hasAffiliation,
              onChanged: (value) {
                setState(() {
                  _hasAffiliation = value!;
                  if (!value) {
                    _selectedMemberLevel = null; // Reset dropdown when "No" is selected
                  }
                });
                // Save the value to SharedPreferences (0 for "No")
                _saveAffiliation(value!);
              },
              activeColor: const Color(0xFF00AFEE),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity(
                horizontal: VisualDensity.minimumDensity,
                vertical: VisualDensity.minimumDensity,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'No',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Gilroy',
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        if (_hasAffiliation) ...[
          SizedBox(height: 10.h),
          CustomDropdown(
            hint: 'Select Member Level',
            value: _selectedMemberLevel,
            items: const ['Karkun', 'Rafiq', 'Umidwar', 'Rukan'], // Dropdown options
            onChanged: (value) {
              setState(() {
                _selectedMemberLevel = value;
              });
            },
          ),
        ],
      ],
    );
  }
}
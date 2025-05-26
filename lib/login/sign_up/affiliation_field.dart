import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widget/custom_dropdown.dart';

class AffiliationField extends StatefulWidget {
  final TextEditingController controller;
  final Function(bool?) onAffiliationChanged;

  const AffiliationField({
    super.key,
    required this.controller,
    required this.onAffiliationChanged,
  });

  @override
  AffiliationFieldState createState() => AffiliationFieldState();
}

class AffiliationFieldState extends State<AffiliationField> {
  bool _hasAffiliation = false; // Default to "No" (false)
  String? _selectedMemberLevel;

  @override
  void initState() {
    super.initState();
    _loadAffiliation();
  }

  Future<void> _loadAffiliation() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('has_affiliation')) {
      // Set default to "No" (0) if not already set
      await prefs.setInt('has_affiliation', 0);
    }
    final savedAffiliation = prefs.getInt('has_affiliation');
    setState(() {
      _hasAffiliation = savedAffiliation == 1;
    });
    widget.onAffiliationChanged(_hasAffiliation);
  }

  Future<void> _saveAffiliation(bool value) async {
    final prefs = await SharedPreferences.getInstance();
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
                    _selectedMemberLevel = null;
                  }
                });
                _saveAffiliation(value!);
                widget.onAffiliationChanged(value);
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
                  _selectedMemberLevel = null;
                });
                _saveAffiliation(value!);
                widget.onAffiliationChanged(value);
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
            items: const ['Karkun', 'Rafiq', 'Umidwar', 'Rukan'],
            onChanged: (value) {
              setState(() {
                _selectedMemberLevel = value;
                widget.controller.text = value ?? '';
              });
            },
          ),
        ],
      ],
    );
  }
}
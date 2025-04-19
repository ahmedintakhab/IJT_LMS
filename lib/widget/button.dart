import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomButton extends StatelessWidget {
  CustomButton({
    required this.onTap,
    this.borderRadius,
    this.buttonColor,
    required this.buttonText,
    this.textColor,
    this.isLoading = false,  // Added loading parameter
    Key? key,
  }) : super(key: key);

  final VoidCallback onTap;
  final Color? buttonColor;
  final double? borderRadius;
  final Color? textColor;
  final String buttonText;
  final bool isLoading;  // Loading state

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,  // Disable tap when loading
      child: Container(
        height: 56,
        width: 374,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 20),
          color: buttonColor ?? const Color(0XFF00AFEE),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : Text(
            buttonText,
            style: TextStyle(
              color: textColor ?? const Color(0XFFFFFFFF),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Gilroy',
            ),
          ),
        ),
      ),
    );
  }
}
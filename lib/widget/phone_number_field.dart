import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

Widget phone_number_field({
  required Function(String) onPhoneNumberChanged,
  String? Function(String?)? validator,
}) {
  return FormField<String>(
    validator: validator,
    builder: (FormFieldState<String> state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntlPhoneField(
            decoration: InputDecoration(
              labelText: 'Phone Number',
              labelStyle: TextStyle(
                fontFamily: 'Gilroy',
                fontWeight: FontWeight.w700,
                fontSize: 14.0,
                color: Color(0XFF9B9B9B),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0XFFDEDEDE), width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0XFF23408F), width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0XFFDEDEDE), width: 1.0),
                borderRadius: BorderRadius.circular(12),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
            initialCountryCode: 'PK', // Default country code
            onChanged: (phone) {
              onPhoneNumberChanged(phone.completeNumber);
              state.didChange(phone.completeNumber); // Update the FormField state
            },
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                state.errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      );
    },
  );
}

import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool isObscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextStyle? style;
  final InputDecoration? decoration;
  final void Function(String)? onChanged;

  const CustomField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isObscureText = false,
    this.readOnly = false,
    this.onTap,
    this.style,
    this.decoration,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onTap,
      readOnly: readOnly,
      controller: controller,
      style: style,
      decoration: (decoration ?? InputDecoration(hintText: hintText)).copyWith(
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
      validator: (val) {
        if (val!.trim().isEmpty) {
          return "$hintText bị thiếu!";
        }
        return null;
      },
      obscureText: isObscureText,
      onChanged: onChanged,
    );
  }
}

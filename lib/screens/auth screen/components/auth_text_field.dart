import 'package:flutter/material.dart';
import 'package:stories_by_parin/utils/colors.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? label;
  final bool obscureText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool showPasswordToggle;

  const AuthTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.label,
    required this.obscureText,
    required this.prefixIcon,
    this.keyboardType,
    this.validator,
    this.showPasswordToggle = false
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {

  late bool _isObscured;

  @override
  void initState() {
    super.initState();

    // Start with the value supplied by the parent.
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
    },
      controller: widget.controller,
      obscureText: _isObscured,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        hintText: widget.hintText,

        // Keeps the text vertically centered.
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),

        // ---------------------------------------------------------
        // PREFIX ICON
        // ---------------------------------------------------------
        //
        // prefixIcon is always part of the field decoration.
        // It will remain visible whether the field is focused or not.
        //
        prefixIcon: Icon(
          widget.prefixIcon,
          color: primaryColor,
          size: 30,
        ),

        // Controls the space reserved for the prefix icon.
        prefixIconConstraints: const BoxConstraints(
          minWidth: 55,
          minHeight: 55,
        ),

        // Show eye button only when requested.
        suffixIcon: widget.showPasswordToggle
            ? IconButton(
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured;
            });
          },
          icon: Icon(
            _isObscured
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        )
            : null,


        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: primaryColor,
            width: 3,
          ),
        ),
      ),
    );
  }
}

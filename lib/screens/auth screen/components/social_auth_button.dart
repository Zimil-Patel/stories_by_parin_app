import 'package:flutter/material.dart';

class SocialAuthButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialAuthButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: ButtonStyle(
          side: WidgetStatePropertyAll(BorderSide(color: Colors.black))
        ),
        icon: Icon(icon, size: 26, color: Colors.black,),
        label: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        )
            : Text(text, style: TextStyle(color: Colors.black, fontSize: 18),),
      ),
    );
  }
}
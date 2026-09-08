import 'package:flutter/material.dart';

class SelfieLoadingOverlay extends StatelessWidget {
  const SelfieLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: ColoredBox(
        color: Colors.black54,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }
}

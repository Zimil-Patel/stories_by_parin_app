import 'package:flutter/material.dart';

class SelfieFaceGuide extends StatelessWidget {
  const SelfieFaceGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        children: [
          const Spacer(),

          const Text(
            'Position your face inside the frame',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 18),

          Container(
            width: 230,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(140),
            ),
          ),

          const Spacer(),

          // Reserve space for bottom controls.
          const SizedBox(height: 130),
        ],
      ),
    );
  }
}

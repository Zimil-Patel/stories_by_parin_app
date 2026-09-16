import 'package:flutter/material.dart';
import 'package:stories_by_parin/utils/images.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            bgImage,
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
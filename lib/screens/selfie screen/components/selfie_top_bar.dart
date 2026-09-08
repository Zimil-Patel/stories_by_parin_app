import 'package:flutter/material.dart';

class SelfieTopBar extends StatelessWidget {
  final VoidCallback? onClose;
  final VoidCallback? onSwitchCamera;

  const SelfieTopBar({
    super.key,
    required this.onClose,
    required this.onSwitchCamera,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _CircleButton(icon: Icons.close, onPressed: onClose),

            _CircleButton(
              icon: Icons.flip_camera_ios,
              onPressed: onSwitchCamera,
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _CircleButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Colors.black45,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

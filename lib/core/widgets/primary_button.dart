import 'package:flutter/material.dart';

/// Full-width rounded button used across the app; supports a busy spinner
/// and an outlined variant, matching the Figma design.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final bool outlined;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.busy = false,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = busy
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Text(label);

    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton(onPressed: busy ? null : onPressed, child: child)
          : ElevatedButton(onPressed: busy ? null : onPressed, child: child),
    );
  }
}

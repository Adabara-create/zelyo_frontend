import 'package:flutter/material.dart';
import 'package:zelyo_1/theme/app_colors.dart';

/// Animated row of PIN dots — filled/glowing once a digit is entered.
/// Shared by the passcode entry, create-passcode, and confirm-passcode
/// screens so all three stay visually identical.
class PinDotIndicator extends StatelessWidget {
  final int length;
  final int filledCount;
  final bool hasError;

  const PinDotIndicator({
    super.key,
    required this.length,
    required this.filledCount,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = hasError ? Colors.redAccent : AppColors.primaryBlue;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isFilled = index < filledCount;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 7),
          width: isFilled ? 15 : 13,
          height: isFilled ? 15 : 13,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? activeColor : Colors.transparent,
            border: Border.all(
              color: isFilled ? activeColor : AppColors.outlineBorder,
              width: 1.4,
            ),
            boxShadow: isFilled
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 0.5,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
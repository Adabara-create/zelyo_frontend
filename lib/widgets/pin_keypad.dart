import 'package:flutter/material.dart';
import 'package:zelyo_1/theme/app_colors.dart';

/// Shared 3x4-style numeric keypad: digits 1-9, an optional custom key
/// (e.g. fingerprint) in the bottom-left slot, 0, and backspace.
/// Used by the passcode entry, create-passcode, and confirm-passcode
/// screens so all three stay visually identical.
class PinKeypad extends StatelessWidget {
  final ValueChanged<String> onDigitTap;
  final VoidCallback onBackspaceTap;

  /// Widget shown in the bottom-left slot instead of an empty spacer —
  /// pass null to leave that slot empty (keeps "0" centered).
  final Widget? bottomLeftKey;

  const PinKeypad({
    super.key,
    required this.onDigitTap,
    required this.onBackspaceTap,
    this.bottomLeftKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 18),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 18),
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            bottomLeftKey ?? const SizedBox(width: 64, height: 64),
            _buildDigitKey('0'),
            _buildBackspaceKey(),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map(_buildDigitKey).toList(),
    );
  }

  Widget _buildDigitKey(String digit) {
    return PinKeypadKey(
      onTap: () => onDigitTap(digit),
      child: Text(
        digit,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return PinKeypadKey(
      onTap: onBackspaceTap,
      isFilled: false,
      child: const Icon(
        Icons.backspace_outlined,
        color: AppColors.textMuted,
        size: 22,
      ),
    );
  }
}

/// A single circular keypad button. Exposed publicly so screens can build
/// a matching custom key (e.g. fingerprint) for the [PinKeypad.bottomLeftKey]
/// slot with identical sizing/ripple behavior.
class PinKeypadKey extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final bool isFilled;

  const PinKeypadKey({
    super.key,
    required this.onTap,
    required this.child,
    this.isFilled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isFilled ? AppColors.surface : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        splashColor: AppColors.primaryBlue.withOpacity(0.18),
        highlightColor: AppColors.primaryBlue.withOpacity(0.10),
        child: SizedBox(
          width: 64,
          height: 64,
          child: Center(child: child),
        ),
      ),
    );
  }
}
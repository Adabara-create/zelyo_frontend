import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/widgets/pin_dot_indicator.dart';
import 'package:zelyo_1/widgets/pin_keypad.dart';

/// Generic 4-digit mobile transaction PIN check — reused anywhere the
/// card flow needs to confirm it's really the account owner (opening a
/// new card, viewing full card details, blocking a card). This screen
/// doesn't know or care what happens next; it just pops `true` on a
/// correct PIN, `false`/`null` otherwise, and the caller decides what
/// to do with that.
///
/// This is the same transaction PIN used in [AuthorizeTransactionScreen]
/// — not the separate, card-specific PIN created in
/// [CreateCardPinScreen].
class VerifyTransactionPinScreen extends StatefulWidget {
  final String purpose;

  const VerifyTransactionPinScreen({
    super.key,
    this.purpose = 'Enter your PIN to continue',
  });

  @override
  State<VerifyTransactionPinScreen> createState() => _VerifyTransactionPinScreenState();
}

class _VerifyTransactionPinScreenState extends State<VerifyTransactionPinScreen>
    with SingleTickerProviderStateMixin {
  static const int _pinLength = 4;

  // TODO: replace with your real stored/verified transaction PIN check.
  static const String _correctPin = '1234';

  String _pin = '';
  String? _errorText;
  bool _isVerifying = false;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onDigitTap(String digit) {
    if (_pin.length >= _pinLength || _isVerifying) return;
    HapticFeedback.selectionClick();
    setState(() {
      _pin += digit;
      _errorText = null;
    });
    if (_pin.length == _pinLength) _verifyPin();
  }

  void _onBackspaceTap() {
    if (_pin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _errorText = null;
    });
  }

  Future<void> _verifyPin() async {
    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    if (_pin == _correctPin) {
      Navigator.of(context).pop(true);
      return;
    }

    HapticFeedback.mediumImpact();
    _shakeController.forward(from: 0);
    setState(() {
      _isVerifying = false;
      _errorText = 'Incorrect PIN. Try again.';
      _pin = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -90,
            left: -90,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              child: Container(
                width: 260,
                height: 260,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryBlue, AppColors.primaryBlueLight],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(false),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryBlue, AppColors.primaryBlueLight],
                    ),
                    boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.35), blurRadius: 22, spreadRadius: 2)],
                  ),
                  child: const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Verify PIN',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Text(
                    _errorText ?? widget.purpose,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: _errorText != null ? Colors.redAccent : AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  ),
                  child: PinDotIndicator(length: _pinLength, filledCount: _pin.length, hasError: _errorText != null),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: PinKeypad(onDigitTap: _onDigitTap, onBackspaceTap: _onBackspaceTap),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
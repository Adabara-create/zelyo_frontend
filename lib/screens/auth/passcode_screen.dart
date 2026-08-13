import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/widgets/pin_dot_indicator.dart';
import 'package:zelyo_1/widgets/pin_keypad.dart';
import 'package:zelyo_1/screens/home/home_shell.dart';

/// PIN-entry screen.
///
/// Purely passcode-based — no biometric option lives here. Once the
/// correct 6-digit passcode is entered, it hands off to whatever's next
/// (currently a bare placeholder Home screen at the bottom of this file —
/// swap [_PlaceholderHomeScreen] out once the real Home screen exists).
class PasscodeScreen extends StatefulWidget {
  /// Called once the correct passcode is entered, right before the
  /// built-in navigation to the placeholder home screen fires. Optional —
  /// use it if you need a side effect (analytics, persisting session
  /// state, etc) without changing where this screen navigates to.
  final VoidCallback? onSuccess;

  const PasscodeScreen({super.key, this.onSuccess});

  @override
  State<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen>
    with SingleTickerProviderStateMixin {
  static const int _passcodeLength = 6;

  // TODO: replace with your real stored/verified passcode check.
  static const String _correctPasscode = '123456';

  String _enteredPasscode = '';
  String? _errorText;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
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
    if (_enteredPasscode.length >= _passcodeLength) return;
    HapticFeedback.selectionClick();

    setState(() {
      _enteredPasscode += digit;
      _errorText = null;
    });

    if (_enteredPasscode.length == _passcodeLength) {
      _verifyPasscode();
    }
  }

  void _onBackspaceTap() {
    if (_enteredPasscode.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _enteredPasscode =
          _enteredPasscode.substring(0, _enteredPasscode.length - 1);
      _errorText = null;
    });
  }

  Future<void> _verifyPasscode() async {
    // Small delay so the user sees the final dot fill before we react.
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;

    if (_enteredPasscode == _correctPasscode) {
      widget.onSuccess?.call();

      // TODO: swap this for a push to the real Home screen once it
      // exists — this is just a stand-in so the flow is navigable now.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeShell(),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    _shakeController.forward(from: 0);
    setState(() {
      _errorText = 'Incorrect passcode. Try again.';
      _enteredPasscode = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ----- Gradient orb, top-left corner -----
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
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.primaryBlueLight,
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // ----- Logo -----
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryBlue,
                        AppColors.primaryBlueLight,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.35),
                        blurRadius: 22,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(height: 28),

                // ----- Headline -----
                const Text(
                  'Enter passcode',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _errorText ?? 'Enter your passcode to continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: _errorText != null
                        ? Colors.redAccent
                        : AppColors.textMuted,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 36),

                // ----- Animated PIN dot indicator -----
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  ),
                  child: PinDotIndicator(
                    length: _passcodeLength,
                    filledCount: _enteredPasscode.length,
                    hasError: _errorText != null,
                  ),
                ),

                const Spacer(),

                // ----- Numeric keypad -----
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: PinKeypad(
                    onDigitTap: _onDigitTap,
                    onBackspaceTap: _onBackspaceTap,
                  ),
                ),

                const SizedBox(height: 20),

                // ----- Forgot passcode -----
                TextButton(
                  onPressed: () {
                    // TODO: navigate to a passcode-recovery flow
                  },
                  child: const Text(
                    'Forgot passcode?',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bare stand-in for the real Home screen, just so the passcode flow has
/// somewhere navigable to land right now. Delete this once the actual
/// bottom-nav Home screen exists and point [PasscodeScreen] there instead.

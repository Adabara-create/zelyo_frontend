import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/widgets/pin_dot_indicator.dart';
import 'package:zelyo_1/widgets/pin_keypad.dart';
import 'package:zelyo_1/screens/auth/create_pin_screen.dart';


/// Second half of onboarding's passcode setup — confirms the passcode
/// entered in [CreatePasscodeScreen] matches, then moves on to offering
/// fingerprint login, and finally to the returning-user welcome screen.
class ConfirmPasscodeScreen extends StatefulWidget {
  final String originalPasscode;

  const ConfirmPasscodeScreen({super.key, required this.originalPasscode});

  @override
  State<ConfirmPasscodeScreen> createState() => _ConfirmPasscodeScreenState();
}

class _ConfirmPasscodeScreenState extends State<ConfirmPasscodeScreen>
    with SingleTickerProviderStateMixin {
  static const int _passcodeLength = 6;

  String _passcode = '';
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
    if (_passcode.length >= _passcodeLength) return;
    HapticFeedback.selectionClick();

    setState(() {
      _passcode += digit;
      _errorText = null;
    });

    if (_passcode.length == _passcodeLength) {
      _verifyMatch();
    }
  }

  void _onBackspaceTap() {
    if (_passcode.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _passcode = _passcode.substring(0, _passcode.length - 1);
      _errorText = null;
    });
  }

  Future<void> _verifyMatch() async {
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;

    if (_passcode == widget.originalPasscode) {
      // TODO: persist the passcode securely (hashed, secure storage) here.
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CreatePinScreen(
            
          ),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    _shakeController.forward(from: 0);
    setState(() {
      _errorText = "Passcodes didn't match. Try again.";
      _passcode = '';
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
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
                    Icons.verified_user_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Confirm your passcode',
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
                  _errorText ?? 'Re-enter your passcode to confirm',
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

                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  ),
                  child: PinDotIndicator(
                    length: _passcodeLength,
                    filledCount: _passcode.length,
                    hasError: _errorText != null,
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: PinKeypad(
                    onDigitTap: _onDigitTap,
                    onBackspaceTap: _onBackspaceTap,
                  ),
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
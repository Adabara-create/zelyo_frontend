import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/widgets/pin_dot_indicator.dart';
import 'package:zelyo_1/widgets/pin_keypad.dart';

/// Sets up the card-specific PIN — deliberately a single screen with an
/// internal create → confirm flow, rather than two separate screens
/// like the app's onboarding passcode setup. This PIN is stored and
/// checked completely separately from the mobile transaction PIN used
/// in [VerifyTransactionPinScreen] — it only ever applies to card
/// operations (e.g. a POS/online purchase asking for a card PIN).
class CreateCardPinScreen extends StatefulWidget {
  const CreateCardPinScreen({super.key});

  @override
  State<CreateCardPinScreen> createState() => _CreateCardPinScreenState();
}

enum _Stage { create, confirm }

class _CreateCardPinScreenState extends State<CreateCardPinScreen>
    with SingleTickerProviderStateMixin {
  static const int _pinLength = 4;

  _Stage _stage = _Stage.create;
  String _firstPin = '';
  String _currentEntry = '';
  String? _errorText;

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
    if (_currentEntry.length >= _pinLength) return;
    HapticFeedback.selectionClick();
    setState(() {
      _currentEntry += digit;
      _errorText = null;
    });

    if (_currentEntry.length != _pinLength) return;

    if (_stage == _Stage.create) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        setState(() {
          _firstPin = _currentEntry;
          _currentEntry = '';
          _stage = _Stage.confirm;
        });
      });
    } else {
      _verifyMatch();
    }
  }

  void _onBackspaceTap() {
    if (_currentEntry.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _currentEntry = _currentEntry.substring(0, _currentEntry.length - 1);
      _errorText = null;
    });
  }

  Future<void> _verifyMatch() async {
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;

    if (_currentEntry == _firstPin) {
      // TODO: persist the card PIN securely (hashed, secure storage /
      // backend) here — separately from the mobile transaction PIN.
      Navigator.of(context).pop(true);
      return;
    }

    HapticFeedback.mediumImpact();
    _shakeController.forward(from: 0);
    setState(() {
      _errorText = "PINs didn't match. Try again.";
      _currentEntry = '';
    });
  }

  void _onBackTap() {
    if (_stage == _Stage.confirm) {
      setState(() {
        _stage = _Stage.create;
        _firstPin = '';
        _currentEntry = '';
        _errorText = null;
      });
    } else {
      Navigator.of(context).maybePop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConfirmStage = _stage == _Stage.confirm;

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
                        onPressed: _onBackTap,
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
                  child: Icon(
                    isConfirmStage ? Icons.verified_user_outlined : Icons.credit_card_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  isConfirmStage ? 'Confirm card PIN' : 'Create card PIN',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _errorText ??
                        (isConfirmStage
                            ? 'Re-enter the 4-digit PIN to confirm'
                            : "This is different from your transaction PIN — it's used only for this card."),
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
                  child: PinDotIndicator(length: _pinLength, filledCount: _currentEntry.length, hasError: _errorText != null),
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
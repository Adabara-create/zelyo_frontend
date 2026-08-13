import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/widgets/pin_dot_indicator.dart';
import 'package:zelyo_1/widgets/pin_keypad.dart';

/// A self-contained change-PIN flow: verify current PIN → create new
/// PIN → confirm new PIN → success, all in one screen with internal
/// stages.
///
/// This exists specifically instead of chaining
/// VerifyTransactionPinScreen → CreatePinScreen (which ends by pushing
/// FingerprintSetupScreen — correct for onboarding, wrong here). Ends
/// by popping `true` back to Profile.
class ChangeTransactionPinScreen extends StatefulWidget {
  const ChangeTransactionPinScreen({super.key});

  @override
  State<ChangeTransactionPinScreen> createState() => _ChangeTransactionPinScreenState();
}

enum _Stage { verify, create, confirm }

class _ChangeTransactionPinScreenState extends State<ChangeTransactionPinScreen>
    with SingleTickerProviderStateMixin {
  static const int _pinLength = 4;

  // TODO: replace with your real stored/verified transaction PIN check
  // and the real persistence call for the new PIN.
  static const String _correctCurrentPin = '1234';

  _Stage _stage = _Stage.verify;
  String _newPin = '';
  String _currentEntry = '';
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
    if (_currentEntry.length >= _pinLength || _isVerifying) return;
    HapticFeedback.selectionClick();
    setState(() {
      _currentEntry += digit;
      _errorText = null;
    });
    if (_currentEntry.length != _pinLength) return;

    switch (_stage) {
      case _Stage.verify:
        _verifyCurrentPin();
        break;
      case _Stage.create:
        Future.delayed(const Duration(milliseconds: 150), () {
          if (!mounted) return;
          setState(() {
            _newPin = _currentEntry;
            _currentEntry = '';
            _stage = _Stage.confirm;
          });
        });
        break;
      case _Stage.confirm:
        _verifyNewPinMatch();
        break;
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

  Future<void> _verifyCurrentPin() async {
    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    if (_currentEntry == _correctCurrentPin) {
      setState(() {
        _isVerifying = false;
        _currentEntry = '';
        _stage = _Stage.create;
      });
      return;
    }

    HapticFeedback.mediumImpact();
    _shakeController.forward(from: 0);
    setState(() {
      _isVerifying = false;
      _errorText = 'Incorrect PIN. Try again.';
      _currentEntry = '';
    });
  }

  Future<void> _verifyNewPinMatch() async {
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;

    if (_currentEntry == _newPin) {
      // TODO: persist the new transaction PIN (hashed, secure storage /
      // backend) before showing success.
      await _showSuccessDialog();
      if (mounted) Navigator.of(context).pop(true);
      return;
    }

    HapticFeedback.mediumImpact();
    _shakeController.forward(from: 0);
    setState(() {
      _errorText = "PINs didn't match. Try again.";
      _currentEntry = '';
    });
  }

  Future<void> _showSuccessDialog() {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.outlineBorder, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.success.withOpacity(0.15)),
                child: const Icon(Icons.check_rounded, color: AppColors.success, size: 38),
              ),
              const SizedBox(height: 20),
              const Text('PIN updated', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text(
                'Your transaction PIN has been changed successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 13.5, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Done', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onBackTap() {
    if (_stage == _Stage.confirm) {
      setState(() {
        _stage = _Stage.create;
        _newPin = '';
        _currentEntry = '';
        _errorText = null;
      });
    } else if (_stage == _Stage.create) {
      setState(() {
        _stage = _Stage.verify;
        _currentEntry = '';
        _errorText = null;
      });
    } else {
      Navigator.of(context).maybePop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (_stage) {
      _Stage.verify => 'Verify current PIN',
      _Stage.create => 'Create new PIN',
      _Stage.confirm => 'Confirm new PIN',
    };
    final subtitle = switch (_stage) {
      _Stage.verify => 'Enter your current 4-digit transaction PIN',
      _Stage.create => 'Choose a new 4-digit PIN',
      _Stage.confirm => 'Re-enter your new PIN to confirm',
    };

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
                    _stage == _Stage.verify ? Icons.lock_outline_rounded : Icons.password_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 28),
                Text(title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Text(
                    _errorText ?? subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.5, color: _errorText != null ? Colors.redAccent : AppColors.textMuted, height: 1.4),
                  ),
                ),
                const SizedBox(height: 36),
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) => Transform.translate(offset: Offset(_shakeAnimation.value, 0), child: child),
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
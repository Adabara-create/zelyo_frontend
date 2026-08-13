import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/widgets/pin_dot_indicator.dart';
import 'package:zelyo_1/widgets/pin_keypad.dart';
import 'package:zelyo_1/models/transfer_models.dart';
import 'transfer_success_screen.dart';

/// Requires a 4-digit transaction PIN to authorize the transfer.
///
/// Deliberately separate from the app's 6-digit unlock passcode
/// ([PasscodeScreen]) — a shorter, transaction-specific PIN is a
/// common pattern so unlocking the app and authorizing money movement
/// aren't gated by the exact same secret.
class AuthorizeTransactionScreen extends StatefulWidget {
  final TransferRequest transfer;

  const AuthorizeTransactionScreen({super.key, required this.transfer});

  @override
  State<AuthorizeTransactionScreen> createState() => _AuthorizeTransactionScreenState();
}

class _AuthorizeTransactionScreenState extends State<AuthorizeTransactionScreen>
    with SingleTickerProviderStateMixin {
  static const int _pinLength = 4;

  // TODO: replace with your real stored/verified transaction PIN check.
  static const String _correctPin = '1234';

  String _enteredPin = '';
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
    if (_enteredPin.length >= _pinLength || _isVerifying) return;
    HapticFeedback.selectionClick();
    setState(() {
      _enteredPin += digit;
      _errorText = null;
    });
    if (_enteredPin.length == _pinLength) _verifyPin();
  }

  void _onBackspaceTap() {
    if (_enteredPin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _errorText = null;
    });
  }

  Future<void> _verifyPin() async {
    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    if (_enteredPin == _correctPin) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => TransferSuccessScreen(transfer: widget.transfer)),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    _shakeController.forward(from: 0);
    setState(() {
      _isVerifying = false;
      _errorText = 'Incorrect PIN. Try again.';
      _enteredPin = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final transfer = widget.transfer;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: 64, height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [AppColors.primaryBlue, AppColors.primaryBlueLight],
                ),
                boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.35), blurRadius: 22, spreadRadius: 2)],
              ),
              child: const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 28),
            ),

            const SizedBox(height: 28),

            const Text(
              'Authorize transaction',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _errorText ??
                    'Enter your PIN to send ${transfer.currency.symbol}${formatAmount(transfer.total)} to ${transfer.recipient.name}',
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
              child: PinDotIndicator(length: _pinLength, filledCount: _enteredPin.length, hasError: _errorText != null),
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
    );
  }
}
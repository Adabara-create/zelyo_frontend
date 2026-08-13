import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:zelyo_1/theme/app_colors.dart';
import 'ID_verification_screen.dart';

/// Email OTP verification screen.
///
/// Pass the email the code was sent to so the subtitle can show a masked
/// version of it (e.g. "jo***@gmail.com"), and wire [onVerified] to
/// whatever comes next in your flow (passcode setup, home, etc).
class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final VoidCallback? onVerified;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.onVerified,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  static const int _codeLength = 6;
  static const int _resendSeconds = 45;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  bool _isVerifying = false;
  String? _errorText;

  Timer? _resendTimer;
  int _secondsRemaining = _resendSeconds;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _controllers =
        List.generate(_codeLength, (_) => TextEditingController());
    _focusNodes = List.generate(_codeLength, (_) => FocusNode());

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

    _startResendTimer();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    _resendTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _secondsRemaining = _resendSeconds;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining -= 1);
      }
    });
  }

  String get _maskedEmail {
    final parts = widget.email.split('@');
    if (parts.length != 2 || parts[0].isEmpty) return widget.email;
    final name = parts[0];
    final visible = name.length <= 2 ? name : name.substring(0, 2);
    return '$visible${'*' * 3}@${parts[1]}';
  }

  String get _enteredCode =>
      _controllers.map((controller) => controller.text).join();

  void _onDigitChanged(int index, String value) {
    setState(() => _errorText = null);

    if (value.isNotEmpty) {
      if (index < _codeLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_enteredCode.length == _codeLength) {
          _onVerifyTap();
        }
      }
    }
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _onVerifyTap() async {
    final code = _enteredCode;
    if (code.length < _codeLength || _isVerifying) return;

    setState(() => _isVerifying = true);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const IdVerificationScreen(),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 900));
    const correctCode = '123456';

    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (code == correctCode) {
      widget.onVerified?.call();
    } else {
      HapticFeedback.mediumImpact();
      _shakeController.forward(from: 0);
      setState(() => _errorText = 'Incorrect code. Please try again.');
      for (final controller in _controllers) {
        controller.clear();
      }
      _focusNodes.first.requestFocus();
    }
  }

  void _onResendTap() {
    if (_secondsRemaining > 0) return;
    // TODO: trigger your real resend-code request.
    _startResendTimer();
    setState(() => _errorText = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surface,
        content: const Text(
          'A new code has been sent.',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Back button
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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    // ----- Logo -----
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
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
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mark_email_read_outlined,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ----- Headline -----
                    const Text(
                      'Verify your email',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMuted,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(
                            text: 'We sent a 6-digit code to ',
                          ),
                          TextSpan(
                            text: _maskedEmail,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // ----- OTP digit boxes -----
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: child,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          _codeLength,
                          (index) => _OtpDigitBox(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            hasError: _errorText != null,
                            onChanged: (value) => _onDigitChanged(index, value),
                            onBackspace: () => _onBackspace(index),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    if (_errorText != null)
                      Text(
                        _errorText!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.redAccent,
                          height: 1.4,
                        ),
                      ),

                    const SizedBox(height: 32),

                    // ----- Verify button -----
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed:
                            (_enteredCode.length == _codeLength && !_isVerifying)
                                ? _onVerifyTap
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          disabledBackgroundColor: AppColors.surface,
                          foregroundColor: Colors.white,
                          disabledForegroundColor: AppColors.textMuted,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isVerifying
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Verify',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ----- Resend code -----
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _secondsRemaining > 0
                              ? 'Resend code in 0:${_secondsRemaining.toString().padLeft(2, '0')}'
                              : "Didn't get a code? ",
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13.5,
                          ),
                        ),
                        if (_secondsRemaining == 0)
                          GestureDetector(
                            onTap: _onResendTap,
                            child: const Text(
                              'Resend',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ----- Change email -----
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Use a different email',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single OTP digit box: filled dark field, blue-outline on focus, and a
/// red outline when the parent screen has an active error (wrong code).
class _OtpDigitBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const _OtpDigitBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, {double width = 1.2}) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );

    return SizedBox(
      width: 48,
      height: 56,
      child: KeyboardListener(
        focusNode: FocusNode(skipTraversal: true),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            onBackspace();
          }
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          onChanged: onChanged,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          cursorColor: AppColors.primaryBlue,
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.zero,
            border: border(
                hasError ? Colors.redAccent : AppColors.outlineBorder),
            enabledBorder: border(
                hasError ? Colors.redAccent : AppColors.outlineBorder),
            focusedBorder: border(
              hasError ? Colors.redAccent : AppColors.primaryBlue,
              width: 1.8,
            ),
          ),
        ),
      ),
    );
  }
}
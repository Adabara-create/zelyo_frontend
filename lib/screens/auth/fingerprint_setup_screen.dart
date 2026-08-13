import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/screens/auth/welcome_back_screen.dart';

/// Shown once, right after a correct passcode entry, offering the user
/// the choice to enable fingerprint login for next time.
///
/// Requires the `local_auth` package:
///   dependencies:
///     local_auth: ^2.3.0
///
/// ...plus native setup (Face ID usage string in Info.plist for iOS,
/// USE_BIOMETRIC permission in AndroidManifest.xml for Android, and the
/// login Activity extending FlutterFragmentActivity on Android).
class FingerprintSetupScreen extends StatefulWidget {
  /// Called once the user has either enabled fingerprint login or chosen
  /// "Maybe later" — either way, this is your cue to continue into the
  /// rest of the app.
  final VoidCallback? onContinue;

  const FingerprintSetupScreen({super.key, this.onContinue});

  @override
  State<FingerprintSetupScreen> createState() =>
      _FingerprintSetupScreenState();
}

class _FingerprintSetupScreenState extends State<FingerprintSetupScreen>
    with SingleTickerProviderStateMixin {
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _isCheckingAvailability = true;
  bool _isBiometricAvailable = false;
  bool _isEnabling = false;
  String? _errorText;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      if (!mounted) return;
      setState(() {
        _isBiometricAvailable = canCheck && isSupported;
        _isCheckingAvailability = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isBiometricAvailable = false;
        _isCheckingAvailability = false;
      });
    }
  }

  Future<void> _onEnableTap() async {
    if (_isEnabling) return;
    setState(() {
      _isEnabling = true;
      _errorText = null;
    });

    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Confirm your fingerprint to enable quick login',
        biometricOnly: true,
      );
      if (!mounted) return;

      if (didAuthenticate) {
        // TODO: persist "fingerprint enabled" for this user (e.g. secure
        // storage / backend flag) so future launches skip straight to
        // the biometric prompt instead of showing this screen again.
        widget.onContinue?.call();
      } else {
        setState(() => _errorText = "Couldn't confirm fingerprint. Try again.");
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorText = "Couldn't confirm fingerprint. Try again.");
    } finally {
      if (mounted) setState(() => _isEnabling = false);
    }
  }

  void _onMaybeLaterTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WelcomeBackScreen(),
      ),
    );
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

          // A second, smaller orb bottom-right for a bit more depth/balance
          // now that this screen has more open space than the passcode one.
          Positioned(
            bottom: -100,
            right: -80,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBlue.withOpacity(0.5),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // ----- Pulsing fingerprint centerpiece -----
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) => Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 148,
                            height: 148,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryBlue.withOpacity(0.12),
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: 1 + (_pulseAnimation.value - 1) * 0.5,
                          child: Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryBlue.withOpacity(0.18),
                            ),
                          ),
                        ),
                        child!,
                      ],
                    ),
                    child: Container(
                      width: 88,
                      height: 88,
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
                            color: AppColors.primaryBlue.withOpacity(0.4),
                            blurRadius: 28,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.fingerprint,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ----- Headline -----
                  const Text(
                    'Enable fingerprint login',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    _isCheckingAvailability
                        ? 'Checking this device for fingerprint support...'
                        : _isBiometricAvailable
                            ? 'Skip typing your passcode next time — just use your fingerprint to log in faster and more securely.'
                            : 'No fingerprint sensor was found on this device, so this can be turned on later from a device that supports it.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                  ),

                  if (_errorText != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _errorText!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.redAccent,
                        height: 1.4,
                      ),
                    ),
                  ],

                  const Spacer(flex: 3),

                  // ----- Enable button -----
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (_isBiometricAvailable && !_isEnabling)
                          ? _onEnableTap
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
                      child: _isEnabling
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Enable fingerprint',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ----- Maybe later -----
                  SizedBox(
                    height: 56,
                    child: TextButton(
                      onPressed: _isEnabling ? null : _onMaybeLaterTap,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textMuted,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Maybe later',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
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
    );
  }
}
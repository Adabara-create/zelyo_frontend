import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'passcode_screen.dart';

/// The screen a returning user sees on app open (or after onboarding
/// finishes): a left-aligned "Welcome back" greeting, a wide card housing
/// a tap-to-scan fingerprint reader, and "Use passcode instead" as a
/// fallback.
///
/// Requires the `local_auth` package — see [PasscodeScreen] / the
/// fingerprint setup screen for the full native setup notes.
class WelcomeBackScreen extends StatefulWidget {
  /// Called once the user is authenticated, either via fingerprint or
  /// passcode. Wire this to navigate into the home shell.
  final VoidCallback? onAuthenticated;

  const WelcomeBackScreen({super.key, this.onAuthenticated});

  @override
  State<WelcomeBackScreen> createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends State<WelcomeBackScreen>
    with SingleTickerProviderStateMixin {
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _isAuthenticating = false;
  String? _statusText;

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

    // Offer the fingerprint prompt automatically on arrival — the user
    // can still tap the reader again if they dismiss or cancel it.
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String get _timeOfDayGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
      _statusText = null;
    });

    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Use your fingerprint to unlock Zelyo',
        biometricOnly: true,
      );
      if (!mounted) return;

      if (didAuthenticate) {
        widget.onAuthenticated?.call();
      } else {
        setState(() => _statusText = 'Tap the sensor to try again.');
      }
    } catch (_) {
      if (!mounted) return;
      setState(
          () => _statusText = "Couldn't read your fingerprint. Try again.");
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  void _onUsePasscodeTap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PasscodeScreen(
          onSuccess: () {
            Navigator.of(context).pop(); // close the passcode screen
            widget.onAuthenticated?.call();
          },
        ),
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

          // A second, quieter orb bottom-right for extra depth/balance.
          Positioned(
            bottom: -110,
            right: -90,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBlue.withOpacity(0.45),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // ----- Zelyo logo lockup -----
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
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
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Zelyo',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 3),

                  // ----- Left-aligned greeting + headline -----
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _timeOfDayGreeting,
                        style: const TextStyle(
                          color: AppColors.primaryBlueLight,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Use your fingerprint to unlock your account and pick up right where you left off.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMuted,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ----- Wide card housing the fingerprint reader -----
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.outlineBorder,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.08),
                          blurRadius: 28,
                          spreadRadius: 2,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // ----- Tap-to-scan fingerprint reader -----
                        GestureDetector(
                          onTap: _authenticate,
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedBuilder(
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
                                      color:
                                          AppColors.primaryBlue.withOpacity(0.12),
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
                                      color:
                                          AppColors.primaryBlue.withOpacity(0.18),
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
                              child: _isAuthenticating
                                  ? const Padding(
                                      padding: EdgeInsets.all(28),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.fingerprint,
                                      color: Colors.white,
                                      size: 42,
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          _statusText ?? 'Tap the sensor to unlock',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: _statusText != null
                                ? Colors.redAccent
                                : AppColors.textMuted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ----- Passcode fallback -----
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _onUsePasscodeTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: const BorderSide(
                          color: AppColors.primaryBlue,
                          width: 1.4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Use passcode instead',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // ----- Security reassurance footer -----
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.textMuted,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Secured with on-device biometric encryption',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

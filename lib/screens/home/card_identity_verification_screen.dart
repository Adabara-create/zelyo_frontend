import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/providers/card_identity_verification_provider.dart';

/// Selfie capture followed by an animated face-match scan.
///
/// Identity-verification state is managed by Riverpod through
/// [cardIdentityVerificationProvider].
///
/// The camera and animations remain inside this screen because they
/// are UI responsibilities.
///
/// Pops `true` once the verification succeeds.
class CardIdentityVerificationScreen extends ConsumerStatefulWidget {
  const CardIdentityVerificationScreen({
    super.key,
  });

  @override
  ConsumerState<CardIdentityVerificationScreen> createState() =>
      _CardIdentityVerificationScreenState();
}

class _CardIdentityVerificationScreenState
    extends ConsumerState<CardIdentityVerificationScreen>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();

  late final AnimationController _scanLineController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Start each time this screen is opened with a fresh verification flow.
    Future.microtask(() {
      if (!mounted) return;
      ref
          .read(cardIdentityVerificationProvider.notifier)
          .reset();
    });

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _captureSelfie() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );

      if (file == null) return;

      if (!mounted) return;

      ref
          .read(cardIdentityVerificationProvider.notifier)
          .setSelfie(file.path);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Couldn't open the camera. "
            'Check permissions and try again.',
          ),
        ),
      );
    }
  }

  Future<void> _onContinueTap() async {
    final verificationNotifier =
        ref.read(cardIdentityVerificationProvider.notifier);

    final succeeded =
        await verificationNotifier.startFaceScan();

    if (!mounted || !succeeded) return;

    // Give the success state a moment to display.
    await Future.delayed(
      const Duration(milliseconds: 900),
    );

    if (!mounted) return;

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final verificationState =
        ref.watch(cardIdentityVerificationProvider);

    final isSelfieStep =
        verificationState.step ==
            CardIdentityVerificationStep.selfie;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -90,
            left: -90,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: 70,
                sigmaY: 70,
              ),
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
                  padding: const EdgeInsets.fromLTRB(
                    12,
                    8,
                    12,
                    0,
                  ),
                  child: Row(
                    children: [
                      if (isSelfieStep)
                        IconButton(
                          onPressed: () =>
                              Navigator.of(context)
                                  .maybePop(false),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 28,
                    ),
                    child: isSelfieStep
                        ? _buildSelfieStep(
                            verificationState,
                          )
                        : _buildScanStep(
                            verificationState,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelfieStep(
    CardIdentityVerificationState verificationState,
  ) {
    final selfiePath =
        verificationState.selfiePath;

    final hasSelfie = selfiePath != null;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),

        Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
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
                color: AppColors.primaryBlue
                    .withOpacity(0.35),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.face_outlined,
            color: Colors.white,
            size: 32,
          ),
        ),

        const SizedBox(height: 28),

        const Text(
          'Verify it\'s you',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'For your security, take a quick selfie '
          'before we open your virtual card.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 32),

        Center(
          child: SizedBox(
            width: 220,
            height: 220,
            child: ClipOval(
              child: hasSelfie
                  ? Image.file(
                      File(selfiePath),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppColors.surface,
                      child: const Icon(
                        Icons.person_outline,
                        color: AppColors.textMuted,
                        size: 90,
                      ),
                    ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _captureSelfie,
            icon: Icon(
              hasSelfie
                  ? Icons.refresh
                  : Icons.camera_alt_outlined,
              size: 19,
            ),
            label: Text(
              hasSelfie
                  ? 'Retake photo'
                  : 'Take selfie',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasSelfie
                  ? AppColors.surface
                  : AppColors.primaryBlue,
              foregroundColor: hasSelfie
                  ? AppColors.textPrimary
                  : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(14),
                side: hasSelfie
                    ? const BorderSide(
                        color:
                            AppColors.outlineBorder,
                      )
                    : BorderSide.none,
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed:
                hasSelfie ? _onContinueTap : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  AppColors.primaryBlue,
              disabledBackgroundColor:
                  AppColors.surface,
              foregroundColor: Colors.white,
              disabledForegroundColor:
                  AppColors.textMuted,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildScanStep(
    CardIdentityVerificationState verificationState,
  ) {
    final scanSucceeded =
        verificationState.scanSucceeded;

    final scanStatus =
        verificationState.scanStatus;

    final selfiePath =
        verificationState.selfiePath;

    return Column(
      children: [
        const SizedBox(height: 24),

        Text(
          scanSucceeded
              ? 'All set'
              : 'Scanning your face',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          scanStatus,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: scanSucceeded
                ? AppColors.primaryBlueLight
                : AppColors.textMuted,
          ),
        ),

        const SizedBox(height: 48),

        SizedBox(
          width: 240,
          height: 240,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _pulseController,
              _scanLineController,
            ]),
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  if (!scanSucceeded)
                    Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryBlue
                              .withOpacity(0.10),
                        ),
                      ),
                    ),

                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: scanSucceeded
                            ? AppColors
                                .primaryBlueLight
                            : AppColors
                                .outlineBorder,
                        width: 2,
                      ),
                    ),
                  ),

                  ClipOval(
                    child: Container(
                      width: 190,
                      height: 190,
                      color: AppColors.surface,
                      child: selfiePath != null
                          ? Image.file(
                              File(selfiePath),
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.person,
                              color:
                                  AppColors.textMuted,
                              size: 90,
                            ),
                    ),
                  ),

                  if (!scanSucceeded)
                    ClipOval(
                      child: SizedBox(
                        width: 190,
                        height: 190,
                        child: Align(
                          alignment: Alignment(
                            0,
                            -1 +
                                2 *
                                    _scanLineController
                                        .value,
                          ),
                          child: Container(
                            height: 3,
                            decoration:
                                BoxDecoration(
                              gradient:
                                  LinearGradient(
                                colors: [
                                  AppColors.primaryBlue
                                      .withOpacity(0),
                                  AppColors
                                      .primaryBlueLight,
                                  AppColors.primaryBlue
                                      .withOpacity(0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (scanSucceeded)
                    Container(
                      width: 200,
                      height: 200,
                      decoration:
                          const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x992563FF),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}
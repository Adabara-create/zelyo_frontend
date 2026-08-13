import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zelyo_1/theme/app_colors.dart';

/// Selfie capture followed by an animated face-match scan — the
/// identity check required before opening a new virtual card. Pops
/// `true` once the scan "succeeds," `false`/`null` otherwise.
///
/// Like the onboarding ID verification screen, the face-match step
/// here is a UI simulation, not real liveness detection — see the TODO
/// on [_runFaceScan] for what a production integration needs.
class CardIdentityVerificationScreen extends StatefulWidget {
  const CardIdentityVerificationScreen({super.key});

  @override
  State<CardIdentityVerificationScreen> createState() => _CardIdentityVerificationScreenState();
}

enum _Step { selfie, scanning }

class _CardIdentityVerificationScreenState extends State<CardIdentityVerificationScreen>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();

  _Step _step = _Step.selfie;
  XFile? _selfieImage;

  bool _scanSucceeded = false;
  String _scanStatus = 'Position your face in the frame';

  late final AnimationController _scanLineController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _captureSelfie() async {
    try {
      final file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85, preferredCameraDevice: CameraDevice.front);
      if (file == null) return;
      setState(() => _selfieImage = file);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't open the camera. Check permissions and try again.")),
      );
    }
  }

  void _onContinueTap() {
    if (_selfieImage == null) return;
    setState(() => _step = _Step.scanning);
    _runFaceScan();
  }

  void _runFaceScan() {
    setState(() {
      _scanSucceeded = false;
      _scanStatus = 'Position your face in the frame';
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _scanStatus = 'Scanning your face...');
    });

    // TODO: replace this simulated delay with a real call to a
    // liveness-detection / face-matching provider, comparing the live
    // capture against the selfie and (ideally) the user's stored KYC
    // photo from onboarding.
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      setState(() {
        _scanSucceeded = true;
        _scanStatus = 'Identity verified';
      });
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        Navigator.of(context).pop(true);
      });
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
                      if (_step == _Step.selfie)
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(false),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: _step == _Step.selfie ? _buildSelfieStep() : _buildScanStep(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelfieStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
              colors: [AppColors.primaryBlue, AppColors.primaryBlueLight],
            ),
            boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.35), blurRadius: 24, spreadRadius: 2)],
          ),
          child: const Icon(Icons.face_outlined, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 28),
        const Text(
          'Verify it\'s you',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        const Text(
          'For your security, take a quick selfie before we open your virtual card.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 32),
        Center(
          child: SizedBox(
            width: 220,
            height: 220,
            child: ClipOval(
              child: _selfieImage != null
                  ? Image.file(File(_selfieImage!.path), fit: BoxFit.cover)
                  : Container(
                      color: AppColors.surface,
                      child: const Icon(Icons.person_outline, color: AppColors.textMuted, size: 90),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _captureSelfie,
            icon: Icon(_selfieImage != null ? Icons.refresh : Icons.camera_alt_outlined, size: 19),
            label: Text(_selfieImage != null ? 'Retake photo' : 'Take selfie'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _selfieImage != null ? AppColors.surface : AppColors.primaryBlue,
              foregroundColor: _selfieImage != null ? AppColors.textPrimary : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: _selfieImage != null ? const BorderSide(color: AppColors.outlineBorder) : BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _selfieImage != null ? _onContinueTap : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              disabledBackgroundColor: AppColors.surface,
              foregroundColor: Colors.white,
              disabledForegroundColor: AppColors.textMuted,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildScanStep() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          _scanSucceeded ? 'All set' : 'Scanning your face',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Text(
          _scanStatus,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: _scanSucceeded ? AppColors.primaryBlueLight : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: 240,
          height: 240,
          child: AnimatedBuilder(
            animation: Listenable.merge([_pulseController, _scanLineController]),
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  if (!_scanSucceeded)
                    Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryBlue.withOpacity(0.10)),
                      ),
                    ),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _scanSucceeded ? AppColors.primaryBlueLight : AppColors.outlineBorder, width: 2),
                    ),
                  ),
                  ClipOval(
                    child: Container(
                      width: 190,
                      height: 190,
                      color: AppColors.surface,
                      child: _selfieImage != null
                          ? Image.file(File(_selfieImage!.path), fit: BoxFit.cover)
                          : const Icon(Icons.person, color: AppColors.textMuted, size: 90),
                    ),
                  ),
                  if (!_scanSucceeded)
                    ClipOval(
                      child: SizedBox(
                        width: 190,
                        height: 190,
                        child: Align(
                          alignment: Alignment(0, -1 + 2 * _scanLineController.value),
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primaryBlue.withOpacity(0), AppColors.primaryBlueLight, AppColors.primaryBlue.withOpacity(0)],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_scanSucceeded)
                    Container(
                      width: 200,
                      height: 200,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x992563FF)),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 64),
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
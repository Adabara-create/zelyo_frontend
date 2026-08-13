import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'create_passcode_screen.dart';

// Note there is an age restriction on this screen. >17
///
/// The face-match step is a UI simulation (see the TODO on
/// [_runFaceMatch]) — wire it up to a real liveness / face-matching
/// provider (AWS Rekognition, ML Kit, Onfido, etc) before shipping.
enum _VerificationStep { intro, idCapture, dateOfBirth, selfieCapture, faceScan }

class IdVerificationScreen extends StatefulWidget {
  const IdVerificationScreen({super.key});

  @override
  State<IdVerificationScreen> createState() => _IdVerificationScreenState();
}

class _IdVerificationScreenState extends State<IdVerificationScreen>
    with TickerProviderStateMixin {
  // Anyone 16 or younger is blocked from continuing.
  static const int _minimumAge = 17;

  static const List<_VerificationStep> _progressSteps = [
    _VerificationStep.idCapture,
    _VerificationStep.dateOfBirth,
    _VerificationStep.selfieCapture,
    _VerificationStep.faceScan,
  ];

  final ImagePicker _picker = ImagePicker();

  _VerificationStep _step = _VerificationStep.intro;
  XFile? _idImage;
  XFile? _selfieImage;
  DateTime? _dateOfBirth;
  bool _isUnderage = false;

  bool _isScanning = false;
  bool _scanSucceeded = false;
  String _scanStatus = 'Position your face in the frame';

  late final AnimationController _scanLineController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _goToStep(_VerificationStep step) => setState(() => _step = step);

  Future<void> _capturePhoto({required bool isIdCard}) async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice:
            isIdCard ? CameraDevice.rear : CameraDevice.front,
      );
      if (file == null) return;
      setState(() {
        if (isIdCard) {
          _idImage = file;
        } else {
          _selfieImage = file;
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Couldn't open the camera. Check permissions and try again."),
        ),
      );
    }
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primaryBlue,
            onPrimary: Colors.white,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
          dialogBackgroundColor: AppColors.background,
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() => _dateOfBirth = picked);
  }

  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  void _onDateOfBirthContinue() {
    if (_dateOfBirth == null) return;
    if (_calculateAge(_dateOfBirth!) < _minimumAge) {
      setState(() => _isUnderage = true);
      return;
    }
    _goToStep(_VerificationStep.selfieCapture);
  }

  void _onSelfieContinue() {
    _goToStep(_VerificationStep.faceScan);
    _runFaceMatch();
  }

  void _runFaceMatch() {
    setState(() {
      _isScanning = true;
      _scanSucceeded = false;
      _scanStatus = 'Position your face in the frame';
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted || !_isScanning) return;
      setState(() => _scanStatus = 'Scanning your face...');
    });

    Future.delayed(const Duration(milliseconds: 1900), () {
      if (!mounted || !_isScanning) return;
      setState(() => _scanStatus = 'Matching with your ID and selfie...');
    });

    // TODO: replace this simulated delay with a real call to your
    // liveness-detection / face-matching provider, comparing the live
    // capture against _selfieImage and the face on _idImage.
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _scanSucceeded = true;
        _scanStatus = 'Identity verified';
      });

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const CreatePasscodeScreen(),
          ),
        );
      });
    });
  }

  void _onBackTap() {
    switch (_step) {
      case _VerificationStep.intro:
        Navigator.of(context).maybePop();
        break;
      case _VerificationStep.idCapture:
        _goToStep(_VerificationStep.intro);
        break;
      case _VerificationStep.dateOfBirth:
        _goToStep(_VerificationStep.idCapture);
        break;
      case _VerificationStep.selfieCapture:
        _goToStep(_VerificationStep.dateOfBirth);
        break;
      case _VerificationStep.faceScan:
        break; // no back navigation while/after scanning
    }
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
            child: _isUnderage ? _buildUnderageView() : _buildStepScaffold(),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Shared chrome: back button + progress bar + the step's own content.
  // ---------------------------------------------------------------------
  Widget _buildStepScaffold() {
    final showBack = _step != _VerificationStep.faceScan;
    final showProgress = _progressSteps.contains(_step);
    final progressIndex = showProgress ? _progressSteps.indexOf(_step) : -1;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 24, 0),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: showBack
                    ? IconButton(
                        onPressed: _onBackTap,
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      )
                    : null,
              ),
              if (showProgress)
                Expanded(
                  child: Row(
                    children: List.generate(_progressSteps.length, (index) {
                      final isActive = index <= progressIndex;
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                              right: index == _progressSteps.length - 1 ? 0 : 6),
                          height: 4,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primaryBlue
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),
                  ),
                )
              else
                const Spacer(),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: _buildStepContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case _VerificationStep.intro:
        return _buildIntroStep();
      case _VerificationStep.idCapture:
        return _buildIdCaptureStep();
      case _VerificationStep.dateOfBirth:
        return _buildDateOfBirthStep();
      case _VerificationStep.selfieCapture:
        return _buildSelfieCaptureStep();
      case _VerificationStep.faceScan:
        return _buildFaceScanStep();
    }
  }

  Widget _buildHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryBlue, AppColors.primaryBlueLight],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.35),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 28),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Step: intro
  // ---------------------------------------------------------------------
  Widget _buildIntroStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(
          icon: Icons.verified_user_outlined,
          title: 'Verify your identity',
          subtitle:
              "This keeps your account secure and only takes about a minute.",
        ),
        _buildChecklistItem(
          icon: Icons.badge_outlined,
          title: 'National ID card',
          subtitle: 'A clear photo of the front of your ID',
        ),
        const SizedBox(height: 14),
        _buildChecklistItem(
          icon: Icons.face_outlined,
          title: 'A selfie',
          subtitle: 'A well-lit photo of your face',
        ),
        const SizedBox(height: 14),
        _buildChecklistItem(
          icon: Icons.center_focus_strong_outlined,
          title: 'Face scan',
          subtitle: 'To confirm it really is you',
        ),
        const SizedBox(height: 40),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () => _goToStep(_VerificationStep.idCapture),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'Get started',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildChecklistItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineBorder, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryBlueLight, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Step: ID card capture
  // ---------------------------------------------------------------------
  Widget _buildIdCaptureStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(
          icon: Icons.badge_outlined,
          title: 'Scan your ID card',
          subtitle:
              'Place your National ID card on a flat surface and make sure all four corners are visible.',
        ),
        _buildCapturePreview(
          image: _idImage,
          aspectRatio: 1.58,
          placeholderIcon: Icons.credit_card,
          placeholderLabel: 'ID card photo',
        ),
        const SizedBox(height: 24),
        _buildCaptureButtons(isIdCard: true, hasImage: _idImage != null),
        const SizedBox(height: 16),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _idImage != null
                ? () => _goToStep(_VerificationStep.dateOfBirth)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              disabledBackgroundColor: AppColors.surface,
              foregroundColor: Colors.white,
              disabledForegroundColor: AppColors.textMuted,
              elevation: 0,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Step: date of birth / age gate
  // ---------------------------------------------------------------------
  Widget _buildDateOfBirthStep() {
    final formatted = _dateOfBirth == null
        ? null
        : '${_dateOfBirth!.day.toString().padLeft(2, '0')}/${_dateOfBirth!.month.toString().padLeft(2, '0')}/${_dateOfBirth!.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(
          icon: Icons.cake_outlined,
          title: 'Confirm your date of birth',
          subtitle:
              'This should match the date of birth on your National ID card. You must be at least $_minimumAge to use Zelyo.',
        ),
        InkWell(
          onTap: _pickDateOfBirth,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _dateOfBirth != null
                    ? AppColors.primaryBlue
                    : AppColors.outlineBorder,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    color: AppColors.textMuted, size: 20),
                const SizedBox(width: 12),
                Text(
                  formatted ?? 'Select date of birth',
                  style: TextStyle(
                    color: _dateOfBirth != null
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                    fontSize: 15,
                    fontWeight:
                        _dateOfBirth != null ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _dateOfBirth != null ? _onDateOfBirthContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              disabledBackgroundColor: AppColors.surface,
              foregroundColor: Colors.white,
              disabledForegroundColor: AppColors.textMuted,
              elevation: 0,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Step: selfie capture
  // ---------------------------------------------------------------------
  Widget _buildSelfieCaptureStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(
          icon: Icons.face_outlined,
          title: 'Take a selfie',
          subtitle:
              'Find good lighting and look straight at the camera with your face fully visible.',
        ),
        Center(
          child: _buildCapturePreview(
            image: _selfieImage,
            aspectRatio: 1,
            isCircular: true,
            placeholderIcon: Icons.person_outline,
            placeholderLabel: 'Selfie photo',
            size: 220,
          ),
        ),
        const SizedBox(height: 24),
        _buildCaptureButtons(isIdCard: false, hasImage: _selfieImage != null),
        const SizedBox(height: 16),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _selfieImage != null ? _onSelfieContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              disabledBackgroundColor: AppColors.surface,
              foregroundColor: Colors.white,
              disabledForegroundColor: AppColors.textMuted,
              elevation: 0,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCapturePreview({
    required XFile? image,
    required double aspectRatio,
    required IconData placeholderIcon,
    required String placeholderLabel,
    bool isCircular = false,
    double? size,
  }) {
    final borderRadius = isCircular
        ? BorderRadius.circular(999)
        : BorderRadius.circular(20);

    Widget content;
    if (image != null) {
      content = ClipRRect(
        borderRadius: borderRadius,
        child: Image.file(
          File(image.path),
          fit: BoxFit.cover,
        ),
      );
    } else {
      content = DottedBorderPlaceholder(
        borderRadius: borderRadius,
        icon: placeholderIcon,
        label: placeholderLabel,
      );
    }

    if (isCircular) {
      return SizedBox(width: size, height: size, child: content);
    }

    return AspectRatio(aspectRatio: aspectRatio, child: content);
  }

  Widget _buildCaptureButtons({required bool isIdCard, required bool hasImage}) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _capturePhoto(isIdCard: isIdCard),
              icon: Icon(hasImage ? Icons.refresh : Icons.camera_alt_outlined,
                  size: 19),
              label: Text(hasImage ? 'Retake photo' : 'Take photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    hasImage ? AppColors.surface : AppColors.primaryBlue,
                foregroundColor:
                    hasImage ? AppColors.textPrimary : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: hasImage
                      ? const BorderSide(color: AppColors.outlineBorder)
                      : BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Step: face scan
  // ---------------------------------------------------------------------
  Widget _buildFaceScanStep() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          _scanSucceeded ? 'All set' : 'Scanning your face',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _scanStatus,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: _scanSucceeded
                ? AppColors.primaryBlueLight
                : AppColors.textMuted,
            height: 1.4,
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
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryBlue.withOpacity(0.10),
                        ),
                      ),
                    ),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _scanSucceeded
                            ? AppColors.primaryBlueLight
                            : AppColors.outlineBorder,
                        width: 2,
                      ),
                    ),
                  ),
                  ClipOval(
                    child: Container(
                      width: 190,
                      height: 190,
                      color: AppColors.surface,
                      child: _selfieImage != null
                          ? Image.file(File(_selfieImage!.path), fit: BoxFit.cover)
                          : const Icon(Icons.person,
                              color: AppColors.textMuted, size: 90),
                    ),
                  ),
                  if (_isScanning)
                    ClipOval(
                      child: SizedBox(
                        width: 190,
                        height: 190,
                        child: Align(
                          alignment: Alignment(
                              0, -1 + 2 * _scanLineController.value),
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryBlue.withOpacity(0),
                                  AppColors.primaryBlueLight,
                                  AppColors.primaryBlue.withOpacity(0),
                                ],
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
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x991657FF),
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 64),
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

  // ---------------------------------------------------------------------
  // Underage block
  // ---------------------------------------------------------------------
  Widget _buildUnderageView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.redAccent.withOpacity(0.12),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 44,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            "You don't meet the age requirement",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Zelyo requires account holders to be at least $_minimumAge years old. Based on the date of birth provided, we cannot continue with verification right now.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _isUnderage = false;
                  _dateOfBirth = null;
                });
                _goToStep(_VerificationStep.dateOfBirth);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(
                    color: AppColors.outlineBorder, width: 1.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Re-enter date of birth',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: TextButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text(
                'Exit',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A dashed-border placeholder box shown before a photo has been captured.
class DottedBorderPlaceholder extends StatelessWidget {
  final BorderRadius borderRadius;
  final IconData icon;
  final String label;

  const DottedBorderPlaceholder({
    super.key,
    required this.borderRadius,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.outlineBorder,
          borderRadius: borderRadius,
        ),
        child: Container(
          color: AppColors.surface,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.textMuted, size: 34),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final BorderRadius borderRadius;

  _DashedBorderPainter({required this.color, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);
    final path = Path()..addRRect(rrect);

    final dashPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    const dashWidth = 6.0;
    const dashSpace = 5.0;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          dashPaint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => false;
}
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/widgets/pin_dot_indicator.dart';
import 'package:zelyo_1/widgets/pin_keypad.dart';

/// A self-contained change-PIN flow:
/// verify current PIN → create new PIN → confirm new PIN → success.
///
/// Riverpod owns the PIN-flow state. UI/animations/dialogs remain local
/// to the screen.
class ChangeTransactionPinState {
  final _Stage stage;
  final String newPin;
  final String currentEntry;
  final String? errorText;
  final bool isVerifying;

  const ChangeTransactionPinState({
    this.stage = _Stage.verify,
    this.newPin = '',
    this.currentEntry = '',
    this.errorText,
    this.isVerifying = false,
  });

  ChangeTransactionPinState copyWith({
    _Stage? stage,
    String? newPin,
    String? currentEntry,
    String? errorText,
    bool clearError = false,
    bool? isVerifying,
  }) {
    return ChangeTransactionPinState(
      stage: stage ?? this.stage,
      newPin: newPin ?? this.newPin,
      currentEntry: currentEntry ?? this.currentEntry,
      errorText: clearError ? null : (errorText ?? this.errorText),
      isVerifying: isVerifying ?? this.isVerifying,
    );
  }
}

class ChangeTransactionPinNotifier
    extends Notifier<ChangeTransactionPinState> {
  static const int pinLength = 4;

  // TODO: replace with the real secure PIN verification.
  static const String correctCurrentPin = '1234';

  @override
  ChangeTransactionPinState build() {
    return const ChangeTransactionPinState();
  }

  void addDigit(String digit) {
    if (state.currentEntry.length >= pinLength ||
        state.isVerifying) {
      return;
    }

    state = state.copyWith(
      currentEntry: state.currentEntry + digit,
      clearError: true,
    );
  }

  void removeDigit() {
    if (state.currentEntry.isEmpty) return;

    state = state.copyWith(
      currentEntry: state.currentEntry.substring(
        0,
        state.currentEntry.length - 1,
      ),
      clearError: true,
    );
  }

  Future<bool> verifyCurrentPin() async {
    state = state.copyWith(isVerifying: true);

    await Future.delayed(
      const Duration(milliseconds: 400),
    );

    if (state.currentEntry == correctCurrentPin) {
      state = state.copyWith(
        stage: _Stage.create,
        currentEntry: '',
        isVerifying: false,
        clearError: true,
      );
      return true;
    }

    state = state.copyWith(
      currentEntry: '',
      errorText: 'Incorrect PIN. Try again.',
      isVerifying: false,
    );

    return false;
  }

  void moveToConfirm() {
    state = state.copyWith(
      stage: _Stage.confirm,
      newPin: state.currentEntry,
      currentEntry: '',
      clearError: true,
    );
  }

  Future<bool> verifyNewPinMatch() async {
    await Future.delayed(
      const Duration(milliseconds: 120),
    );

    if (state.currentEntry == state.newPin) {
      // TODO: persist the new PIN securely through your backend/storage.
      return true;
    }

    state = state.copyWith(
      currentEntry: '',
      errorText: "PINs didn't match. Try again.",
    );

    return false;
  }

  void goBack() {
    if (state.stage == _Stage.confirm) {
      state = state.copyWith(
        stage: _Stage.create,
        newPin: '',
        currentEntry: '',
        clearError: true,
      );
    } else if (state.stage == _Stage.create) {
      state = state.copyWith(
        stage: _Stage.verify,
        currentEntry: '',
        clearError: true,
      );
    }
  }

  void reset() {
    state = const ChangeTransactionPinState();
  }
}

final changeTransactionPinProvider = NotifierProvider<
    ChangeTransactionPinNotifier,
    ChangeTransactionPinState>(
  ChangeTransactionPinNotifier.new,
);

enum _Stage {
  verify,
  create,
  confirm,
}

class ChangeTransactionPinScreen extends ConsumerStatefulWidget {
  const ChangeTransactionPinScreen({super.key});

  @override
  ConsumerState<ChangeTransactionPinScreen> createState() =>
      _ChangeTransactionPinScreenState();
}

class _ChangeTransactionPinScreenState
    extends ConsumerState<ChangeTransactionPinScreen>
    with SingleTickerProviderStateMixin {
  static const int _pinLength = 4;

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
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -10.0),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -10.0, end: 10.0),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 10.0, end: -6.0),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -6.0, end: 0.0),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onDigitTap(String digit) {
    final state = ref.read(changeTransactionPinProvider);
    final notifier =
        ref.read(changeTransactionPinProvider.notifier);

    if (state.currentEntry.length >= _pinLength ||
        state.isVerifying) {
      return;
    }

    HapticFeedback.selectionClick();
    notifier.addDigit(digit);

    if (state.currentEntry.length + 1 != _pinLength) {
      return;
    }

    switch (state.stage) {
      case _Stage.verify:
        _verifyCurrentPin();
        break;

      case _Stage.create:
        Future.delayed(
          const Duration(milliseconds: 150),
          () {
            if (!mounted) return;
            notifier.moveToConfirm();
          },
        );
        break;

      case _Stage.confirm:
        _verifyNewPinMatch();
        break;
    }
  }

  void _onBackspaceTap() {
    final state = ref.read(changeTransactionPinProvider);

    if (state.currentEntry.isEmpty) return;

    HapticFeedback.selectionClick();

    ref
        .read(changeTransactionPinProvider.notifier)
        .removeDigit();
  }

  Future<void> _verifyCurrentPin() async {
    final success = await ref
        .read(changeTransactionPinProvider.notifier)
        .verifyCurrentPin();

    if (!mounted) return;

    if (!success) {
      HapticFeedback.mediumImpact();
      _shakeController.forward(from: 0);
    }
  }

  Future<void> _verifyNewPinMatch() async {
    final success = await ref
        .read(changeTransactionPinProvider.notifier)
        .verifyNewPinMatch();

    if (!mounted) return;

    if (success) {
      await _showSuccessDialog();

      if (mounted) {
        Navigator.of(context).pop(true);
      }
      return;
    }

    HapticFeedback.mediumImpact();
    _shakeController.forward(from: 0);
  }

  Future<void> _showSuccessDialog() {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding:
              const EdgeInsets.fromLTRB(28, 32, 28, 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.outlineBorder,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      AppColors.success.withOpacity(0.15),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.success,
                  size: 38,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'PIN updated',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your transaction PIN has been changed successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onBackTap() {
    final state =
        ref.read(changeTransactionPinProvider);
    final notifier =
        ref.read(changeTransactionPinProvider.notifier);

    if (state.stage == _Stage.verify) {
      Navigator.of(context).maybePop(false);
      return;
    }

    notifier.goBack();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(changeTransactionPinProvider);

    final title = switch (state.stage) {
      _Stage.verify => 'Verify current PIN',
      _Stage.create => 'Create new PIN',
      _Stage.confirm => 'Confirm new PIN',
    };

    final subtitle = switch (state.stage) {
      _Stage.verify =>
        'Enter your current 4-digit transaction PIN',
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
                  padding:
                      const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _onBackTap,
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
                        color: AppColors.primaryBlue
                            .withOpacity(0.35),
                        blurRadius: 22,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    state.stage == _Stage.verify
                        ? Icons.lock_outline_rounded
                        : Icons.password_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36),
                  child: Text(
                    state.errorText ?? subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: state.errorText != null
                          ? Colors.redAccent
                          : AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) =>
                      Transform.translate(
                    offset: Offset(
                      _shakeAnimation.value,
                      0,
                    ),
                    child: child,
                  ),
                  child: PinDotIndicator(
                    length: _pinLength,
                    filledCount:
                        state.currentEntry.length,
                    hasError:
                        state.errorText != null,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36),
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
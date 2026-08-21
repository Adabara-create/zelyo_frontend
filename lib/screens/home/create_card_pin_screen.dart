import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/widgets/pin_dot_indicator.dart';
import 'package:zelyo_1/widgets/pin_keypad.dart';
import 'package:zelyo_1/providers/create_card_pin_provider.dart';

/// Sets up the card-specific PIN — deliberately a single screen with an
/// internal create → confirm flow, rather than two separate screens
/// like the app's onboarding passcode setup. This PIN is stored and
/// checked completely separately from the mobile transaction PIN used
/// in [VerifyTransactionPinScreen] — it only ever applies to card
/// operations (e.g. a POS/online purchase asking for a card PIN).
class CreateCardPinScreen extends ConsumerStatefulWidget {
  const CreateCardPinScreen({super.key});

  @override
  ConsumerState<CreateCardPinScreen> createState() =>
      _CreateCardPinScreenState();
}

class _CreateCardPinScreenState extends ConsumerState<CreateCardPinScreen>
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

    // Start this screen with a fresh PIN flow.
    Future.microtask(() {
      if (!mounted) return;

      ref
          .read(createCardPinProvider.notifier)
          .reset();
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onDigitTap(String digit) {
    final pinState = ref.read(createCardPinProvider);

    if (pinState.currentEntry.length >= _pinLength) {
      return;
    }

    HapticFeedback.selectionClick();

    final notifier =
        ref.read(createCardPinProvider.notifier);

    notifier.addDigit(digit);

    final updatedState =
        ref.read(createCardPinProvider);

    if (updatedState.currentEntry.length != _pinLength) {
      return;
    }

    if (updatedState.stage == CreateCardPinStage.create) {
      Future.delayed(
        const Duration(milliseconds: 150),
        () {
          if (!mounted) return;

          ref
              .read(createCardPinProvider.notifier)
              .moveToConfirm();
        },
      );
    } else {
      _verifyMatch();
    }
  }

  void _onBackspaceTap() {
    final pinState = ref.read(createCardPinProvider);

    if (pinState.currentEntry.isEmpty) {
      return;
    }

    HapticFeedback.selectionClick();

    ref
        .read(createCardPinProvider.notifier)
        .removeDigit();
  }

  Future<void> _verifyMatch() async {
    await Future.delayed(
      const Duration(milliseconds: 120),
    );

    if (!mounted) return;

    final matched = ref
        .read(createCardPinProvider.notifier)
        .verifyMatch();

    if (matched) {
      // TODO: persist the card PIN securely (hashed, secure storage /
      // backend) here — separately from the mobile transaction PIN.
      Navigator.of(context).pop(true);
      return;
    }

    HapticFeedback.mediumImpact();
    _shakeController.forward(from: 0);
  }

  void _onBackTap() {
    final pinState = ref.read(createCardPinProvider);

    if (pinState.stage == CreateCardPinStage.confirm) {
      ref
          .read(createCardPinProvider.notifier)
          .backToCreate();
    } else {
      Navigator.of(context).maybePop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinState =
        ref.watch(createCardPinProvider);

    final isConfirmStage =
        pinState.stage == CreateCardPinStage.confirm;

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
                    isConfirmStage
                        ? Icons.verified_user_outlined
                        : Icons.credit_card_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  isConfirmStage
                      ? 'Confirm card PIN'
                      : 'Create card PIN',
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
                      const EdgeInsets.symmetric(
                    horizontal: 32,
                  ),
                  child: Text(
                    pinState.errorText ??
                        (isConfirmStage
                            ? 'Re-enter the 4-digit PIN to confirm'
                            : "This is different from your transaction PIN — it's used only for this card."),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: pinState.errorText != null
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
                        pinState.currentEntry.length,
                    hasError:
                        pinState.errorText != null,
                  ),
                ),

                const Spacer(),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 36,
                  ),
                  child: PinKeypad(
                    onDigitTap: _onDigitTap,
                    onBackspaceTap:
                        _onBackspaceTap,
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
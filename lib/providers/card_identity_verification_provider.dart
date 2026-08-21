import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current stage of the card identity verification flow.
enum CardIdentityVerificationStep {
  selfie,
  scanning,
}

/// State for the card identity verification flow.
///
/// Riverpod owns the actual verification state, while the screen
/// remains responsible for camera access, animations, and navigation.
class CardIdentityVerificationState {
  final CardIdentityVerificationStep step;
  final String? selfiePath;
  final bool scanSucceeded;
  final String scanStatus;

  const CardIdentityVerificationState({
    required this.step,
    required this.selfiePath,
    required this.scanSucceeded,
    required this.scanStatus,
  });

  const CardIdentityVerificationState.initial()
      : step = CardIdentityVerificationStep.selfie,
        selfiePath = null,
        scanSucceeded = false,
        scanStatus = 'Position your face in the frame';

  CardIdentityVerificationState copyWith({
    CardIdentityVerificationStep? step,
    String? selfiePath,
    bool clearSelfiePath = false,
    bool? scanSucceeded,
    String? scanStatus,
  }) {
    return CardIdentityVerificationState(
      step: step ?? this.step,
      selfiePath: clearSelfiePath
          ? null
          : selfiePath ?? this.selfiePath,
      scanSucceeded: scanSucceeded ?? this.scanSucceeded,
      scanStatus: scanStatus ?? this.scanStatus,
    );
  }
}

/// Handles the state of the identity-verification flow.
class CardIdentityVerificationNotifier
    extends Notifier<CardIdentityVerificationState> {
  @override
  CardIdentityVerificationState build() {
    return const CardIdentityVerificationState.initial();
  }

  /// Stores the path of the selfie captured by the camera.
  void setSelfie(String path) {
    state = state.copyWith(
      selfiePath: path,
      step: CardIdentityVerificationStep.selfie,
      scanSucceeded: false,
      scanStatus: 'Position your face in the frame',
    );
  }

  /// Starts the face verification process.
  ///
  /// This is currently a simulation. Replace the delays with the
  /// actual liveness/face-matching API when the backend is ready.
  Future<bool> startFaceScan() async {
    if (state.selfiePath == null) {
      return false;
    }

    state = state.copyWith(
      step: CardIdentityVerificationStep.scanning,
      scanSucceeded: false,
      scanStatus: 'Position your face in the frame',
    );

    await Future.delayed(
      const Duration(milliseconds: 900),
    );

    state = state.copyWith(
      scanStatus: 'Scanning your face...',
    );

    await Future.delayed(
      const Duration(milliseconds: 1700),
    );

    state = state.copyWith(
      scanSucceeded: true,
      scanStatus: 'Identity verified',
    );

    return true;
  }

  /// Resets the entire verification flow.
  void reset() {
    state = const CardIdentityVerificationState.initial();
  }
}

final cardIdentityVerificationProvider = NotifierProvider<
    CardIdentityVerificationNotifier,
    CardIdentityVerificationState>(
  CardIdentityVerificationNotifier.new,
);
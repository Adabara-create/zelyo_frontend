import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The two stages of creating a card PIN.
enum CreateCardPinStage {
  create,
  confirm,
}

/// State for the card PIN creation flow.
class CreateCardPinState {
  final CreateCardPinStage stage;
  final String firstPin;
  final String currentEntry;
  final String? errorText;

  const CreateCardPinState({
    required this.stage,
    required this.firstPin,
    required this.currentEntry,
    required this.errorText,
  });

  const CreateCardPinState.initial()
      : stage = CreateCardPinStage.create,
        firstPin = '',
        currentEntry = '',
        errorText = null;

  CreateCardPinState copyWith({
    CreateCardPinStage? stage,
    String? firstPin,
    String? currentEntry,
    String? errorText,
    bool clearError = false,
  }) {
    return CreateCardPinState(
      stage: stage ?? this.stage,
      firstPin: firstPin ?? this.firstPin,
      currentEntry: currentEntry ?? this.currentEntry,
      errorText: clearError ? null : errorText ?? this.errorText,
    );
  }
}

/// Controls the card PIN creation flow.
///
/// This PIN is separate from the mobile transaction PIN.
class CreateCardPinNotifier
    extends Notifier<CreateCardPinState> {
  static const int pinLength = 4;

  @override
  CreateCardPinState build() {
    return const CreateCardPinState.initial();
  }

  /// Adds a digit to the current PIN entry.
  void addDigit(String digit) {
    if (state.currentEntry.length >= pinLength) return;

    state = state.copyWith(
      currentEntry: '${state.currentEntry}$digit',
      clearError: true,
    );
  }

  /// Removes the last entered digit.
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

  /// Moves from the create stage to the confirm stage.
  void moveToConfirm() {
    state = state.copyWith(
      firstPin: state.currentEntry,
      currentEntry: '',
      stage: CreateCardPinStage.confirm,
      clearError: true,
    );
  }

  /// Resets the flow back to creating the first PIN.
  void backToCreate() {
    state = const CreateCardPinState.initial();
  }

  /// Verifies whether the confirmation PIN matches.
  bool verifyMatch() {
    if (state.currentEntry == state.firstPin) {
      return true;
    }

    state = state.copyWith(
      currentEntry: '',
      errorText: "PINs didn't match. Try again.",
    );

    return false;
  }

  /// Completely resets the provider.
  void reset() {
    state = const CreateCardPinState.initial();
  }
}

final createCardPinProvider =
    NotifierProvider<CreateCardPinNotifier, CreateCardPinState>(
  CreateCardPinNotifier.new,
);
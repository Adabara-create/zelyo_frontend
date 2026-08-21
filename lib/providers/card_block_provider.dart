import 'package:flutter_riverpod/flutter_riverpod.dart';

class CardBlockState {
  final int? selectedReasonIndex;

  const CardBlockState({
    required this.selectedReasonIndex,
  });

  const CardBlockState.initial()
      : selectedReasonIndex = null;

  CardBlockState copyWith({
    int? selectedReasonIndex,
    bool clearSelectedReason = false,
  }) {
    return CardBlockState(
      selectedReasonIndex: clearSelectedReason
          ? null
          : selectedReasonIndex ?? this.selectedReasonIndex,
    );
  }
}

class CardBlockNotifier extends Notifier<CardBlockState> {
  @override
  CardBlockState build() {
    return const CardBlockState.initial();
  }

  void selectReason(int index) {
    state = state.copyWith(
      selectedReasonIndex: index,
    );
  }

  void reset() {
    state = const CardBlockState.initial();
  }
}

final cardBlockProvider =
    NotifierProvider<CardBlockNotifier, CardBlockState>(
  CardBlockNotifier.new,
);
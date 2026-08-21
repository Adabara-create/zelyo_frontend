import 'package:flutter_riverpod/flutter_riverpod.dart';

class CardDetailsState {
  final int selectedIndex;

  const CardDetailsState({
    required this.selectedIndex,
  });

  const CardDetailsState.initial()
      : selectedIndex = 0;

  CardDetailsState copyWith({
    int? selectedIndex,
  }) {
    return CardDetailsState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}

class CardDetailsNotifier extends Notifier<CardDetailsState> {
  @override
  CardDetailsState build() {
    return const CardDetailsState.initial();
  }

  void setSelectedIndex(int index) {
    state = state.copyWith(
      selectedIndex: index,
    );
  }

  void setInitialIndex(int index) {
    state = CardDetailsState(
      selectedIndex: index,
    );
  }

  void reset() {
    state = const CardDetailsState.initial();
  }
}

final cardDetailsProvider =
    NotifierProvider<CardDetailsNotifier, CardDetailsState>(
  CardDetailsNotifier.new,
);
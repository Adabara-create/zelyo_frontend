import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zelyo_1/models/card_models.dart';

/// Replaces the local `_hasCard` / `_isCardBlocked` StatefulWidget state
/// that used to live only inside card_screen.dart. Pulling it into a
/// provider means other screens can react to card status too — e.g.
/// ProfileScreen's "1 card" stat, or Home eventually gating the "Add
/// money to card" pill button until a card actually exists.
class CardAccountState {
  final bool hasCard;
  final bool isBlocked;
  final List<VirtualCardData> cards;

  const CardAccountState({
    required this.hasCard,
    required this.isBlocked,
    required this.cards,
  });

  CardAccountState copyWith({
    bool? hasCard,
    bool? isBlocked,
    List<VirtualCardData>? cards,
  }) {
    return CardAccountState(
      hasCard: hasCard ?? this.hasCard,
      isBlocked: isBlocked ?? this.isBlocked,
      cards: cards ?? this.cards,
    );
  }
}

class CardsNotifier extends Notifier<CardAccountState> {
  @override
  CardAccountState build() {
    // TODO: replace with a real fetch — hasCard/isBlocked should come
    // from the backend, not default to false on every app start.
    return const CardAccountState(
      hasCard: false,
      isBlocked: false,
      cards: sampleVirtualCards,
    );
  }

  /// Called once identity verification + mobile PIN + card PIN setup
  /// all succeed in card_screen.dart's `_onOpenCardTap` chain.
  void openCard() {
    state = state.copyWith(hasCard: true);
  }

  /// Called from CardBlockScreen once the reason + PIN confirmation
  /// flow completes.
  void blockCard() {
    state = state.copyWith(isBlocked: true);
  }

  /// Called from Card settings once "unblock" is wired up there.
  void unblockCard() {
    state = state.copyWith(isBlocked: false);
  }

  /// Called from CardSettingsScreen's "Delete card" confirmation —
  /// resets back to the intro state in card_screen.dart.
  void deleteCard() {
    state = state.copyWith(hasCard: false, isBlocked: false);
  }
}

final cardsProvider = NotifierProvider<CardsNotifier, CardAccountState>(
  CardsNotifier.new,
);

/// Convenience derived providers so screens that only care about one
/// flag don't need to watch the whole CardAccountState and pull a field
/// out themselves.
final hasCardProvider = Provider<bool>((ref) => ref.watch(cardsProvider).hasCard);
final isCardBlockedProvider = Provider<bool>((ref) => ref.watch(cardsProvider).isBlocked);
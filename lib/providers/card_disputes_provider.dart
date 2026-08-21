import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DisputeStatus {
  investigating,
  resolved,
}

class Dispute {
  final String transactionName;
  final String amount;
  final String dateFiled;
  final DisputeStatus status;

  const Dispute({
    required this.transactionName,
    required this.amount,
    required this.dateFiled,
    required this.status,
  });
}

class CardDisputesState {
  final List<Dispute> disputes;

  const CardDisputesState({
    required this.disputes,
  });

  const CardDisputesState.initial()
      : disputes = const [
          Dispute(
            transactionName: 'Unrecognized charge — Amazon',
            amount: '\$42.00',
            dateFiled: 'Filed 2 days ago',
            status: DisputeStatus.investigating,
          ),
          Dispute(
            transactionName: 'Duplicate charge — Uber',
            amount: '₦8,500',
            dateFiled: 'Filed 3 weeks ago',
            status: DisputeStatus.resolved,
          ),
        ];

  CardDisputesState copyWith({
    List<Dispute>? disputes,
  }) {
    return CardDisputesState(
      disputes: disputes ?? this.disputes,
    );
  }
}

class CardDisputesNotifier
    extends Notifier<CardDisputesState> {
  @override
  CardDisputesState build() {
    // TODO: replace with a real backend fetch.
    return const CardDisputesState.initial();
  }

  void addDispute(Dispute dispute) {
    state = state.copyWith(
      disputes: [
        ...state.disputes,
        dispute,
      ],
    );
  }

  void removeDispute(int index) {
    if (index < 0 || index >= state.disputes.length) {
      return;
    }

    final updated = [...state.disputes]
      ..removeAt(index);

    state = state.copyWith(
      disputes: updated,
    );
  }

  void setDisputes(List<Dispute> disputes) {
    state = state.copyWith(
      disputes: List.unmodifiable(disputes),
    );
  }

  void reset() {
    state = const CardDisputesState.initial();
  }
}

final cardDisputesProvider = NotifierProvider<
    CardDisputesNotifier,
    CardDisputesState>(
  CardDisputesNotifier.new,
);
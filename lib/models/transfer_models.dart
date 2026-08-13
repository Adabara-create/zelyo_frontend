import 'package:flutter/material.dart';

/// A currency the user can transfer from (mirrors the accounts shown on
/// the Home screen's wallet carousel).
class TransferCurrency {
  final String code;
  final String flag;
  final String symbol;
  final double balance;

  const TransferCurrency({
    required this.code,
    required this.flag,
    required this.symbol,
    required this.balance,
  });
}

/// A transfer recipient — either picked from recents or resolved from a
/// manually entered account number + detected bank.
class Recipient {
  final String name;
  final String bankName;
  final String accountNumber;
  final Color avatarColor;
  final String initials;

  const Recipient({
    required this.name,
    required this.bankName,
    required this.accountNumber,
    required this.avatarColor,
    required this.initials,
  });
}

/// Carries the transfer state forward through the flow: pick currency ->
/// pick recipient -> add amount -> review -> authorize -> success.
/// Each screen receives the request so far and passes along an updated
/// copy via [copyWith] rather than screens reaching back for state.
class TransferRequest {
  final TransferCurrency currency;
  final Recipient recipient;
  final double amount;
  final String narration;

  const TransferRequest({
    required this.currency,
    required this.recipient,
    this.amount = 0,
    this.narration = '',
  });

  /// Simple flat-fee simulation — swap for your real fee schedule.
  /// TODO: replace with actual fee calculation from your backend.
  double get fee {
    if (amount <= 0) return 0;
    final calculated = amount * 0.005; // 0.5%
    return calculated.clamp(10, 2000);
  }

  double get total => amount + fee;

  TransferRequest copyWith({
    TransferCurrency? currency,
    Recipient? recipient,
    double? amount,
    String? narration,
  }) {
    return TransferRequest(
      currency: currency ?? this.currency,
      recipient: recipient ?? this.recipient,
      amount: amount ?? this.amount,
      narration: narration ?? this.narration,
    );
  }
}

String formatAmount(num value) {
  final isNegative = value < 0;
  final absValue = value.abs();
  final wholePart = absValue.truncate().toString();
  final decimalPart =
      ((absValue - absValue.truncate()) * 100).round().toString().padLeft(2, '0');

  final buffer = StringBuffer();
  for (int i = 0; i < wholePart.length; i++) {
    if (i > 0 && (wholePart.length - i) % 3 == 0) buffer.write(',');
    buffer.write(wholePart[i]);
  }

  return '${isNegative ? '-' : ''}$buffer.$decimalPart';
}
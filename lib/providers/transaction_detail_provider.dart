import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents the transaction currently being viewed on the
/// Transaction Details screen.
///
/// This model intentionally stays independent from the private
/// transaction models used by HomeScreen and HistoryScreen.
class TransactionDetailData {
  final String name;
  final String subtitle;
  final String date;
  final String time;
  final double amount;
  final String currencySymbol;
  final IconData icon;
  final Color iconColor;

  final String category;
  final String paymentMethod;
  final String status;

  final String? recipientBank;
  final String? recipientAccountNumber;

  final double? fee;
  final String? narration;

  const TransactionDetailData({
    required this.name,
    required this.subtitle,
    required this.date,
    required this.time,
    required this.amount,
    required this.currencySymbol,
    required this.icon,
    required this.iconColor,
    this.category = 'Transaction',
    this.paymentMethod = 'Zelyo wallet',
    this.status = 'Successful',
    this.recipientBank,
    this.recipientAccountNumber,
    this.fee,
    this.narration,
  });

  /// Creates a copy of the transaction while allowing
  /// individual fields to be changed.
  TransactionDetailData copyWith({
    String? name,
    String? subtitle,
    String? date,
    String? time,
    double? amount,
    String? currencySymbol,
    IconData? icon,
    Color? iconColor,
    String? category,
    String? paymentMethod,
    String? status,
    String? recipientBank,
    String? recipientAccountNumber,
    double? fee,
    String? narration,
  }) {
    return TransactionDetailData(
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      date: date ?? this.date,
      time: time ?? this.time,
      amount: amount ?? this.amount,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      recipientBank: recipientBank ?? this.recipientBank,
      recipientAccountNumber:
          recipientAccountNumber ?? this.recipientAccountNumber,
      fee: fee ?? this.fee,
      narration: narration ?? this.narration,
    );
  }
}

/// Stores the transaction currently selected by the user.
///
/// Example:
///
/// ref.read(transactionDetailProvider.notifier).state =
///     TransactionDetailData(...);
///
/// Any ConsumerWidget watching this provider will rebuild whenever
/// the selected transaction changes.
final transactionDetailProvider =
    StateProvider<TransactionDetailData?>((ref) {
  return null;
});
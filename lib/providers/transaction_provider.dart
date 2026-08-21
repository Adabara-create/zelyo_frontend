import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zelyo_1/theme/app_colors.dart';

/// All transaction types supported by Zelyo.
enum TransactionCategory {
  deposit,
  withdraw,
  transfer,
  convert,
}

/// Shared transaction model.
///
/// This model is intentionally public because transactions are created by
/// TransferScreen, DepositScreen, WithdrawScreen, ConvertScreen, etc.,
/// and displayed by HistoryScreen.
class TransactionRecord {
  final String id;
  final String name;
  final String subtitle;
  final TransactionCategory category;
  final String currencyCode;
  final String currencySymbol;
  final double amount; // positive = inflow, negative = outflow
  final DateTime timestamp;

  const TransactionRecord({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.category,
    required this.currencyCode,
    required this.currencySymbol,
    required this.amount,
    required this.timestamp,
  });

  TransactionRecord copyWith({
    String? id,
    String? name,
    String? subtitle,
    TransactionCategory? category,
    String? currencyCode,
    String? currencySymbol,
    double? amount,
    DateTime? timestamp,
  }) {
    return TransactionRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  ({
    IconData icon,
    Color color,
  }) get visuals {
    switch (category) {
      case TransactionCategory.deposit:
        return (
          icon: Icons.south_west_rounded,
          color: AppColors.success,
        );

      case TransactionCategory.withdraw:
        return (
          icon: Icons.north_east_rounded,
          color: const Color(0xFFF59E0B),
        );

      case TransactionCategory.transfer:
        return (
          icon: Icons.swap_horiz_rounded,
          color: AppColors.primaryBlueLight,
        );

      case TransactionCategory.convert:
        return (
          icon: Icons.currency_exchange_rounded,
          color: const Color(0xFF7C5CFC),
        );
    }
  }
}

/// Single source of truth for transaction history.
class TransactionsNotifier
    extends Notifier<List<TransactionRecord>> {
  @override
  List<TransactionRecord> build() {
    // Keep your sample history for now.
    // Later this can be replaced with a backend/API fetch.
    return _buildSampleTransactions();
  }

  List<TransactionRecord> _buildSampleTransactions() {
    final now = DateTime.now();

    return [
      TransactionRecord(
        id: 'sample-1',
        name: 'David Eze',
        subtitle: 'Transfer received',
        category: TransactionCategory.transfer,
        currencyCode: 'NGN',
        currencySymbol: '₦',
        amount: 45000,
        timestamp: now.subtract(
          const Duration(minutes: 25),
        ),
      ),
      TransactionRecord(
        id: 'sample-2',
        name: 'Netflix Subscription',
        subtitle: 'Transfer sent',
        category: TransactionCategory.transfer,
        currencyCode: 'USD',
        currencySymbol: '\$',
        amount: -15.99,
        timestamp: now.subtract(
          const Duration(hours: 2),
        ),
      ),
      TransactionRecord(
        id: 'sample-3',
        name: 'Wallet top-up',
        subtitle: 'Bank transfer deposit',
        category: TransactionCategory.deposit,
        currencyCode: 'NGN',
        currencySymbol: '₦',
        amount: 100000,
        timestamp: now.subtract(
          const Duration(hours: 5),
        ),
      ),
      TransactionRecord(
        id: 'sample-4',
        name: 'GTBank ATM',
        subtitle: 'Cash withdrawal',
        category: TransactionCategory.withdraw,
        currencyCode: 'NGN',
        currencySymbol: '₦',
        amount: -20000,
        timestamp: now.subtract(
          const Duration(hours: 8),
        ),
      ),
      TransactionRecord(
        id: 'sample-5',
        name: 'USD to NGN',
        subtitle: 'Currency conversion',
        category: TransactionCategory.convert,
        currencyCode: 'USD',
        currencySymbol: '\$',
        amount: -50,
        timestamp: now.subtract(
          const Duration(days: 1, hours: 1),
        ),
      ),
      TransactionRecord(
        id: 'sample-6',
        name: 'Tomiwa Precious',
        subtitle: 'Transfer received',
        category: TransactionCategory.transfer,
        currencyCode: 'NGN',
        currencySymbol: '₦',
        amount: 15000,
        timestamp: now.subtract(
          const Duration(days: 1, hours: 4),
        ),
      ),
      TransactionRecord(
        id: 'sample-7',
        name: 'Card deposit',
        subtitle: 'Debit card top-up',
        category: TransactionCategory.deposit,
        currencyCode: 'USD',
        currencySymbol: '\$',
        amount: 500,
        timestamp: now.subtract(
          const Duration(days: 1, hours: 9),
        ),
      ),
      TransactionRecord(
        id: 'sample-8',
        name: 'Rent payment',
        subtitle: 'Transfer sent',
        category: TransactionCategory.transfer,
        currencyCode: 'GBP',
        currencySymbol: '£',
        amount: -650,
        timestamp: now.subtract(
          const Duration(days: 3),
        ),
      ),
      TransactionRecord(
        id: 'sample-9',
        name: 'Access Bank',
        subtitle: 'Bank withdrawal',
        category: TransactionCategory.withdraw,
        currencyCode: 'EUR',
        currencySymbol: '€',
        amount: -200,
        timestamp: now.subtract(
          const Duration(days: 4),
        ),
      ),
      TransactionRecord(
        id: 'sample-10',
        name: 'EUR to GBP',
        subtitle: 'Currency conversion',
        category: TransactionCategory.convert,
        currencyCode: 'EUR',
        currencySymbol: '€',
        amount: -300,
        timestamp: now.subtract(
          const Duration(days: 6),
        ),
      ),
      TransactionRecord(
        id: 'sample-11',
        name: 'Moyo Adebayo',
        subtitle: 'Transfer received',
        category: TransactionCategory.transfer,
        currencyCode: 'NGN',
        currencySymbol: '₦',
        amount: 32000,
        timestamp: now.subtract(
          const Duration(days: 9),
        ),
      ),
      TransactionRecord(
        id: 'sample-12',
        name: 'Salary',
        subtitle: 'Bank transfer deposit',
        category: TransactionCategory.deposit,
        currencyCode: 'NGN',
        currencySymbol: '₦',
        amount: 620000,
        timestamp: now.subtract(
          const Duration(days: 12),
        ),
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Generic transaction operations
  // ---------------------------------------------------------------------------

  void addTransaction(
    TransactionRecord transaction,
  ) {
    state = [
      transaction,
      ...state,
    ];
  }

  void replaceTransactions(
    List<TransactionRecord> transactions,
  ) {
    state = List.unmodifiable(
      transactions,
    );
  }

  void removeTransaction(
    String id,
  ) {
    state = state
        .where(
          (transaction) => transaction.id != id,
        )
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Transaction-specific operations
  // ---------------------------------------------------------------------------

  void recordDeposit({
    required String name,
    required String currencyCode,
    required String currencySymbol,
    required double amount,
    String subtitle = 'Wallet deposit',
  }) {
    addTransaction(
      TransactionRecord(
        id: _generateId('deposit'),
        name: name,
        subtitle: subtitle,
        category: TransactionCategory.deposit,
        currencyCode: currencyCode,
        currencySymbol: currencySymbol,
        amount: amount.abs(),
        timestamp: DateTime.now(),
      ),
    );
  }

  void recordWithdraw({
    required String name,
    required String currencyCode,
    required String currencySymbol,
    required double amount,
    String subtitle = 'Bank withdrawal',
  }) {
    addTransaction(
      TransactionRecord(
        id: _generateId('withdraw'),
        name: name,
        subtitle: subtitle,
        category: TransactionCategory.withdraw,
        currencyCode: currencyCode,
        currencySymbol: currencySymbol,
        amount: -amount.abs(),
        timestamp: DateTime.now(),
      ),
    );
  }

  void recordTransfer({
    required String name,
    required String currencyCode,
    required String currencySymbol,
    required double amount,
    String subtitle = 'Transfer sent',
  }) {
    addTransaction(
      TransactionRecord(
        id: _generateId('transfer'),
        name: name,
        subtitle: subtitle,
        category: TransactionCategory.transfer,
        currencyCode: currencyCode,
        currencySymbol: currencySymbol,
        amount: -amount.abs(),
        timestamp: DateTime.now(),
      ),
    );
  }

  void recordConversion({
    required String fromCurrencyCode,
    required String fromCurrencySymbol,
    required double fromAmount,
    required String toCurrencyCode,
    required String toCurrencySymbol,
    required double toAmount,
  }) {
    addTransaction(
      TransactionRecord(
        id: _generateId('convert'),
        name:
            '$fromCurrencyCode to $toCurrencyCode',
        subtitle:
            'Currency conversion • '
            'Received '
            '$toCurrencySymbol${toAmount.toStringAsFixed(2)} '
            '$toCurrencyCode',
        category: TransactionCategory.convert,
        currencyCode: fromCurrencyCode,
        currencySymbol: fromCurrencySymbol,
        amount: -fromAmount.abs(),
        timestamp: DateTime.now(),
      ),
    );
  }

  String _generateId(String type) {
    return '$type-${DateTime.now().microsecondsSinceEpoch}';
  }
}

final transactionsProvider =
    NotifierProvider<
      TransactionsNotifier,
      List<TransactionRecord>
    >(
  TransactionsNotifier.new,
);
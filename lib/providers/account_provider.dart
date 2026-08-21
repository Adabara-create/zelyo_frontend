import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zelyo_1/models/transfer_models.dart';


class AccountsNotifier extends Notifier<List<TransferCurrency>> {
  @override
  List<TransferCurrency> build() {
    // TODO: Replace with the authenticated user's wallet/API response.
    return const [
      TransferCurrency(
        code: 'NGN',
        flag: '🇳🇬',
        symbol: '₦',
        balance: 482350.75,
      ),
      TransferCurrency(
        code: 'USD',
        flag: '🇺🇸',
        symbol: '\$',
        balance: 3240.50,
      ),
      TransferCurrency(
        code: 'EUR',
        flag: '🇪🇺',
        symbol: '€',
        balance: 1875.20,
      ),
      TransferCurrency(
        code: 'GBP',
        flag: '🇬🇧',
        symbol: '£',
        balance: 962.00,
      ),
      TransferCurrency(
        code: 'JPY',
        flag: '🇯🇵',
        symbol: '¥',
        balance: 158400,
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // READ OPERATIONS
  // ---------------------------------------------------------------------------

  /// Returns the account for [code].
  ///
  /// Throws a [StateError] if the currency does not exist.
  TransferCurrency byCode(String code) {
    for (final account in state) {
      if (account.code == code) {
        return account;
      }
    }

    throw StateError('Currency account "$code" does not exist.');
  }

  /// Returns true when the wallet contains [code].
  bool hasCurrency(String code) {
    return state.any((account) => account.code == code);
  }

  /// Returns the current balance for [code].
  double balanceOf(String code) {
    return byCode(code).balance;
  }

  // ---------------------------------------------------------------------------
  // BALANCE OPERATIONS
  // ---------------------------------------------------------------------------

  /// Completely replaces a currency balance.
  ///
  /// Useful when:
  /// - syncing with backend
  /// - refreshing a wallet
  /// - correcting a balance
  void setBalance({
    required String code,
    required double amount,
  }) {
    if (amount < 0) {
      throw ArgumentError('Balance cannot be negative.');
    }

    _updateAccount(
      code,
      (account) => account.copyWith(balance: amount),
    );
  }

  /// Adds or subtracts money from a currency.
  ///
  /// Positive [delta]  -> money comes in.
  /// Negative [delta]  -> money goes out.
  ///
  /// Example:
  /// adjustBalance(code: 'NGN', delta: 50000);
  void adjustBalance({
    required String code,
    required double delta,
  }) {
    final current = byCode(code);
    final newBalance = current.balance + delta;

    if (newBalance < 0) {
      throw StateError(
        'Insufficient ${current.code} balance.',
      );
    }

    setBalance(
      code: code,
      amount: newBalance,
    );
  }

  // ---------------------------------------------------------------------------
  // WALLET OPERATIONS
  // ---------------------------------------------------------------------------

  /// Deposits money into a currency account.
  void deposit({
    required String code,
    required double amount,
  }) {
    _validatePositiveAmount(amount);

    adjustBalance(
      code: code,
      delta: amount,
    );
  }

  /// Withdraws money from a currency account.
  void withdraw({
    required String code,
    required double amount,
  }) {
    _validatePositiveAmount(amount);

    adjustBalance(
      code: code,
      delta: -amount,
    );
  }

  /// Transfers money between two currency accounts.
  ///
  /// This updates both balances in ONE state assignment so consumers never
  /// observe an intermediate state where only one side has changed.
  void transfer({
    required String fromCode,
    required String toCode,
    required double fromAmount,
    required double toAmount,
  }) {
    _validatePositiveAmount(fromAmount);
    _validatePositiveAmount(toAmount);

    if (fromCode == toCode) {
      throw StateError(
        'Source and destination currencies cannot be the same.',
      );
    }

    final fromAccount = byCode(fromCode);
    byCode(toCode); // Validate destination exists.

    if (fromAccount.balance < fromAmount) {
      throw StateError(
        'Insufficient ${fromAccount.code} balance.',
      );
    }

    state = [
      for (final account in state)
        if (account.code == fromCode)
          account.copyWith(
            balance: account.balance - fromAmount,
          )
        else if (account.code == toCode)
          account.copyWith(
            balance: account.balance + toAmount,
          )
        else
          account,
    ];
  }

  /// Converts money from one currency into another.
  ///
  /// [fromAmount] is removed from the source currency.
  /// [toAmount] is added to the destination currency.
  ///
  /// The conversion rate/fee calculation should happen in ConvertScreen
  /// or, preferably later, in a backend/service layer.
  void convert({
    required String fromCode,
    required String toCode,
    required double fromAmount,
    required double toAmount,
  }) {
    transfer(
      fromCode: fromCode,
      toCode: toCode,
      fromAmount: fromAmount,
      toAmount: toAmount,
    );
  }

  // ---------------------------------------------------------------------------
  // INTERNAL HELPERS
  // ---------------------------------------------------------------------------

  /// Updates exactly one account while keeping every other account unchanged.
  void _updateAccount(
    String code,
    TransferCurrency Function(TransferCurrency account) update,
  ) {
    // Make sure the account exists before attempting the update.
    byCode(code);

    state = [
      for (final account in state)
        account.code == code ? update(account) : account,
    ];
  }

  void _validatePositiveAmount(double amount) {
    if (amount <= 0) {
      throw ArgumentError(
        'Amount must be greater than zero.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // FUTURE BACKEND INTEGRATION
  // ---------------------------------------------------------------------------

  /// Replace the entire wallet state.
  ///
  /// This is intentionally kept separate from [setBalance] because later
  /// your backend may return all wallet accounts at once.
  void replaceAccounts(List<TransferCurrency> accounts) {
    state = List.unmodifiable(accounts);
  }

  /// Resets the wallet to the initial local/demo data.
  ///
  /// Useful during development and testing.
  void reset() {
    state = build();
  }
}

/// Global wallet state provider.
///
/// Every wallet-related screen should access balances through this provider.
final accountsProvider =
    NotifierProvider<AccountsNotifier, List<TransferCurrency>>(
  AccountsNotifier.new,
);


final accountByCodeProvider =
    Provider.family<TransferCurrency, String>((ref, code) {
  final accounts = ref.watch(accountsProvider);

  for (final account in accounts) {
    if (account.code == code) {
      return account;
    }
  }

  throw StateError(
    'Currency account "$code" does not exist.',
  );
});

/// Convenience provider for only a currency's balance.
///
/// This is useful for widgets that don't need the complete account object
/// and therefore shouldn't rebuild because unrelated account metadata changes.
final balanceByCodeProvider =
    Provider.family<double, String>((ref, code) {
  return ref.watch(
    accountByCodeProvider(code).select(
      (account) => account.balance,
    ),
  );
});
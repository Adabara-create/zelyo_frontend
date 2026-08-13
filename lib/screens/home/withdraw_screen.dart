import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/models/transfer_models.dart';
import 'package:zelyo_1/widgets/pin_dot_indicator.dart';
import 'package:zelyo_1/widgets/pin_keypad.dart';

/// Withdraw screen — pick which currency wallet to withdraw from, which
/// saved bank account it goes to, how much, then authorize with a PIN
/// right here via a bottom sheet rather than a separate screen, since
/// there's no recipient-confirmation step withdrawals need (unlike
/// transfers).
///
/// Reuses [TransferCurrency] / [formatAmount] from transfer_models.dart
/// and the shared [PinDotIndicator] / [PinKeypad] widgets so both the
/// data and the PIN entry stay consistent with the rest of the app.
class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _BankAccount {
  final String bankName;
  final String accountNumberMasked;
  final String accountName;

  const _BankAccount({
    required this.bankName,
    required this.accountNumberMasked,
    required this.accountName,
  });
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  // TODO: replace with the user's real multi-currency accounts.
  final List<TransferCurrency> _currencies = const [
    TransferCurrency(code: 'NGN', flag: '🇳🇬', symbol: '₦', balance: 482350.75),
    TransferCurrency(code: 'USD', flag: '🇺🇸', symbol: '\$', balance: 3240.50),
    TransferCurrency(code: 'EUR', flag: '🇪🇺', symbol: '€', balance: 1875.20),
    TransferCurrency(code: 'GBP', flag: '🇬🇧', symbol: '£', balance: 962.00),
    TransferCurrency(code: 'JPY', flag: '🇯🇵', symbol: '¥', balance: 158400),
  ];

  // TODO: replace with the user's real saved/linked bank accounts.
  final List<_BankAccount> _bankAccounts = const [
    _BankAccount(bankName: 'GTBank', accountNumberMasked: '•••• •••• 4471', accountName: 'Amara Johnson'),
    _BankAccount(bankName: 'Access Bank', accountNumberMasked: '•••• •••• 8823', accountName: 'Amara Johnson'),
  ];

  late TransferCurrency _selectedCurrency;
  late _BankAccount _selectedAccount;

  final TextEditingController _amountController = TextEditingController();
  double _amount = 0;
  // bool _isAuthorizing = false; this isn't currently being in use, so i disabled it

  @override
  void initState() {
    super.initState();
    _selectedCurrency = _currencies.first;
    _selectedAccount = _bankAccounts.first;
    _amountController.addListener(() {
      setState(() => _amount = double.tryParse(_amountController.text) ?? 0);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // TODO: replace with your real withdrawal fee schedule per currency.
  double get _fee {
    if (_amount <= 0) return 0;
    return _selectedCurrency.code == 'NGN' ? 50 : 2.0;
  }

  double get _netAmount => (_amount - _fee).clamp(0, double.infinity);

  bool get _exceedsBalance => _amount > _selectedCurrency.balance;
  bool get _canWithdraw => _amount > 0 && !_exceedsBalance;

  Future<void> _pickCurrency() async {
    final picked = await showModalBottomSheet<TransferCurrency>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _CurrencyPickerSheet(currencies: _currencies, selected: _selectedCurrency),
    );
    if (picked != null) setState(() => _selectedCurrency = picked);
  }

  Future<void> _pickBankAccount() async {
    final picked = await showModalBottomSheet<_BankAccount>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _BankAccountPickerSheet(accounts: _bankAccounts, selected: _selectedAccount),
    );
    if (picked != null) setState(() => _selectedAccount = picked);
  }

  Future<void> _onWithdrawTap() async {
    if (!_canWithdraw) return;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AuthorizeWithdrawalSheet(
        amount: _amount,
        currency: _selectedCurrency,
        account: _selectedAccount,
      ),
    );
    if (confirmed != true || !mounted) return;
    _showWithdrawSuccessDialog();
  }

  void _showWithdrawSuccessDialog() {
    final amount = _amount;
    final currency = _selectedCurrency;
    final account = _selectedAccount;
    _amountController.clear();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.outlineBorder, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.success.withOpacity(0.15)),
                child: const Icon(Icons.check_rounded, color: AppColors.success, size: 38),
              ),
              const SizedBox(height: 20),
              const Text(
                'Withdrawal successful',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                '${currency.symbol}${formatAmount(amount)} is on its way to your ${account.bankName} account.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13.5, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Done', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCurrencySelector(),
                    const SizedBox(height: 24),
                    _buildAmountInput(),
                    const SizedBox(height: 28),
                    const Text(
                      'Withdraw to',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    _buildBankAccountCard(),
                    const SizedBox(height: 24),
                    _buildFeeSummary(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canWithdraw ? _onWithdrawTap : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    disabledBackgroundColor: AppColors.surface,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: AppColors.textMuted,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Withdraw', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(width: 4),
          const Text(
            'Withdraw',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 19, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector() {
    return InkWell(
      onTap: _pickCurrency,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.outlineBorder, width: 1),
        ),
        child: Row(
          children: [
            Text(_selectedCurrency.flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Withdraw from',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11.5, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_selectedCurrency.code} • ${_selectedCurrency.symbol}${formatAmount(_selectedCurrency.balance)}',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Center(
      child: Column(
        children: [
          const Text(
            'Amount to withdraw',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          IntrinsicWidth(
            child: TextField(
              controller: _amountController,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 40, fontWeight: FontWeight.w800),
              cursorColor: AppColors.primaryBlue,
              decoration: InputDecoration(
                prefixText: '${_selectedCurrency.symbol} ',
                prefixStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 40, fontWeight: FontWeight.w800),
                hintText: '0',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 40, fontWeight: FontWeight.w800),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _exceedsBalance
                ? 'Insufficient balance'
                : 'Available: ${_selectedCurrency.symbol}${formatAmount(_selectedCurrency.balance)}',
            style: TextStyle(
              color: _exceedsBalance ? AppColors.danger : AppColors.textMuted,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountCard() {
    return InkWell(
      onTap: _pickBankAccount,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.outlineBorder, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryBlue.withOpacity(0.14)),
              child: const Icon(Icons.account_balance_rounded, color: AppColors.primaryBlueLight, size: 19),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selectedAccount.bankName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(_selectedAccount.accountNumberMasked, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                ],
              ),
            ),
            const Text(
              'Change',
              style: TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineBorder, width: 1),
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Withdrawal amount', value: '${_selectedCurrency.symbol}${formatAmount(_amount)}'),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Fee', value: '${_selectedCurrency.symbol}${formatAmount(_fee)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.outlineBorder, height: 1),
          ),
          _SummaryRow(
            label: "You'll receive",
            value: '${_selectedCurrency.symbol}${formatAmount(_netAmount)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? AppColors.textPrimary : AppColors.textMuted,
            fontSize: isTotal ? 14.5 : 13.5,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: isTotal ? 16 : 13.5,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CurrencyPickerSheet extends StatelessWidget {
  final List<TransferCurrency> currencies;
  final TransferCurrency selected;

  const _CurrencyPickerSheet({required this.currencies, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: AppColors.outlineBorder, borderRadius: BorderRadius.circular(4)),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Withdraw from', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 16),
          ...currencies.map((currency) {
            final isSelected = currency.code == selected.code;
            return InkWell(
              onTap: () => Navigator.of(context).pop(currency),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Text(currency.flag, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(currency.code, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text('${currency.symbol}${formatAmount(currency.balance)}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                        ],
                      ),
                    ),
                    if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue, size: 20),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _BankAccountPickerSheet extends StatelessWidget {
  final List<_BankAccount> accounts;
  final _BankAccount selected;

  const _BankAccountPickerSheet({required this.accounts, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: AppColors.outlineBorder, borderRadius: BorderRadius.circular(4)),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Withdraw to', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 16),
            ...accounts.map((account) {
              final isSelected = account.accountNumberMasked == selected.accountNumberMasked &&
                  account.bankName == selected.bankName;
              return InkWell(
                onTap: () => Navigator.of(context).pop(account),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryBlue.withOpacity(0.14)),
                        child: const Icon(Icons.account_balance_rounded, color: AppColors.primaryBlueLight, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(account.bankName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(account.accountNumberMasked, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                          ],
                        ),
                      ),
                      if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue, size: 20),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 4),
            const Divider(color: AppColors.outlineBorder, height: 20),
            InkWell(
              onTap: () {
                // TODO: navigate to an add-bank-account flow.
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(14),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryBlue, size: 22),
                    SizedBox(width: 14),
                    Text('Add new bank account', style: TextStyle(color: AppColors.primaryBlue, fontSize: 14.5, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Slides up to authorize the withdrawal with a 4-digit transaction PIN
/// — mirrors [AuthorizeTransactionScreen] but as an inline sheet, since
/// withdrawals don't need a separate recipient-review step first.
class _AuthorizeWithdrawalSheet extends StatefulWidget {
  final double amount;
  final TransferCurrency currency;
  final _BankAccount account;

  const _AuthorizeWithdrawalSheet({
    required this.amount,
    required this.currency,
    required this.account,
  });

  @override
  State<_AuthorizeWithdrawalSheet> createState() => _AuthorizeWithdrawalSheetState();
}

class _AuthorizeWithdrawalSheetState extends State<_AuthorizeWithdrawalSheet>
    with SingleTickerProviderStateMixin {
  static const int _pinLength = 4;

  // TODO: replace with your real stored/verified transaction PIN check.
  static const String _correctPin = '1234';

  String _pin = '';
  String? _errorText;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onDigitTap(String digit) {
    if (_pin.length >= _pinLength) return;
    HapticFeedback.selectionClick();
    setState(() {
      _pin += digit;
      _errorText = null;
    });
    if (_pin.length == _pinLength) _verifyPin();
  }

  void _onBackspaceTap() {
    if (_pin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _errorText = null;
    });
  }

  Future<void> _verifyPin() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    if (_pin == _correctPin) {
      Navigator.of(context).pop(true);
      return;
    }

    HapticFeedback.mediumImpact();
    _shakeController.forward(from: 0);
    setState(() {
      _errorText = 'Incorrect PIN. Try again.';
      _pin = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: AppColors.outlineBorder, borderRadius: BorderRadius.circular(4)),
            ),
            const Text(
              'Authorize withdrawal',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              _errorText ??
                  'Enter your PIN to withdraw ${widget.currency.symbol}${formatAmount(widget.amount)} to ${widget.account.bankName}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: _errorText != null ? Colors.redAccent : AppColors.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) => Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: child,
              ),
              child: PinDotIndicator(length: _pinLength, filledCount: _pin.length, hasError: _errorText != null),
            ),
            const SizedBox(height: 28),
            PinKeypad(onDigitTap: _onDigitTap, onBackspaceTap: _onBackspaceTap),
          ],
        ),
      ),
    );
  }
}
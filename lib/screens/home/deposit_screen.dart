import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/models/transfer_models.dart';

/// Deposit screen — pick which currency wallet to fund, then either
/// transfer into a dedicated virtual account or top up with a card.
///
/// Reuses [TransferCurrency] / [formatAmount] from transfer_models.dart
/// so the currency list and formatting stay identical to the transfer
/// flow and the Home wallet carousel.
class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

enum _DepositMethod { bankTransfer, card }

class _DepositScreenState extends State<DepositScreen> {
  // TODO: replace with the user's real multi-currency accounts.
  final List<TransferCurrency> _currencies = const [
    TransferCurrency(code: 'NGN', flag: '🇳🇬', symbol: '₦', balance: 482350.75),
    TransferCurrency(code: 'USD', flag: '🇺🇸', symbol: '\$', balance: 3240.50),
    TransferCurrency(code: 'EUR', flag: '🇪🇺', symbol: '€', balance: 1875.20),
    TransferCurrency(code: 'GBP', flag: '🇬🇧', symbol: '£', balance: 962.00),
    TransferCurrency(code: 'JPY', flag: '🇯🇵', symbol: '¥', balance: 158400),
  ];

  late TransferCurrency _selectedCurrency;
  _DepositMethod _method = _DepositMethod.bankTransfer;

  final TextEditingController _amountController = TextEditingController();
  double _cardAmount = 0;

  // Card on file — starts with a sample card, replaceable via the
  // "Change" sheet. In a real app this should hold only what's safe to
  // display (last 4 digits, expiry, card brand) — see the security note
  // on _ChangeCardSheet below.
  String _cardLast4 = '4821';
  String _cardExpiry = '09/28';

  @override
  void initState() {
    super.initState();
    _selectedCurrency = _currencies.first;
    _amountController.addListener(() {
      setState(() => _cardAmount = double.tryParse(_amountController.text) ?? 0);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // TODO: replace with real per-currency virtual account details from
  // your provider (e.g. Providus for NGN, a partner bank for USD/EUR/etc).
  ({String bankName, String accountNumber, String accountName}) get _virtualAccount {
    final code = _selectedCurrency.code;
    return (
      bankName: code == 'NGN' ? 'Providus Bank' : 'Zelyo Partner Bank',
      accountNumber: '90${code.codeUnits.fold<int>(0, (a, b) => a + b) % 90000000 + 1000000}',
      accountName: 'Amara Johnson — Zelyo',
    );
  }

  Future<void> _pickCurrency() async {
    final picked = await showModalBottomSheet<TransferCurrency>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _CurrencyPickerSheet(currencies: _currencies, selected: _selectedCurrency),
    );
    if (picked != null) setState(() => _selectedCurrency = picked);
  }

  Future<void> _copyToClipboard(String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
        content: Text('$label copied', style: const TextStyle(color: AppColors.textPrimary)),
      ),
    );
  }

  Future<void> _openChangeCardSheet() async {
    final result = await showModalBottomSheet<({String last4, String expiry})>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _ChangeCardSheet(),
    );
    if (result == null || !mounted) return;
    setState(() {
      _cardLast4 = result.last4;
      _cardExpiry = result.expiry;
    });
  }

  void _onAddMoneyTap() {
    if (_cardAmount <= 0) return;
    // TODO: integrate a real payment gateway (Paystack, Flutterwave,
    // Stripe, etc) here — actually charge the card and only show success
    // once the gateway confirms it. This just simulates a successful
    // deposit so the flow is demonstrable end to end.
    final amount = _cardAmount;
    final currency = _selectedCurrency;
    _amountController.clear();
    _showDepositSuccessDialog(amount: amount, currency: currency);
  }

  Future<void> _showDepositSuccessDialog({
    required double amount,
    required TransferCurrency currency,
  }) {
    return showDialog(
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
                'Deposit successful',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                '${currency.symbol}${formatAmount(amount)} has been added to your ${currency.code} wallet.',
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
    final account = _virtualAccount;

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
                    const SizedBox(height: 20),
                    _buildMethodSelector(),
                    const SizedBox(height: 24),
                    if (_method == _DepositMethod.bankTransfer)
                      _buildBankTransferContent(account)
                    else
                      _buildCardContent(),
                  ],
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
            'Deposit',
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
                    'Deposit into',
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

  Widget _buildMethodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineBorder, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MethodTab(
              label: 'Bank transfer',
              icon: Icons.account_balance_outlined,
              isSelected: _method == _DepositMethod.bankTransfer,
              onTap: () => setState(() => _method = _DepositMethod.bankTransfer),
            ),
          ),
          Expanded(
            child: _MethodTab(
              label: 'Debit card',
              icon: Icons.credit_card_rounded,
              isSelected: _method == _DepositMethod.card,
              onTap: () => setState(() => _method = _DepositMethod.card),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankTransferContent(({String bankName, String accountNumber, String accountName}) account) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ----- Virtual account card -----
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
            ),
            boxShadow: [
              BoxShadow(color: AppColors.primaryBlue.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 12)),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(999)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_selectedCurrency.flag, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                    Text(
                      '${_selectedCurrency.code} virtual account',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // QR block.
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.qr_code_2_rounded, color: AppColors.primaryBlueDark, size: 60),
              ),
              const SizedBox(height: 10),
              Text(
                'Scan to copy account details',
                style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 11.5),
              ),

              const SizedBox(height: 22),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 18),

              _AccountDetailRow(
                label: 'Account number',
                value: account.accountNumber,
                emphasize: true,
                onCopy: () => _copyToClipboard(account.accountNumber, 'Account number'),
              ),
              const SizedBox(height: 14),
              _AccountDetailRow(
                label: 'Bank name',
                value: account.bankName,
                onCopy: () => _copyToClipboard(account.bankName, 'Bank name'),
              ),
              const SizedBox(height: 14),
              _AccountDetailRow(
                label: 'Account name',
                value: account.accountName,
                onCopy: () => _copyToClipboard(account.accountName, 'Account name'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ----- Info note -----
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineBorder, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.primaryBlueLight, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Transfers to this account are usually credited within a few minutes. This account only accepts ${_selectedCurrency.code}.',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.5),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 54,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: share the account details via the platform share sheet.
            },
            icon: const Icon(Icons.ios_share_rounded, size: 18),
            label: const Text('Share account details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.outlineBorder, width: 1.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Column(
            children: [
              const Text(
                'Amount to add',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              IntrinsicWidth(
                child: TextField(
                  controller: _amountController,
                  autofocus: true,
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
            ],
          ),
        ),

        const SizedBox(height: 28),

        // ----- Card on file -----
        Container(
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
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primaryBlue, AppColors.primaryBlueLight]),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.credit_card_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('•••• •••• •••• $_cardLast4', style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('Expires $_cardExpiry', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              TextButton(
                onPressed: _openChangeCardSheet,
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                child: const Text('Change', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _cardAmount > 0 ? _onAddMoneyTap : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              disabledBackgroundColor: AppColors.surface,
              foregroundColor: Colors.white,
              disabledForegroundColor: AppColors.textMuted,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Add money', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

class _MethodTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue.withOpacity(0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? AppColors.primaryBlueLight : AppColors.textMuted),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryBlueLight : AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCopy;
  final bool emphasize;

  const _AccountDetailRow({
    required this.label,
    required this.value,
    required this.onCopy,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11.5)),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: emphasize ? 17 : 14,
                  fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: emphasize ? 0.5 : 0,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: onCopy,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.copy_rounded, color: Colors.white, size: 15),
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
            child: Text('Deposit into', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
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

/// Slides up to collect new card details.
///
/// SECURITY NOTE — read before wiring this to a real backend: this form
/// collects a raw card number/expiry/CVV, but a production app should
/// never send those raw values to your own server or store them
/// yourself. Handling PANs directly puts your app in PCI-DSS scope,
/// which is a serious compliance burden. Instead, use your payment
/// gateway's SDK (Stripe, Paystack, Flutterwave, etc) to tokenize the
/// card client-side — the SDK sends the sensitive fields straight to
/// the processor and hands you back a safe token plus the last 4
/// digits/expiry, which is all this screen actually needs to display.
/// This sheet is built as a realistic UI shell for that flow, not as a
/// safe way to actually collect and transmit cards yourself.
class _ChangeCardSheet extends StatefulWidget {
  const _ChangeCardSheet();

  @override
  State<_ChangeCardSheet> createState() => _ChangeCardSheetState();
}

class _ChangeCardSheetState extends State<_ChangeCardSheet> {
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  String? _errorText;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      filled: true,
      fillColor: AppColors.surfaceElevated,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.outlineBorder, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.outlineBorder, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.6),
      ),
    );
  }

  void _onSaveTap() {
    final rawNumber = _cardNumberController.text.replaceAll(' ', '');
    final expiry = _expiryController.text.trim();
    final cvv = _cvvController.text.trim();

    if (rawNumber.length < 12 || rawNumber.length > 19) {
      setState(() => _errorText = 'Enter a valid card number.');
      return;
    }
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiry)) {
      setState(() => _errorText = 'Enter expiry as MM/YY.');
      return;
    }
    if (cvv.length < 3 || cvv.length > 4) {
      setState(() => _errorText = 'Enter a valid CVV.');
      return;
    }

    // TODO: pass rawNumber/expiry/cvv to your payment SDK's tokenization
    // call here — never send them to your own backend directly. On
    // success, the SDK gives you back the last4/expiry to store instead.
    Navigator.of(context).pop((last4: rawNumber.substring(rawNumber.length - 4), expiry: expiry));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: AppColors.outlineBorder, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const Text(
                'Change debit card',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your card details are sent straight to our payment processor and are never stored on our servers.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14.5),
                cursorColor: AppColors.primaryBlue,
                decoration: _decoration('Card number'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14.5),
                      cursorColor: AppColors.primaryBlue,
                      decoration: _decoration('MM/YY'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14.5),
                      cursorColor: AppColors.primaryBlue,
                      decoration: _decoration('CVV'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14.5),
                cursorColor: AppColors.primaryBlue,
                decoration: _decoration('Name on card'),
              ),

              if (_errorText != null) ...[
                const SizedBox(height: 10),
                Text(_errorText!, style: const TextStyle(color: Colors.redAccent, fontSize: 12.5)),
              ],

              const SizedBox(height: 20),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _onSaveTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save card', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
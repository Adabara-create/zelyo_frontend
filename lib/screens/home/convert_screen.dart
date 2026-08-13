import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/models/transfer_models.dart';
import 'package:zelyo_1/widgets/pin_dot_indicator.dart';
import 'package:zelyo_1/widgets/pin_keypad.dart';

/// Convert screen — move money between the user's own currency wallets.
/// Pick a "from" and "to" currency, type an amount, see the live
/// converted amount update as you type, then review, authorize with a
/// PIN, and see a success confirmation — all handled right here via
/// bottom sheets rather than separate screens, since (like Withdraw)
/// there's no recipient-confirmation step a same-owner conversion needs.
///
/// Reuses [TransferCurrency] / [formatAmount] from transfer_models.dart
/// and the shared [PinDotIndicator] / [PinKeypad] widgets for full
/// visual and behavioral consistency with the rest of the app.
class ConvertScreen extends StatefulWidget {
  const ConvertScreen({super.key});

  @override
  State<ConvertScreen> createState() => _ConvertScreenState();
}

class _ConvertScreenState extends State<ConvertScreen>
    with SingleTickerProviderStateMixin {
  // TODO: replace with the user's real multi-currency accounts.
  final List<TransferCurrency> _currencies = const [
    TransferCurrency(code: 'NGN', flag: '🇳🇬', symbol: '₦', balance: 482350.75),
    TransferCurrency(code: 'USD', flag: '🇺🇸', symbol: '\$', balance: 3240.50),
    TransferCurrency(code: 'EUR', flag: '🇪🇺', symbol: '€', balance: 1875.20),
    TransferCurrency(code: 'GBP', flag: '🇬🇧', symbol: '£', balance: 962.00),
    TransferCurrency(code: 'JPY', flag: '🇯🇵', symbol: '¥', balance: 158400),
  ];

  // TODO: replace with live rates from a real FX provider.
  static const Map<String, double> _ratesToNgn = {
    'NGN': 1,
    'USD': 1612.40,
    'EUR': 1748.90,
    'GBP': 2041.10,
    'JPY': 10.85,
  };

  late TransferCurrency _fromCurrency;
  late TransferCurrency _toCurrency;

  final TextEditingController _fromAmountController = TextEditingController();
  double _fromAmount = 0;

  late final AnimationController _swapController;

  @override
  void initState() {
    super.initState();
    _fromCurrency = _currencies[0];
    _toCurrency = _currencies[1];
    _swapController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fromAmountController.addListener(() {
      setState(() => _fromAmount = double.tryParse(_fromAmountController.text) ?? 0);
    });
  }

  @override
  void dispose() {
    _fromAmountController.dispose();
    _swapController.dispose();
    super.dispose();
  }

  double get _rate => _ratesToNgn[_fromCurrency.code]! / _ratesToNgn[_toCurrency.code]!;

  // TODO: replace with your real conversion fee schedule.
  double get _fee => _fromAmount * 0.005;

  double get _netFromAmount => (_fromAmount - _fee).clamp(0, double.infinity);

  double get _toAmount => _netFromAmount * _rate;

  bool get _exceedsBalance => _fromAmount > _fromCurrency.balance;
  bool get _canContinue => _fromAmount > 0 && !_exceedsBalance;

  void _onSwapTap() {
    HapticFeedback.selectionClick();
    _swapController.forward(from: 0);
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
  }

  Future<void> _pickFromCurrency() async {
    final picked = await showModalBottomSheet<TransferCurrency>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _CurrencyPickerSheet(
        title: 'Convert from',
        currencies: _currencies,
        selected: _fromCurrency,
        excludeCode: _toCurrency.code,
      ),
    );
    if (picked == null) return;
    setState(() {
      _fromCurrency = picked;
      if (_toCurrency.code == picked.code) {
        _toCurrency = _currencies.firstWhere((c) => c.code != picked.code);
      }
    });
  }

  Future<void> _pickToCurrency() async {
    final picked = await showModalBottomSheet<TransferCurrency>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _CurrencyPickerSheet(
        title: 'Convert to',
        currencies: _currencies,
        selected: _toCurrency,
        excludeCode: _fromCurrency.code,
      ),
    );
    if (picked != null) setState(() => _toCurrency = picked);
  }

  Future<void> _onContinueTap() async {
    if (!_canContinue) return;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ReviewConversionSheet(
        fromCurrency: _fromCurrency,
        toCurrency: _toCurrency,
        fromAmount: _fromAmount,
        fee: _fee,
        netFromAmount: _netFromAmount,
        toAmount: _toAmount,
        rate: _rate,
      ),
    );
    if (confirmed != true || !mounted) return;

    final authorized = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _AuthorizeConversionSheet(),
    );
    if (authorized != true || !mounted) return;

    _showConversionSuccessDialog();
  }

  void _showConversionSuccessDialog() {
    final fromCurrency = _fromCurrency;
    final toCurrency = _toCurrency;
    final fromAmount = _fromAmount;
    final toAmount = _toAmount;
    _fromAmountController.clear();

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
                'Conversion successful',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                '${fromCurrency.symbol}${formatAmount(fromAmount)} ${fromCurrency.code} was converted to '
                '${toCurrency.symbol}${formatAmount(toAmount)} ${toCurrency.code}.',
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
                    // ----- From / To stacked cards with swap button -----
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          children: [
                            _buildCurrencyPanel(
                              label: 'From',
                              currency: _fromCurrency,
                              onCurrencyTap: _pickFromCurrency,
                              controller: _fromAmountController,
                              isEditable: true,
                            ),
                            const SizedBox(height: 12),
                            _buildToPanel(),
                          ],
                        ),
                        _buildSwapButton(),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildRateInfo(),

                    if (_exceedsBalance) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'Insufficient balance',
                        style: TextStyle(color: AppColors.danger, fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                    ],
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
                  onPressed: _canContinue ? _onContinueTap : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    disabledBackgroundColor: AppColors.surface,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: AppColors.textMuted,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
            'Convert',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 19, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyPanel({
    required String label,
    required TransferCurrency currency,
    required VoidCallback onCurrencyTap,
    required TextEditingController controller,
    required bool isEditable,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.outlineBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(
                'Balance: ${currency.symbol}${formatAmount(currency.balance)}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              InkWell(
                onTap: onCurrencyTap,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.outlineBorder, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(currency.flag, style: const TextStyle(fontSize: 17)),
                      const SizedBox(width: 6),
                      Text(currency.code, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 2),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: isEditable,
                  textAlign: TextAlign.right,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800),
                  cursorColor: AppColors.primaryBlue,
                  decoration: const InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 24, fontWeight: FontWeight.w800),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.outlineBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('To', style: TextStyle(color: AppColors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(
                'Balance: ${_toCurrency.symbol}${formatAmount(_toCurrency.balance)}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              InkWell(
                onTap: _pickToCurrency,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.outlineBorder, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_toCurrency.flag, style: const TextStyle(fontSize: 17)),
                      const SizedBox(width: 6),
                      Text(_toCurrency.code, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 2),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _fromAmount > 0 ? formatAmount(_toAmount) : '0',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: _fromAmount > 0 ? AppColors.textPrimary : AppColors.textMuted,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwapButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _onSwapTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryBlue, AppColors.primaryBlueLight],
            ),
            border: Border.all(color: AppColors.background, width: 4),
            boxShadow: [
              BoxShadow(color: AppColors.primaryBlue.withOpacity(0.4), blurRadius: 14, spreadRadius: 1),
            ],
          ),
          child: AnimatedBuilder(
            animation: _swapController,
            builder: (context, child) => Transform.rotate(
              angle: _swapController.value * 3.14159,
              child: child,
            ),
            child: const Icon(Icons.swap_vert_rounded, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildRateInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineBorder, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.sync_rounded, color: AppColors.primaryBlueLight, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '1 ${_fromCurrency.code} = ${_rate.toStringAsFixed(_rate < 1 ? 4 : 2)} ${_toCurrency.code}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
          const Text(
            'Rate updates every 30s',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _CurrencyPickerSheet extends StatelessWidget {
  final String title;
  final List<TransferCurrency> currencies;
  final TransferCurrency selected;
  final String excludeCode;

  const _CurrencyPickerSheet({
    required this.title,
    required this.currencies,
    required this.selected,
    required this.excludeCode,
  });

  @override
  Widget build(BuildContext context) {
    final available = currencies.where((c) => c.code != excludeCode).toList();

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
          Align(
            alignment: Alignment.centerLeft,
            child: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 16),
          ...available.map((currency) {
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

/// Slides up to review the conversion before authorizing it.
class _ReviewConversionSheet extends StatelessWidget {
  final TransferCurrency fromCurrency;
  final TransferCurrency toCurrency;
  final double fromAmount;
  final double fee;
  final double netFromAmount;
  final double toAmount;
  final double rate;

  const _ReviewConversionSheet({
    required this.fromCurrency,
    required this.toCurrency,
    required this.fromAmount,
    required this.fee,
    required this.netFromAmount,
    required this.toAmount,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
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
            'Review conversion',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),

          // Amount summary card.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
              ),
            ),
            child: Column(
              children: [
                Text(
                  '${fromCurrency.symbol}${formatAmount(fromAmount)} ${fromCurrency.code}',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Icon(Icons.arrow_downward_rounded, color: Colors.white.withOpacity(0.7), size: 18),
                ),
                Text(
                  '${toCurrency.symbol}${formatAmount(toAmount)} ${toCurrency.code}',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineBorder, width: 1),
            ),
            child: Column(
              children: [
                _ReviewRow(label: 'Exchange rate', value: '1 ${fromCurrency.code} = ${rate.toStringAsFixed(rate < 1 ? 4 : 2)} ${toCurrency.code}'),
                const SizedBox(height: 10),
                _ReviewRow(label: 'Fee', value: '${fromCurrency.symbol}${formatAmount(fee)}'),
                const SizedBox(height: 10),
                _ReviewRow(label: 'Amount converted', value: '${fromCurrency.symbol}${formatAmount(netFromAmount)}'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.outlineBorder, width: 1.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Change', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Confirm', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

/// Slides up to authorize the conversion with a 4-digit transaction PIN
/// — same pattern as [WithdrawScreen]'s inline authorization sheet.
class _AuthorizeConversionSheet extends StatefulWidget {
  const _AuthorizeConversionSheet();

  @override
  State<_AuthorizeConversionSheet> createState() => _AuthorizeConversionSheetState();
}

class _AuthorizeConversionSheetState extends State<_AuthorizeConversionSheet>
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
              'Authorize conversion',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              _errorText ?? 'Enter your PIN to confirm this conversion',
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
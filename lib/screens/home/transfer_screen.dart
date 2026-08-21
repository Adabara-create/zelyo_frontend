import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/models/transfer_models.dart';
import 'package:zelyo_1/providers/account_provider.dart';
import 'package:zelyo_1/widgets/recipient_confirm_sheet.dart';
import 'add_amount_screen.dart';

/// Entry point of the transfer flow: choose the currency to send from,
/// either type a recipient's account number (auto-detecting their bank)
/// or pick from recent recipients, then confirm before moving on to
/// [AddAmountScreen].
class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  static const int _accountNumberLength = 10;


  // TODO: replace with the user's real recent recipients.
  final List<Recipient> _recentRecipients = const [
    Recipient(name: 'David Eze', bankName: 'GTBank', accountNumber: '0123456789', avatarColor: AppColors.primaryBlue, initials: 'DE'),
    Recipient(name: 'Tomiwa Precious', bankName: 'Access Bank', accountNumber: '0234567891', avatarColor: Color(0xFF7C5CFC), initials: 'TP'),
    Recipient(name: 'Moyo Adebayo', bankName: 'Zenith Bank', accountNumber: '0345678912', avatarColor: Color(0xFF14B8A6), initials: 'MA'),
    Recipient(name: 'Rita Kalu', bankName: 'UBA', accountNumber: '0456789123', avatarColor: Color(0xFFF59E0B), initials: 'RK'),
    Recipient(name: 'Segun Peters', bankName: 'First Bank', accountNumber: '0567891234', avatarColor: Color(0xFFEC4899), initials: 'SP'),
  ];

  // Simulated bank list for manual account-number lookup.
  static const List<String> _sampleBanks = [
    'GTBank', 'Access Bank', 'Zenith Bank', 'UBA', 'First Bank', 'Kuda',
  ];

  String _selectedCurrencyCode = 'NGN';

  /// Always resolves the selected currency from Riverpod so its balance is
  /// always the latest value after a deposit, withdrawal, transfer, or
  /// conversion.
  TransferCurrency get _selectedCurrency {
    final accounts = ref.read(accountsProvider);
    return accounts.firstWhere((currency) => currency.code == _selectedCurrencyCode);
  }
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  Recipient? _detectedRecipient;
  bool _isDetecting = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _accountNumberController.addListener(_onAccountNumberChanged);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onAccountNumberChanged() {
    final value = _accountNumberController.text;
    if (value.length != _accountNumberLength) {
      if (_detectedRecipient != null || _isDetecting) {
        setState(() {
          _detectedRecipient = null;
          _isDetecting = false;
        });
      }
      return;
    }

    setState(() {
      _isDetecting = true;
      _detectedRecipient = null;
    });

    // TODO: replace with a real account-resolve API call (e.g. NUBAN
    // lookup) — this just simulates a network delay and picks a sample
    // bank/name so the flow is demonstrable end to end.
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted || _accountNumberController.text != value) return;
      final bankIndex = value.codeUnits.fold<int>(0, (sum, c) => sum + c) % _sampleBanks.length;
      setState(() {
        _isDetecting = false;
        _detectedRecipient = Recipient(
          name: 'Chinedu Okafor',
          bankName: _sampleBanks[bankIndex],
          accountNumber: value,
          avatarColor: AppColors.primaryBlueLight,
          initials: 'CO',
        );
      });
    });
  }

  Future<void> _pickCurrency() async {
    final picked = await showModalBottomSheet<TransferCurrency>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _CurrencyPickerSheet(
        currencies: ref.read(accountsProvider),
        selected: _selectedCurrency,
      ),
    );
    if (picked != null) setState(() => _selectedCurrencyCode = picked.code);
  }

  Future<void> _searchOtherBanks() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _BankPickerSheet(banks: _sampleBanks),
    );
    if (picked == null || _detectedRecipient == null) return;
    setState(() {
      _detectedRecipient = Recipient(
        name: _detectedRecipient!.name,
        bankName: picked,
        accountNumber: _detectedRecipient!.accountNumber,
        avatarColor: _detectedRecipient!.avatarColor,
        initials: _detectedRecipient!.initials,
      );
    });
  }

  Future<void> _confirmRecipient(Recipient recipient) async {
    final confirmed = await showRecipientConfirmSheet(context, recipient: recipient);
    if (confirmed != true || !mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddAmountScreen(
          transfer: TransferRequest(currency: _selectedCurrency, recipient: recipient),
        ),
      ),
    );
  }

  List<Recipient> get _filteredRecipients {
    if (_searchQuery.isEmpty) return _recentRecipients;
    return _recentRecipients
        .where((r) =>
            r.name.toLowerCase().contains(_searchQuery) ||
            r.bankName.toLowerCase().contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the shared wallet state so this screen rebuilds when any other
    // wallet screen changes a balance.
    ref.watch(accountsProvider);

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
                    _buildAccountNumberField(),
                    if (_isDetecting || _detectedRecipient != null) ...[
                      const SizedBox(height: 12),
                      _buildDetectedBankCard(),
                    ],
                    const SizedBox(height: 28),
                    const Text(
                      'Select recipient',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRecipientsCard(),
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
            'Transfer',
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
                    'Transfer from',
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

  Widget _buildAccountNumberField() {
    return TextField(
      controller: _accountNumberController,
      keyboardType: TextInputType.number,
      maxLength: _accountNumberLength,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      cursorColor: AppColors.primaryBlue,
      decoration: InputDecoration(
        hintText: 'Recipient account number',
        counterText: '',
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14.5),
        prefixIcon: const Icon(Icons.tag_rounded, color: AppColors.textMuted, size: 20),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.outlineBorder, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.outlineBorder, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.6),
        ),
      ),
    );
  }

  Widget _buildDetectedBankCard() {
    if (_isDetecting) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineBorder, width: 1),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
            ),
            SizedBox(width: 12),
            Text('Looking up account...', style: TextStyle(color: AppColors.textMuted, fontSize: 13.5)),
          ],
        ),
      );
    }

    final recipient = _detectedRecipient!;
    return InkWell(
      onTap: () => _confirmRecipient(recipient),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.35), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryBlue.withOpacity(0.14)),
              child: const Icon(Icons.account_balance_rounded, color: AppColors.primaryBlueLight, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          recipient.name,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(recipient.bankName, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            TextButton(
              onPressed: _searchOtherBanks,
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
              child: const Text(
                'Wrong bank?',
                style: TextStyle(color: AppColors.primaryBlue, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.outlineBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 19),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5),
                          cursorColor: AppColors.primaryBlue,
                          decoration: const InputDecoration(
                            hintText: 'Search previous accounts',
                            hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13.5),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () {
                  // TODO: navigate to a full recipients/beneficiaries list.
                },
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                child: const Text(
                  'View all',
                  style: TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_filteredRecipients.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No matching accounts',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...List.generate(_filteredRecipients.length, (index) {
              final recipient = _filteredRecipients[index];
              final isLast = index == _filteredRecipients.length - 1;
              return Column(
                children: [
                  _RecipientRow(recipient: recipient, onTap: () => _confirmRecipient(recipient)),
                  if (!isLast) const Divider(color: AppColors.outlineBorder, height: 20),
                ],
              );
            }),
        ],
      ),
    );
  }
}

class _RecipientRow extends StatelessWidget {
  final Recipient recipient;
  final VoidCallback onTap;

  const _RecipientRow({required this.recipient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: recipient.avatarColor.withOpacity(0.2),
            child: Text(
              recipient.initials,
              style: TextStyle(color: recipient.avatarColor, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipient.name,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${recipient.bankName} • ${recipient.accountNumber}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
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
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: AppColors.outlineBorder, borderRadius: BorderRadius.circular(4)),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Transfer from', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
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

class _BankPickerSheet extends StatelessWidget {
  final List<String> banks;

  const _BankPickerSheet({required this.banks});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: AppColors.outlineBorder, borderRadius: BorderRadius.circular(4)),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Search other banks', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: banks.length,
                separatorBuilder: (context, index) => const Divider(color: AppColors.outlineBorder, height: 1),
                itemBuilder: (context, index) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.account_balance_rounded, color: AppColors.primaryBlueLight),
                  title: Text(banks[index], style: const TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.w600)),
                  onTap: () => Navigator.of(context).pop(banks[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/models/transfer_models.dart';
import 'package:zelyo_1/providers/account_provider.dart';
import 'authorize_transaction_screen.dart';

/// Final review before payment: full transfer details, a narration
/// field, and a fee/total breakdown, ending in the "Pay" button that
/// hands off to [AuthorizeTransactionScreen].
class ReviewTransferScreen extends ConsumerStatefulWidget {
  final TransferRequest transfer;

  const ReviewTransferScreen({super.key, required this.transfer});

  @override
  ConsumerState<ReviewTransferScreen> createState() => _ReviewTransferScreenState();
}

class _ReviewTransferScreenState extends ConsumerState<ReviewTransferScreen> {
  // TODO: replace with the signed-in user's real name/account details.
  static const String _userName = 'Amara Johnson';
  static const String _userAccountNumber = '2203 4471 902';

  static const List<String> _narrationSuggestions = [
    'Family', 'Food', 'Rent', 'Business', 'Gift', 'Other',
  ];

  final TextEditingController _narrationController = TextEditingController();

  /// Always reads the latest account from Riverpod so the review screen
  /// stays connected to the shared wallet state.
  TransferCurrency get _currentCurrency {
    return ref.watch(accountByCodeProvider(widget.transfer.currency.code));
  }

  @override
  void dispose() {
    _narrationController.dispose();
    super.dispose();
  }

  void _onPayTap() {
    final currency = _currentCurrency;

    final finalTransfer = widget.transfer.copyWith(
      currency: currency,
      narration: _narrationController.text.trim(),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AuthorizeTransactionScreen(transfer: finalTransfer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transfer = widget.transfer;
    final currency = _currentCurrency;
    final recipient = transfer.recipient;

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
                    // ----- Amount + recipient summary -----
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${currency.symbol}${formatAmount(transfer.amount)}',
                            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'to ${recipient.name}',
                            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13.5, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${recipient.bankName} • ${recipient.accountNumber}',
                            style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ----- Paying from -----
                    const Text(
                      'Paying from',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
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
                            width: 42, height: 42,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryBlue),
                            child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(_userName, style: TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(_userAccountNumber, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.14), borderRadius: BorderRadius.circular(999)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(currency.flag, style: const TextStyle(fontSize: 13)),
                                const SizedBox(width: 5),
                                Text(currency.code, style: const TextStyle(color: AppColors.primaryBlueLight, fontSize: 12, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ----- Narration -----
                    const Text(
                      'Narration',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.outlineBorder, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _narrationController,
                            maxLength: 60,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                            cursorColor: AppColors.primaryBlue,
                            decoration: const InputDecoration(
                              hintText: "What's this for?",
                              hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                              border: InputBorder.none,
                              counterText: '',
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _narrationSuggestions
                                .map((label) => _NarrationChip(
                                      label: label,
                                      onTap: () => setState(() => _narrationController.text = label),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ----- Fee breakdown -----
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.outlineBorder, width: 1),
                      ),
                      child: Column(
                        children: [
                          _SummaryRow(label: 'Transfer amount', value: '${currency.symbol}${formatAmount(transfer.amount)}'),
                          const SizedBox(height: 12),
                          _SummaryRow(label: 'Fee', value: '${currency.symbol}${formatAmount(transfer.fee)}'),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: AppColors.outlineBorder, height: 1),
                          ),
                          _SummaryRow(
                            label: 'Total',
                            value: '${currency.symbol}${formatAmount(transfer.total)}',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ----- Pay button -----
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onPayTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Pay ${currency.symbol}${formatAmount(transfer.total)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
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
            'Review transfer',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 19, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _NarrationChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NarrationChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.outlineBorder, width: 1),
        ),
        child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
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

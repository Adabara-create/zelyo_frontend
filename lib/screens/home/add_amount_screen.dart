import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/models/transfer_models.dart';
import 'package:zelyo_1/widgets/recipient_confirm_sheet.dart';
import 'review_transfer_screen.dart';

/// Second step of the transfer flow — enter how much to send, shown
/// alongside who it's going to and which of the user's accounts it's
/// coming from.
class AddAmountScreen extends StatefulWidget {
  final TransferRequest transfer;

  const AddAmountScreen({super.key, required this.transfer});

  @override
  State<AddAmountScreen> createState() => _AddAmountScreenState();
}

class _AddAmountScreenState extends State<AddAmountScreen> {
  // TODO: replace with the signed-in user's real name/account details.
  static const String _userName = 'Amara Johnson';
  static const String _userAccountNumber = '2203 4471 902';

  final TextEditingController _amountController = TextEditingController();
  double _amount = 0;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      setState(() => _amount = double.tryParse(_amountController.text) ?? 0);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  bool get _exceedsBalance => _amount > widget.transfer.currency.balance;

  Future<void> _onContinueTap() async {
    if (_amount <= 0 || _exceedsBalance) return;

    final confirmed = await showRecipientConfirmSheet(
      context,
      recipient: widget.transfer.recipient,
      title: 'Please double check and make sure\nthis is the right recipient',
      confirmLabel: 'Confirm',
    );
    if (confirmed != true || !mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReviewTransferScreen(
          transfer: widget.transfer.copyWith(amount: _amount),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipient = widget.transfer.recipient;
    final currency = widget.transfer.currency;

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
                    // ----- To -----
                    const Text(
                      'To',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Row(
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
                              Text(recipient.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(recipient.bankName, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ----- Amount input -----
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'Add amount',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          IntrinsicWidth(
                            child: TextField(
                              controller: _amountController,
                              autofocus: true,
                              textAlign: TextAlign.center,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                              ),
                              cursorColor: AppColors.primaryBlue,
                              decoration: InputDecoration(
                                prefixText: '${currency.symbol} ',
                                prefixStyle: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                ),
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
                                : 'Available: ${currency.symbol}${formatAmount(currency.balance)}',
                            style: TextStyle(
                              color: _exceedsBalance ? AppColors.danger : AppColors.textMuted,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

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
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
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
                  ],
                ),
              ),
            ),
            SizedBox(height: 10 + MediaQuery.of(context).padding.bottom),

            // ----- Continue -----
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_amount > 0 && !_exceedsBalance) ? _onContinueTap : null,
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
            'Add amount',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 19, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
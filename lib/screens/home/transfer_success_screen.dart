import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/models/transfer_models.dart';
import 'package:zelyo_1/providers/account_provider.dart';
import 'package:zelyo_1/screens/home/home_shell.dart';

/// Shown once a transfer's PIN authorization succeeds. Summarizes the
/// completed transfer and offers to share a receipt or return home.
class TransferSuccessScreen extends ConsumerStatefulWidget {
  final TransferRequest transfer;

  const TransferSuccessScreen({
    super.key,
    required this.transfer,
  });

  @override
  ConsumerState<TransferSuccessScreen> createState() =>
      _TransferSuccessScreenState();
}

class _TransferSuccessScreenState
    extends ConsumerState<TransferSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;
  late final String _reference;
  late final DateTime _completedAt;

  bool _balanceUpdated = false;

  @override
  void initState() {
    super.initState();

    _completedAt = DateTime.now();

    _reference =
        'ZLY${_completedAt.millisecondsSinceEpoch.toString().substring(4)}';

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.4, end: 1.12).chain(
          CurveTween(
            curve: Curves.easeOut,
          ),
        ),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.12, end: 1.0).chain(
          CurveTween(
            curve: Curves.easeInOut,
          ),
        ),
        weight: 35,
      ),
    ]).animate(_scaleController);

    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    final hour =
        dt.hour % 12 == 0 ? 12 : dt.hour % 12;

    final minute =
        dt.minute.toString().padLeft(2, '0');

    final period =
        dt.hour < 12 ? 'AM' : 'PM';

    return '${dt.day}/${dt.month}/${dt.year} • '
        '$hour:$minute $period';
  }

  void _onShareReceiptTap() {
    // TODO: generate and share a real receipt (image/PDF) via share_plus
    // or similar, using the transfer details below.
  }

  void _onDoneTap() {
    // ---------------------------------------------------------------
    // UPDATE WALLET HERE
    //
    // This is a button callback, so changing the provider is safe.
    // It is NOT being done in build() or initState().
    // ---------------------------------------------------------------
    if (!_balanceUpdated) {
      ref.read(accountsProvider.notifier).adjustBalance(
            code: widget.transfer.currency.code,
            delta: -widget.transfer.total,
          );

      _balanceUpdated = true;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const HomeShell(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final transfer = widget.transfer;
    final currency = transfer.currency;
    final recipient = transfer.recipient;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: Column(
            children: [
              const Spacer(flex: 2),

              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success.withOpacity(0.15),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.success,
                    size: 52,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Transfer successful',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '${currency.symbol}'
                '${formatAmount(transfer.amount)} '
                'was sent to ${recipient.name}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const Spacer(flex: 2),

              // ----- Summary card -----
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.outlineBorder,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _ReceiptRow(
                      label: 'Recipient',
                      value: recipient.name,
                    ),
                    const _ReceiptDivider(),

                    _ReceiptRow(
                      label: 'Bank',
                      value: recipient.bankName,
                    ),
                    const _ReceiptDivider(),

                    _ReceiptRow(
                      label: 'Account number',
                      value: recipient.accountNumber,
                    ),
                    const _ReceiptDivider(),

                    _ReceiptRow(
                      label: 'Amount',
                      value:
                          '${currency.symbol}'
                          '${formatAmount(transfer.amount)}',
                    ),
                    const _ReceiptDivider(),

                    _ReceiptRow(
                      label: 'Fee',
                      value:
                          '${currency.symbol}'
                          '${formatAmount(transfer.fee)}',
                    ),
                    const _ReceiptDivider(),

                    _ReceiptRow(
                      label: 'Total',
                      value:
                          '${currency.symbol}'
                          '${formatAmount(transfer.total)}',
                      emphasize: true,
                    ),
                    const _ReceiptDivider(),

                    _ReceiptRow(
                      label: 'Date',
                      value:
                          _formatDateTime(_completedAt),
                    ),
                    const _ReceiptDivider(),

                    _ReceiptRow(
                      label: 'Reference',
                      value: _reference,
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // ----- Bottom actions -----
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: _onShareReceiptTap,
                        icon: const Icon(
                          Icons.ios_share_rounded,
                          size: 18,
                        ),
                        label: const Text(
                          'Share receipt',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              AppColors.textPrimary,
                          side: const BorderSide(
                            color: AppColors.outlineBorder,
                            width: 1.4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _onDoneTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _ReceiptRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: emphasize ? 15 : 13.5,
                fontWeight: emphasize
                    ? FontWeight.w800
                    : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptDivider extends StatelessWidget {
  const _ReceiptDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: AppColors.outlineBorder,
      height: 1,
    );
  }
}
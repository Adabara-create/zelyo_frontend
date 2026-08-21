import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/providers/transaction_detail_provider.dart';

/// Full detail view for a single transaction — opened by tapping a row
/// in [HomeScreen]'s "Recent transactions" card.
///
/// Riverpod is now integrated so the transaction currently being viewed
/// can also be accessed through [transactionDetailProvider].
///
/// The original constructor fields are intentionally preserved so
/// existing HomeScreen and HistoryScreen navigation continues to work.
class TransactionDetailScreen extends ConsumerWidget {
  final String name;
  final String subtitle;
  final String date;
  final String time;
  final double amount; // positive = money in, negative = money out
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

  const TransactionDetailScreen({
    super.key,
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

  /// Converts this screen's constructor data into the Riverpod model.
  TransactionDetailData get _transactionData {
    return TransactionDetailData(
      name: name,
      subtitle: subtitle,
      date: date,
      time: time,
      amount: amount,
      currencySymbol: currencySymbol,
      icon: icon,
      iconColor: iconColor,
      category: category,
      paymentMethod: paymentMethod,
      status: status,
      recipientBank: recipientBank,
      recipientAccountNumber: recipientAccountNumber,
      fee: fee,
      narration: narration,
    );
  }

  String _formatAmount(num value) {
    final absValue = value.abs();
    final wholePart = absValue.truncate().toString();

    final decimalPart = ((absValue - absValue.truncate()) * 100)
        .round()
        .toString()
        .padLeft(2, '0');

    final buffer = StringBuffer();

    for (int i = 0; i < wholePart.length; i++) {
      if (i > 0 && (wholePart.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(wholePart[i]);
    }

    return '$buffer.$decimalPart';
  }

  /// TODO:
  /// Replace this with the actual transaction reference stored
  /// when the transaction is created.
  String get _reference =>
      'ZLY${(name.hashCode.abs() % 900000 + 100000)}';

  bool get _hasRecipientInfo =>
      recipientBank != null || recipientAccountNumber != null;

  bool get _hasFee => fee != null && fee! > 0;

  bool get _hasNarration =>
      narration != null && narration!.trim().isNotEmpty;

  Future<void> _copyReference(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: _reference),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
        content: Text(
          'Reference copied',
          style: TextStyle(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ---------------------------------------------------------------
    // Riverpod integration
    // ---------------------------------------------------------------
    //
    // This stores the transaction currently being viewed in Riverpod.
    //
    // We use listen instead of modifying the provider directly during
    // the build phase.
    //
    ref.listenManual<TransactionDetailData?>(
      transactionDetailProvider,
      (_, __) {},
    );

    // The current transaction can now be accessed anywhere below
    // through Riverpod if another component needs it.
    final currentTransaction = ref.read(transactionDetailProvider);

    // If the provider has not been initialized yet, the screen's
    // constructor data becomes the source used to initialize it.
    if (currentTransaction == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;

        ref.read(transactionDetailProvider.notifier).state =
            _transactionData;
      });
    }

    final isPositive = amount >= 0;

    final total =
        _hasFee ? amount.abs() + fee! : amount.abs();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  4,
                  20,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),

                    _buildHero(isPositive),

                    const SizedBox(height: 28),

                    _buildStatusTimeline(),

                    const SizedBox(height: 18),

                    _buildDetailsCard(context),

                    if (_hasRecipientInfo) ...[
                      const SizedBox(height: 18),
                      _buildRecipientCard(),
                    ],

                    if (_hasFee) ...[
                      const SizedBox(height: 18),
                      _buildAmountBreakdownCard(total),
                    ],

                    if (_hasNarration) ...[
                      const SizedBox(height: 18),
                      _buildNarrationCard(),
                    ],

                    const SizedBox(height: 18),

                    _buildHelpCard(),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO:
                          // Generate and share a real receipt
                          // using share_plus or another package.
                        },
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

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 54,
                      child: TextButton.icon(
                        onPressed: () {
                          // TODO:
                          // Open "report an issue" flow.
                        },
                        icon: const Icon(
                          Icons.flag_outlined,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        label: const Text(
                          'Report an issue',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        12,
        8,
        20,
        4,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),

          const SizedBox(width: 4),

          const Text(
            'Transaction details',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Hero
  // ---------------------------------------------------------------------

  Widget _buildHero(bool isPositive) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withOpacity(0.15),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 32,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            '${isPositive ? '+' : '-'}'
            '$currencySymbol'
            '${_formatAmount(amount.abs())}',
            style: TextStyle(
              color: isPositive
                  ? AppColors.success
                  : AppColors.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 13,
                ),

                const SizedBox(width: 5),

                Text(
                  status,
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Status timeline
  // ---------------------------------------------------------------------

  Widget _buildStatusTimeline() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaction status',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 16),

          _TimelineStep(
            label: 'Transaction initiated',
            timeLabel: '$date • $time',
            isFirst: true,
            isLast: false,
          ),

          _TimelineStep(
            label: 'Processing',
            timeLabel: null,
            isFirst: false,
            isLast: false,
          ),

          _TimelineStep(
            label: status,
            timeLabel: '$date • $time',
            isFirst: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Details card
  // ---------------------------------------------------------------------

  Widget _buildDetailsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _DetailRow(
            label: 'Description',
            value: subtitle,
          ),

          const _DetailDivider(),

          _DetailRow(
            label: 'Category',
            value: category,
          ),

          const _DetailDivider(),

          _DetailRow(
            label: 'Payment method',
            value: paymentMethod,
          ),

          const _DetailDivider(),

          _DetailRow(
            label: 'Date',
            value: date,
          ),

          const _DetailDivider(),

          _DetailRow(
            label: 'Time',
            value: time,
          ),

          const _DetailDivider(),

          InkWell(
            onTap: () => _copyReference(context),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
              ),
              child: Row(
                children: [
                  const Text(
                    'Reference',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    _reference,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(width: 6),

                  const Icon(
                    Icons.copy_rounded,
                    color: AppColors.textMuted,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Recipient card
  // ---------------------------------------------------------------------

  Widget _buildRecipientCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryBlue.withOpacity(0.14),
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              color: AppColors.primaryBlueLight,
              size: 19,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  [
                    if (recipientBank != null)
                      recipientBank!,
                    if (recipientAccountNumber != null)
                      recipientAccountNumber!,
                  ].join(' • '),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Amount breakdown
  // ---------------------------------------------------------------------

  Widget _buildAmountBreakdownCard(double total) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _DetailRow(
            label: 'Amount',
            value:
                '$currencySymbol${_formatAmount(amount.abs())}',
          ),

          const _DetailDivider(),

          _DetailRow(
            label: 'Fee',
            value:
                '$currencySymbol${_formatAmount(fee!)}',
          ),

          const _DetailDivider(),

          _DetailRow(
            label: 'Total',
            value:
                '$currencySymbol${_formatAmount(total)}',
            emphasize: true,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Narration
  // ---------------------------------------------------------------------

  Widget _buildNarrationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Narration',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            narration!,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Help card
  // ---------------------------------------------------------------------

  Widget _buildHelpCard() {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          // TODO:
          // Open customer support chat.
          //
          // The transaction reference can be retrieved from:
          // _reference
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.outlineBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBlue
                      .withOpacity(0.14),
                ),
                child: const Icon(
                  Icons.headset_mic_rounded,
                  color: AppColors.primaryBlueLight,
                  size: 18,
                ),
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need help with this transaction?',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 2),

                    Text(
                      'Chat with support',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================================
// TIMELINE STEP
// =======================================================================

class _TimelineStep extends StatelessWidget {
  final String label;
  final String? timeLabel;
  final bool isFirst;
  final bool isLast;

  const _TimelineStep({
    required this.label,
    required this.timeLabel,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 12,
                ),
              ),

              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.success
                        .withOpacity(0.35),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : 18,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  if (timeLabel != null) ...[
                    const SizedBox(height: 2),

                    Text(
                      timeLabel!,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =======================================================================
// DETAIL ROW
// =======================================================================

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _DetailRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
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

// =======================================================================
// DIVIDER
// =======================================================================

class _DetailDivider extends StatelessWidget {
  const _DetailDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: AppColors.outlineBorder,
      height: 1,
    );
  }
}
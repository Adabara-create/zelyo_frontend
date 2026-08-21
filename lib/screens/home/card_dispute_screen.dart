import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/providers/card_disputes_provider.dart';

/// Shows the user's card disputes.
class CardDisputesScreen extends ConsumerWidget {
  const CardDisputesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disputeState = ref.watch(cardDisputesProvider);
    final disputes = disputeState.disputes;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: disputes.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        8,
                        20,
                        24,
                      ),
                      itemCount: disputes.length,
                      separatorBuilder:
                          (context, index) =>
                              const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _DisputeCard(
                        dispute: disputes[index],
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
            'Disputes',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 40,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue
                    .withOpacity(0.12),
              ),
              child: const Icon(
                Icons.fact_check_outlined,
                color: AppColors.primaryBlueLight,
                size: 38,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No disputes',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "If you spot a transaction on your card you don't recognize, you can dispute it from the transaction's details.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisputeCard extends StatelessWidget {
  final Dispute dispute;

  const _DisputeCard({
    required this.dispute,
  });

  @override
  Widget build(BuildContext context) {
    final isResolved =
        dispute.status == DisputeStatus.resolved;

    final statusColor = isResolved
        ? AppColors.success
        : const Color(0xFFF59E0B);

    final statusIcon = isResolved
        ? Icons.check_circle_rounded
        : Icons.hourglass_top_rounded;

    final statusLabel =
        isResolved ? 'Resolved' : 'Investigating';

    return Container(
      padding: const EdgeInsets.all(16),
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
              color: statusColor.withOpacity(0.15),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
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
                  dispute.transactionName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 3),

                Text(
                  '${dispute.amount} • '
                  '${dispute.dateFiled}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.14),
              borderRadius:
                  BorderRadius.circular(999),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
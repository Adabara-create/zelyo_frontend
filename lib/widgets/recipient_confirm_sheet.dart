import 'package:flutter/material.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/models/transfer_models.dart';

/// Slides up from the bottom to confirm a recipient — used twice in the
/// transfer flow: once right after picking/resolving a recipient, and
/// again as a "double check" step right before submitting the transfer.
/// Same design both times, different [title]/[confirmLabel].
///
/// Returns `true` if the user tapped Confirm, `false`/`null` otherwise
/// (dismissed or tapped Change).
Future<bool?> showRecipientConfirmSheet(
  BuildContext context, {
  required Recipient recipient,
  String title = 'Confirm if this is the right person',
  String confirmLabel = 'Confirm',
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => _RecipientConfirmSheet(
      recipient: recipient,
      title: title,
      confirmLabel: confirmLabel,
    ),
  );
}

class _RecipientConfirmSheet extends StatelessWidget {
  final Recipient recipient;
  final String title;
  final String confirmLabel;

  const _RecipientConfirmSheet({
    required this.recipient,
    required this.title,
    required this.confirmLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle.
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.outlineBorder,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 20),

            // ----- Recipient card -----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.outlineBorder, width: 1),
              ),
              child: Column(
                children: [
                  // Bank logo.
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryBlue.withOpacity(0.14),
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      color: AppColors.primaryBlueLight,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    recipient.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recipient.bankName,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    recipient.accountNumber,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ----- Change / Confirm -----
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
                      child: const Text(
                        'Change',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
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
                      child: Text(
                        confirmLabel,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
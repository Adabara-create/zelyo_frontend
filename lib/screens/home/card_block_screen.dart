import 'package:flutter/material.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'verify_transaction_pin_screen.dart';

/// Asks why the user wants to block their card, verifies their PIN,
/// then confirms the block. Pops `true` if the card ends up blocked.
class CardBlockScreen extends StatefulWidget {
  const CardBlockScreen({super.key});

  @override
  State<CardBlockScreen> createState() => _CardBlockScreenState();
}

class _CardBlockScreenState extends State<CardBlockScreen> {
  static const List<String> _reasons = [
    'Lost or stolen',
    'Suspicious activity detected',
    'No longer need this card',
    'Found a better alternative',
    'Other reason',
  ];

  int? _selectedReasonIndex;

  Future<void> _onContinueTap() async {
    if (_selectedReasonIndex == null) return;

    final verified = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const VerifyTransactionPinScreen(
          purpose: 'Enter your PIN to confirm blocking this card',
        ),
      ),
    );
    if (verified != true || !mounted) return;

    await _showBlockedDialog();
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _showBlockedDialog() {
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
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.danger.withOpacity(0.15)),
                child: const Icon(Icons.block_rounded, color: AppColors.danger, size: 34),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your virtual card has been blocked',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'No new transactions can be made with this card until you unblock it from card settings.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 13.5, height: 1.5),
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
                    const Text(
                      'Why do you want to block\nyour virtual card?',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w800, height: 1.3),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This helps us keep your account secure.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13.5),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.outlineBorder, width: 1),
                      ),
                      child: Column(
                        children: List.generate(_reasons.length, (index) {
                          final isLast = index == _reasons.length - 1;
                          final isSelected = _selectedReasonIndex == index;
                          return Column(
                            children: [
                              InkWell(
                                onTap: () => setState(() => _selectedReasonIndex = index),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected ? AppColors.primaryBlue : AppColors.outlineBorder,
                                            width: 1.6,
                                          ),
                                        ),
                                        child: isSelected
                                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 15)
                                            : null,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          _reasons[index],
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14.5,
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (!isLast)
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Divider(color: AppColors.outlineBorder, height: 1),
                                ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedReasonIndex != null ? _onContinueTap : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
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
            onPressed: () => Navigator.of(context).maybePop(false),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(width: 4),
          const Text('Block card', style: TextStyle(color: AppColors.textPrimary, fontSize: 19, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/models/card_models.dart';

/// Slides up after PIN verification to reveal full card details — name,
/// number, expiry, CVV — each individually copyable, with a currency
/// switcher across the top so the user can check any of their cards
/// without leaving the sheet.
Future<void> showCardDetailsSheet(
  BuildContext context, {
  required List<VirtualCardData> cards,
  int initialIndex = 0,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => _CardDetailsSheet(cards: cards, initialIndex: initialIndex),
  );
}

class _CardDetailsSheet extends StatefulWidget {
  final List<VirtualCardData> cards;
  final int initialIndex;

  const _CardDetailsSheet({required this.cards, required this.initialIndex});

  @override
  State<_CardDetailsSheet> createState() => _CardDetailsSheetState();
}

class _CardDetailsSheetState extends State<_CardDetailsSheet> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  Future<void> _copy(String value, String label) async {
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

  @override
  Widget build(BuildContext context) {
    final card = widget.cards[_selectedIndex];

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
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: AppColors.outlineBorder, borderRadius: BorderRadius.circular(4)),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Card details', style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 16),

            // ----- Currency switcher -----
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.cards.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedIndex;
                  final c = widget.cards[index];
                  return InkWell(
                    onTap: () => setState(() => _selectedIndex = index),
                    borderRadius: BorderRadius.circular(999),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryBlue : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: isSelected ? AppColors.primaryBlue : AppColors.outlineBorder, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(c.flag, style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 5),
                          Text(
                            c.code,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ----- Details -----
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.outlineBorder, width: 1),
              ),
              child: Column(
                children: [
                  _CopyableDetailRow(label: 'Cardholder name', value: card.holderName, onCopy: () => _copy(card.holderName, 'Name')),
                  const Divider(color: AppColors.outlineBorder, height: 22),
                  _CopyableDetailRow(label: 'Card number', value: card.fullNumber, onCopy: () => _copy(card.fullNumber.replaceAll(' ', ''), 'Card number')),
                  const Divider(color: AppColors.outlineBorder, height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _CopyableDetailRow(label: 'Expiry', value: card.expiry, onCopy: () => _copy(card.expiry, 'Expiry')),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _CopyableDetailRow(label: 'CVV', value: card.cvv, onCopy: () => _copy(card.cvv, 'CVV')),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.shield_outlined, color: AppColors.textMuted, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Never share these details with anyone, including Zelyo staff.',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Close', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CopyableDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCopy;

  const _CopyableDetailRow({required this.label, required this.value, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.4),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            InkWell(
              onTap: onCopy,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.copy_rounded, color: AppColors.primaryBlueLight, size: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
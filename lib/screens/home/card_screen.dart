import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/models/card_models.dart';
import 'package:zelyo_1/widgets/carousel_dots.dart';
import 'card_identity_verification_screen.dart';
import 'verify_transaction_pin_screen.dart';
import 'create_card_pin_screen.dart';
import 'card_detail_sheet_screen.dart';
import 'card_block_screen.dart';
import 'card_dispute_screen.dart';
import 'card_settings_screen.dart';

/// The Card tab — shows an intro/"open a card" state until the user
/// completes verification, then the real card carousel with actions
/// and transaction history. Both states live in one file/one widget,
/// since which one renders is just a matter of [_hasCard].
class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  bool _hasCard = false;
  bool _isCardBlocked = false;

  final PageController _cardController = PageController();
  int _activeCardIndex = 0;

  // TODO: replace with the user's real card transaction history —
  // empty is the correct starting state for a freshly issued card.
  final List<_CardTransaction> _transactions = const [];

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  Future<void> _onOpenCardTap() async {
    final identityVerified = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const CardIdentityVerificationScreen()),
    );
    if (identityVerified != true || !mounted) return;

    final pinVerified = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const VerifyTransactionPinScreen(
          purpose: 'Verify your PIN to open a virtual card',
        ),
      ),
    );
    if (pinVerified != true || !mounted) return;

    final cardPinCreated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const CreateCardPinScreen()),
    );
    if (cardPinCreated != true || !mounted) return;

    setState(() => _hasCard = true);
  }

  Future<void> _onDetailsTap() async {
    final verified = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const VerifyTransactionPinScreen(
          purpose: 'Enter your PIN to view your card details',
        ),
      ),
    );
    if (verified != true || !mounted) return;

    showCardDetailsSheet(context, cards: sampleVirtualCards, initialIndex: _activeCardIndex);
  }

  Future<void> _onBlockTap() async {
    final blocked = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const CardBlockScreen()),
    );
    if (blocked == true && mounted) setState(() => _isCardBlocked = true);
  }

  void _onDisputesTap() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CardDisputesScreen()),
    );
  }

  Future<void> _onSettingsTap() async {
    final deleted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const CardSettingsScreen()),
    );
    if (deleted == true && mounted) {
      setState(() {
        _hasCard = false;
        _isCardBlocked = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _hasCard ? _buildCardState() : _buildIntroState(),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Intro state: no card yet — a proper, lively landing page rather than
  // a single static promo box.
  // ---------------------------------------------------------------------
  Widget _buildIntroState() {
    return Stack(
      children: [
        // Soft ambient glow, same brand-orb language used across the app.
        Positioned(
          top: -120,
          right: -90,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue.withOpacity(0.18),
              ),
            ),
          ),
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Text(
                'Cards',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ----- Realistic card preview, tilted for a "floating" feel -----
                    Center(
                      child: Transform.rotate(
                        angle: -0.045,
                        child: _CardPreviewMock(),
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'Open a virtual card now',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Get instant access to secure online payments in any currency you hold — issued in seconds, free to open.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13.5, height: 1.5),
                    ),

                    const SizedBox(height: 28),

                    // ----- Benefits -----
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.outlineBorder, width: 1),
                      ),
                      child: Column(
                        children: const [
                          _BenefitRow(
                            icon: Icons.bolt_rounded,
                            iconColor: Color(0xFFF59E0B),
                            title: 'Instant issuance',
                            subtitle: 'Ready to use the moment verification is complete.',
                          ),
                          _BenefitDivider(),
                          _BenefitRow(
                            icon: Icons.public_rounded,
                            iconColor: AppColors.primaryBlueLight,
                            title: 'Every currency supported',
                            subtitle: 'One card per wallet — NGN, USD, EUR, GBP, and JPY.',
                          ),
                          _BenefitDivider(),
                          _BenefitRow(
                            icon: Icons.shield_outlined,
                            iconColor: Color(0xFF14B8A6),
                            title: 'Bank-grade security',
                            subtitle: 'Selfie verification, a dedicated card PIN, and one-tap blocking.',
                          ),
                          _BenefitDivider(),
                          _BenefitRow(
                            icon: Icons.savings_outlined,
                            iconColor: Color(0xFF7C5CFC),
                            title: 'No setup fees',
                            subtitle: 'Opening and holding a virtual card costs nothing.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ----- How it works -----
                    const Text(
                      'How it works',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 15.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.outlineBorder, width: 1),
                      ),
                      child: const Column(
                        children: [
                          _HowItWorksStep(number: '1', label: 'Verify it\'s you', description: 'A quick selfie and face scan.', isLast: false),
                          _HowItWorksStep(number: '2', label: 'Set a card PIN', description: 'A 4-digit PIN just for this card.', isLast: false),
                          _HowItWorksStep(number: '3', label: 'Start spending', description: 'Your card is ready immediately.', isLast: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        const Icon(Icons.lock_outline_rounded, color: AppColors.textMuted, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Protected with selfie verification and end-to-end encryption.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ----- Bottom action -----
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Column(
                children: [
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onOpenCardTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Open a virtual card', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Takes less than 2 minutes',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11.5, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Full state: card carousel + actions + transactions
  // ---------------------------------------------------------------------
  Widget _buildCardState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cards',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),

          if (_isCardBlocked) ...[
            _buildBlockedBanner(),
            const SizedBox(height: 16),
          ],

          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _cardController,
              itemCount: sampleVirtualCards.length,
              onPageChanged: (index) => setState(() => _activeCardIndex = index),
              itemBuilder: (context, index) => _VirtualCardWidget(
                card: sampleVirtualCards[index],
                isBlocked: _isCardBlocked,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: CarouselDots(itemCount: sampleVirtualCards.length, activeIndex: _activeCardIndex),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(child: _CardActionButton(icon: Icons.info_outline_rounded, label: 'Details', onTap: _onDetailsTap)),
              const SizedBox(width: 12),
              Expanded(child: _CardActionButton(icon: Icons.block_rounded, label: 'Block', onTap: _onBlockTap)),
              const SizedBox(width: 12),
              Expanded(child: _CardActionButton(icon: Icons.fact_check_outlined, label: 'Disputes', onTap: _onDisputesTap)),
              const SizedBox(width: 12),
              Expanded(child: _CardActionButton(icon: Icons.settings_outlined, label: 'Settings', onTap: _onSettingsTap)),
            ],
          ),

          const SizedBox(height: 28),

          const Text(
            'Card transactions',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),

          _transactions.isEmpty ? _buildEmptyTransactions() : _buildTransactionsCard(),
        ],
      ),
    );
  }

  Widget _buildBlockedBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.danger.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.block_rounded, color: AppColors.danger, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This card is blocked', style: TextStyle(color: AppColors.danger, fontSize: 13.5, fontWeight: FontWeight.w700)),
                SizedBox(height: 2),
                Text('Unblock it from Card settings to resume transactions.', style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineBorder, width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryBlue.withOpacity(0.12)),
            child: const Icon(Icons.receipt_long_rounded, color: AppColors.primaryBlueLight, size: 24),
          ),
          const SizedBox(height: 14),
          const Text('No transactions yet', style: TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Your card transactions will show up here.', style: TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
        ],
      ),
    );
  }

  Widget _buildTransactionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineBorder, width: 1),
      ),
      child: Column(
        children: List.generate(_transactions.length, (index) {
          final isLast = index == _transactions.length - 1;
          return Column(
            children: [
              _TransactionRow(transaction: _transactions[index]),
              if (!isLast) const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(color: AppColors.outlineBorder, height: 1)),
            ],
          );
        }),
      ),
    );
  }
}

// ===========================================================================
// Intro-state widgets
// ===========================================================================

/// A realistic-looking (but fully placeholder) card preview for the
/// intro screen — same gradient/pattern language as the real cards,
/// with masked fields since no card has actually been issued yet.
class _CardPreviewMock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 172,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
        ),
        boxShadow: [
          BoxShadow(color: AppColors.primaryBlue.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 16)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _CardPatternPainter(pattern: CardPattern.diagonalLines)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(999)),
                      child: const Text('Virtual card', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                    const Spacer(),
                    const Text('Zelyo', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.sim_card_rounded, color: Colors.white70, size: 26),
                const SizedBox(height: 10),
                const Text(
                  '•••• •••• •••• ••••',
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 1.4),
                ),
                const SizedBox(height: 6),
                Text(
                  'YOUR NAME HERE',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11.5, fontWeight: FontWeight.w600, letterSpacing: 0.6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _BenefitRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: iconColor.withOpacity(0.15)),
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitDivider extends StatelessWidget {
  const _BenefitDivider();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Divider(color: AppColors.outlineBorder, height: 1),
      );
}

class _HowItWorksStep extends StatelessWidget {
  final String number;
  final String label;
  final String description;
  final bool isLast;

  const _HowItWorksStep({
    required this.number,
    required this.label,
    required this.description,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryBlue),
                alignment: Alignment.center,
                child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w800)),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: AppColors.primaryBlue.withOpacity(0.25))),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(description, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Card transaction model + row (same visual pattern as HomeScreen's)
// ===========================================================================

class _CardTransaction {
  final String name;
  final String subtitle;
  final String date;
  final String time;
  final double amount;
  final String currencySymbol;
  final IconData icon;
  final Color iconColor;

  const _CardTransaction({
    required this.name,
    required this.subtitle,
    required this.date,
    required this.time,
    required this.amount,
    required this.currencySymbol,
    required this.icon,
    required this.iconColor,
  });
}

class _TransactionRow extends StatelessWidget {
  final _CardTransaction transaction;

  const _TransactionRow({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.amount >= 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(shape: BoxShape.circle, color: transaction.iconColor.withOpacity(0.15)),
            child: Icon(transaction.icon, color: transaction.iconColor, size: 19),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text('${transaction.subtitle} • ${transaction.date}, ${transaction.time}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : '-'}${transaction.currencySymbol}${transaction.amount.abs().toStringAsFixed(2)}',
            style: TextStyle(color: isPositive ? AppColors.success : AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Card action button (Details / Block / Disputes / Settings)
// ===========================================================================

class _CardActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CardActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.primaryBlue.withOpacity(0.12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outlineBorder, width: 1),
          ),
          child: Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.14), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: AppColors.primaryBlueLight, size: 19),
              ),
              const SizedBox(height: 10),
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Virtual card widget — gradient, decorative pattern, pill + Zelyo mark
// ===========================================================================

class _VirtualCardWidget extends StatelessWidget {
  final VirtualCardData card;
  final bool isBlocked;

  const _VirtualCardWidget({required this.card, required this.isBlocked});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: card.gradientColors,
          ),
          boxShadow: [
            BoxShadow(color: card.gradientColors.first.withOpacity(0.35), blurRadius: 22, offset: const Offset(0, 12)),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _CardPatternPainter(pattern: card.pattern)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(999)),
                      child: const Text('Virtual card', style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700)),
                    ),
                    const Spacer(),
                    const Text('Zelyo', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(card.flag, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(card.code, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  card.maskedNumber,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 1.4),
                ),
                const SizedBox(height: 6),
                Text(
                  card.holderName,
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12.5, fontWeight: FontWeight.w600, letterSpacing: 0.6),
                ),
              ],
            ),
            if (isBlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), borderRadius: BorderRadius.circular(26)),
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(999)),
                    child: const Text('BLOCKED', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Draws a subtle decorative texture behind each card's content, unique
/// per [CardPattern] so cards feel visually distinct beyond just color.
class _CardPatternPainter extends CustomPainter {
  final CardPattern pattern;

  _CardPatternPainter({required this.pattern});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final fillPaint = Paint()..color = Colors.white.withOpacity(0.07);

    switch (pattern) {
      case CardPattern.diagonalLines:
        for (double x = -size.height; x < size.width; x += 26) {
          canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), paint);
        }
        break;
      case CardPattern.dots:
        for (double y = 10; y < size.height; y += 26) {
          for (double x = 10; x < size.width; x += 26) {
            canvas.drawCircle(Offset(x, y), 2, fillPaint);
          }
        }
        break;
      case CardPattern.waves:
        for (int i = 0; i < 3; i++) {
          canvas.drawCircle(
            Offset(size.width * 0.8, size.height * 0.2 + i * 40),
            60 + i * 30,
            paint,
          );
        }
        break;
      case CardPattern.grid:
        for (double x = 0; x < size.width; x += 24) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
        }
        for (double y = 0; y < size.height; y += 24) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
        break;
      case CardPattern.rings:
        canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.15), 30, paint);
        canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.15), 55, paint);
        canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.15), 80, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _CardPatternPainter oldDelegate) => oldDelegate.pattern != pattern;
}
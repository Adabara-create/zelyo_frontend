import 'package:flutter/material.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'contact_support_screen.dart';

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}

/// Searchable FAQ list with an expandable accordion, plus a "still need
/// help" link into Contact support. Sub-screen of Profile — has a back
/// button.
class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  static const List<_FaqItem> _faqs = [
    _FaqItem(
      question: 'How do I open a virtual card?',
      answer: 'Go to the Card tab and tap "Open a virtual card." You\'ll verify your identity with a selfie and face scan, set a card PIN, and your card is ready instantly.',
    ),
    _FaqItem(
      question: 'How do I reset my transaction PIN?',
      answer: 'Go to Profile → Change transaction PIN. You\'ll need to verify your current PIN first, then set a new one.',
    ),
    _FaqItem(
      question: 'How long do deposits take to reflect?',
      answer: 'Bank transfers to your virtual account usually reflect within a few minutes. Card deposits are typically instant.',
    ),
    _FaqItem(
      question: 'What currencies does Zelyo support?',
      answer: 'You can hold and transact in NGN, USD, EUR, GBP, and JPY, with more currencies planned.',
    ),
    _FaqItem(
      question: 'How do I raise a dispute on a card transaction?',
      answer: 'Go to Card → Disputes to view and track any disputes you\'ve filed on card transactions.',
    ),
    _FaqItem(
      question: 'Is my money safe with Zelyo?',
      answer: 'Your funds are held with our licensed banking partners and protected with bank-grade encryption, biometric verification, and PIN-protected transactions.',
    ),
  ];

  String _query = '';
  int? _expandedIndex;

  List<_FaqItem> get _filtered {
    if (_query.isEmpty) return _faqs;
    return _faqs.where((f) => f.question.toLowerCase().contains(_query.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.outlineBorder, width: 1)),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 19),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        cursorColor: AppColors.primaryBlue,
                        decoration: const InputDecoration(hintText: 'Search for help', hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14), border: InputBorder.none, isDense: true),
                        onChanged: (value) => setState(() => _query = value),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  ..._filtered.asMap().entries.map((entry) {
                    final index = entry.key;
                    final faq = entry.value;
                    final isExpanded = _expandedIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.outlineBorder, width: 1),
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () => setState(() => _expandedIndex = isExpanded ? null : index),
                              borderRadius: BorderRadius.circular(18),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(faq.question, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                                    ),
                                    AnimatedRotation(
                                      turns: isExpanded ? 0.5 : 0,
                                      duration: const Duration(milliseconds: 200),
                                      child: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted, size: 22),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 200),
                              crossFadeState: isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                              firstChild: Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Text(faq.answer, style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5)),
                              ),
                              secondChild: const SizedBox(width: double.infinity),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(colors: [AppColors.primaryBlue, AppColors.primaryBlueDark]),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.18)),
                          child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 13),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Still need help?', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                              SizedBox(height: 2),
                              Text('Our support team is here for you.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const ContactSupportScreen()),
                          ),
                          style: TextButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.15), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                          child: const Text('Contact us', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                ],
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
          const Text('Help center', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
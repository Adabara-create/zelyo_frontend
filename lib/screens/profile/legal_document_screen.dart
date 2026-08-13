import 'package:flutter/material.dart';
import 'package:zelyo_1/theme/app_colors.dart';

class LegalSection {
  final String heading;
  final String body;

  const LegalSection({required this.heading, required this.body});
}

/// Generic scrollable legal-document layout — shared by
/// TermsOfServiceScreen and PrivacyPolicyScreen since they're
/// structurally identical (title, last-updated date, numbered
/// sections). Sub-screen of Profile — has a back button.
class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final String lastUpdated;
  final List<LegalSection> sections;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.lastUpdated,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Last updated: $lastUpdated', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    const SizedBox(height: 24),
                    ...sections.asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final section = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$index. ${section.heading}',
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              section.body,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.6),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineBorder, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.mail_outline_rounded, color: AppColors.primaryBlueLight, size: 16),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Questions about this document? Reach us via Contact support.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                            ),
                          ),
                        ],
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
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
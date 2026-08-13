import 'package:flutter/material.dart';
import 'package:zelyo_1/theme/app_colors.dart';

class _Statement {
  final String label;
  final String period;

  const _Statement({required this.label, required this.period});
}

class _Document {
  final String label;
  final String status;
  final bool isVerified;

  const _Document({required this.label, required this.status, required this.isVerified});
}

/// Monthly account statements + uploaded KYC documents. Sub-screen of
/// Profile — has a back button.
class StatementsDocumentsScreen extends StatelessWidget {
  const StatementsDocumentsScreen({super.key});

  // TODO: replace with the user's real generated statements.
  static const List<_Statement> _statements = [
    _Statement(label: 'January 2026', period: 'Generated 1 Feb 2026'),
    _Statement(label: 'December 2025', period: 'Generated 1 Jan 2026'),
    _Statement(label: 'November 2025', period: 'Generated 1 Dec 2025'),
    _Statement(label: 'October 2025', period: 'Generated 1 Nov 2025'),
  ];

  // TODO: replace with the user's real uploaded/verified documents.
  static const List<_Document> _documents = [
    _Document(label: 'National ID', status: 'Verified 12 Jan 2026', isVerified: true),
    _Document(label: 'International passport', status: 'Not uploaded', isVerified: false),
  ];

  void _onDownloadTap(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
        content: Text('Downloading $label — coming soon', style: const TextStyle(color: AppColors.textPrimary)),
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
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  const Text('Monthly statements', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.outlineBorder, width: 1),
                    ),
                    child: Column(
                      children: List.generate(_statements.length, (index) {
                        final isLast = index == _statements.length - 1;
                        final statement = _statements[index];
                        return Column(
                          children: [
                            InkWell(
                              onTap: () => _onDownloadTap(context, statement.label),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.14), borderRadius: BorderRadius.circular(11)),
                                      child: const Icon(Icons.description_outlined, color: AppColors.primaryBlueLight, size: 18),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(statement.label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 2),
                                          Text(statement.period, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.file_download_outlined, color: AppColors.primaryBlueLight, size: 20),
                                  ],
                                ),
                              ),
                            ),
                            if (!isLast) const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(color: AppColors.outlineBorder, height: 1)),
                          ],
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 28),
                  const Text('Documents', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.outlineBorder, width: 1),
                    ),
                    child: Column(
                      children: List.generate(_documents.length, (index) {
                        final isLast = index == _documents.length - 1;
                        final doc = _documents[index];
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: (doc.isVerified ? AppColors.success : AppColors.textMuted).withOpacity(0.14),
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    child: Icon(
                                      doc.isVerified ? Icons.verified_outlined : Icons.upload_file_outlined,
                                      color: doc.isVerified ? AppColors.success : AppColors.textMuted,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(doc.label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 2),
                                        Text(
                                          doc.status,
                                          style: TextStyle(color: doc.isVerified ? AppColors.success : AppColors.textMuted, fontSize: 11.5, fontWeight: doc.isVerified ? FontWeight.w600 : FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast) const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(color: AppColors.outlineBorder, height: 1)),
                          ],
                        );
                      }),
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
          const Text('Statements & documents', style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
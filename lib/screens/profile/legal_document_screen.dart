import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zelyo_1/theme/app_colors.dart';

class LegalSection {
  final String heading;
  final String body;

  const LegalSection({
    required this.heading,
    required this.body,
  });
}

class LegalDocumentState {
  final String title;
  final String lastUpdated;
  final List<LegalSection> sections;

  const LegalDocumentState({
    required this.title,
    required this.lastUpdated,
    required this.sections,
  });

  LegalDocumentState copyWith({
    String? title,
    String? lastUpdated,
    List<LegalSection>? sections,
  }) {
    return LegalDocumentState(
      title: title ?? this.title,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      sections: sections ?? this.sections,
    );
  }
}

class LegalDocumentNotifier extends Notifier<LegalDocumentState> {
  @override
  LegalDocumentState build() {
    return const LegalDocumentState(
      title: '',
      lastUpdated: '',
      sections: [],
    );
  }

  void setDocument({
    required String title,
    required String lastUpdated,
    required List<LegalSection> sections,
  }) {
    state = LegalDocumentState(
      title: title,
      lastUpdated: lastUpdated,
      sections: sections,
    );
  }

  void updateDocument({
    String? title,
    String? lastUpdated,
    List<LegalSection>? sections,
  }) {
    state = state.copyWith(
      title: title,
      lastUpdated: lastUpdated,
      sections: sections,
    );
  }
}

final legalDocumentProvider =
    NotifierProvider<LegalDocumentNotifier, LegalDocumentState>(
  LegalDocumentNotifier.new,
);

class LegalDocumentScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listenManual<LegalDocumentState>(
      legalDocumentProvider,
      (previous, next) {},
    );

    final document = ref.watch(legalDocumentProvider);

    // Keep the existing constructor-based API so Terms/Privacy screens
    // continue to work exactly as before while the document is managed
    // through Riverpod.
    if (document.title != title ||
        document.lastUpdated != lastUpdated ||
        document.sections != sections) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ref.read(legalDocumentProvider.notifier).setDocument(
                title: title,
                lastUpdated: lastUpdated,
                sections: sections,
              );
        }
      });
    }

    final activeDocument =
        document.title.isEmpty ? null : document;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(
              context,
              activeDocument?.title ?? title,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last updated: '
                      '${activeDocument?.lastUpdated ?? lastUpdated}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...(activeDocument?.sections ?? sections)
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key + 1;
                      final section = entry.value;

                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 22),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$index. ${section.heading}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              section.body,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13.5,
                                height: 1.6,
                              ),
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
                        borderRadius:
                            BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.outlineBorder,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.mail_outline_rounded,
                            color:
                                AppColors.primaryBlueLight,
                            size: 16,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Questions about this document? Reach us via Contact support.',
                              style: TextStyle(
                                color:
                                    AppColors.textSecondary,
                                fontSize: 12,
                                height: 1.4,
                              ),
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

  Widget _buildHeader(
    BuildContext context,
    String documentTitle,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 4),
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
          Expanded(
            child: Text(
              documentTitle,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
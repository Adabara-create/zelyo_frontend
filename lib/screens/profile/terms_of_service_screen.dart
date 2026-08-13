import 'package:flutter/material.dart';
import 'legal_document_screen.dart';

/// TODO: replace this placeholder text with your actual, lawyer-reviewed
/// Terms of Service before shipping — this is illustrative structure
/// only, not real legal content.
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      title: 'Terms of service',
      lastUpdated: '1 January 2026',
      sections: [
        LegalSection(
          heading: 'Acceptance of terms',
          body: 'By creating a Zelyo account or using any Zelyo service, you agree to be bound by these Terms of Service and any policies referenced within them.',
        ),
        LegalSection(
          heading: 'Eligibility',
          body: 'You must be at least the minimum age required in your country to use Zelyo, and able to form a legally binding contract, to open an account.',
        ),
        LegalSection(
          heading: 'Your account',
          body: 'You are responsible for keeping your passcode, transaction PIN, and card PIN confidential, and for all activity that occurs under your account.',
        ),
        LegalSection(
          heading: 'Verification and compliance',
          body: 'Zelyo may require identity verification, including government-issued identification, to comply with applicable financial regulations before or during your use of certain features.',
        ),
        LegalSection(
          heading: 'Fees',
          body: 'Certain transactions, including transfers, withdrawals, and currency conversions, may carry a fee, which is disclosed before you confirm the transaction.',
        ),
        LegalSection(
          heading: 'Prohibited use',
          body: 'You may not use Zelyo for any unlawful purpose, including fraud, money laundering, or transactions involving prohibited goods or services.',
        ),
        LegalSection(
          heading: 'Suspension and termination',
          body: 'Zelyo may suspend or close your account if we reasonably believe these terms have been violated, or as required by law or our regulators.',
        ),
        LegalSection(
          heading: 'Changes to these terms',
          body: 'We may update these terms from time to time. Continued use of Zelyo after changes take effect constitutes acceptance of the revised terms.',
        ),
        LegalSection(
          heading: 'Contact',
          body: 'Questions about these terms can be directed to our support team from within the app.',
        ),
      ],
    );
  }
}
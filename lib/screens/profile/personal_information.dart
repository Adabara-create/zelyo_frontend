import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zelyo_1/theme/app_colors.dart';

/// Riverpod state for the user's personal information.
class PersonalInformationState {
  final String email;
  final String phone;
  final String address;

  const PersonalInformationState({
    required this.email,
    required this.phone,
    required this.address,
  });

  PersonalInformationState copyWith({
    String? email,
    String? phone,
    String? address,
  }) {
    return PersonalInformationState(
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}

class PersonalInformationNotifier
    extends Notifier<PersonalInformationState> {
  @override
  PersonalInformationState build() {
    return const PersonalInformationState(
      email: 'amara.johnson@email.com',
      phone: '+234 803 456 7890',
      address: '12 Ronike Street, Lekki, Lagos',
    );
  }

  void updateEmail(String value) {
    state = state.copyWith(email: value);
  }

  void updatePhone(String value) {
    state = state.copyWith(phone: value);
  }

  void updateAddress(String value) {
    state = state.copyWith(address: value);
  }
}

final personalInformationProvider = NotifierProvider<
    PersonalInformationNotifier, PersonalInformationState>(
  PersonalInformationNotifier.new,
);

class PersonalInformationScreen extends ConsumerWidget {
  const PersonalInformationScreen({super.key});

  static const String _fullName = 'Amara Johnson';
  static const String _dateOfBirth = '14 March 1996';
  static const String _nationality = 'Nigerian';
  static const String _idNumberMasked = 'National ID •••• 4821';

  void _showLockedNotice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
        content: Text(
          "This can't be edited — contact support to update verified details.",
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Future<void> _editField({
    required BuildContext context,
    required String title,
    required String currentValue,
    required TextInputType keyboardType,
    required ValueChanged<String> onSave,
  }) async {
    final controller = TextEditingController(text: currentValue);

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.outlineBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(
                'Edit $title',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: controller,
                keyboardType: keyboardType,
                autofocus: true,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
                cursorColor: AppColors.primaryBlue,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.outlineBorder,
                      width: 1.2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.outlineBorder,
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.primaryBlue,
                      width: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pop(controller.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    controller.dispose();

    if (result != null && result.isNotEmpty) {
      onSave(result);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personalInfo = ref.watch(personalInformationProvider);
    final notifier = ref.read(personalInformationProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primaryBlue,
                                  AppColors.primaryBlueLight,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            _fullName,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                color: AppColors.success,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Identity verified',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        const Text(
                          'Identity details',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.textMuted,
                          size: 13,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard([
                      _InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'Full name',
                        value: _fullName,
                        isLocked: true,
                        onTap: () => _showLockedNotice(context),
                      ),
                      _InfoRow(
                        icon: Icons.cake_outlined,
                        label: 'Date of birth',
                        value: _dateOfBirth,
                        isLocked: true,
                        onTap: () => _showLockedNotice(context),
                      ),
                      _InfoRow(
                        icon: Icons.flag_outlined,
                        label: 'Nationality',
                        value: _nationality,
                        isLocked: true,
                        onTap: () => _showLockedNotice(context),
                      ),
                      _InfoRow(
                        icon: Icons.credit_card_outlined,
                        label: 'ID document',
                        value: _idNumberMasked,
                        isLocked: true,
                        onTap: () => _showLockedNotice(context),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        "Verified details can't be edited here — contact support if something needs to change.",
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11.5,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Contact details',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard([
                      _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: personalInfo.email,
                        onTap: () => _editField(
                          context: context,
                          title: 'email',
                          currentValue: personalInfo.email,
                          keyboardType: TextInputType.emailAddress,
                          onSave: notifier.updateEmail,
                        ),
                      ),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone number',
                        value: personalInfo.phone,
                        onTap: () => _editField(
                          context: context,
                          title: 'phone number',
                          currentValue: personalInfo.phone,
                          keyboardType: TextInputType.phone,
                          onSave: notifier.updatePhone,
                        ),
                      ),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Residential address',
                        value: personalInfo.address,
                        onTap: () => _editField(
                          context: context,
                          title: 'address',
                          currentValue: personalInfo.address,
                          keyboardType: TextInputType.streetAddress,
                          onSave: notifier.updateAddress,
                        ),
                      ),
                    ]),
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
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'Personal information',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<_InfoRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: List.generate(rows.length, (index) {
          final isLast = index == rows.length - 1;
          final row = rows[index];

          return Column(
            children: [
              InkWell(
                onTap: row.onTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(
                          row.icon,
                          color: AppColors.primaryBlueLight,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.label,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              row.value,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        row.isLocked
                            ? Icons.lock_outline_rounded
                            : Icons.edit_outlined,
                        color: AppColors.textMuted,
                        size: 17,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    color: AppColors.outlineBorder,
                    height: 1,
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isLocked;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.isLocked = false,
  });
}
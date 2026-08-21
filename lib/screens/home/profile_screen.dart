import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/providers/profile_provider.dart';
import 'package:zelyo_1/screens/auth/welcome_back_screen.dart';
import 'package:zelyo_1/screens/auth/create_pin_screen.dart';
import 'verify_transaction_pin_screen.dart';
import 'package:zelyo_1/screens/profile/personal_information.dart';
import 'package:zelyo_1/screens/profile/account_limit_screen.dart';
import 'package:zelyo_1/screens/profile/statements_documents_screen.dart';
import 'package:zelyo_1/screens/profile/login_activity_screen.dart';
import 'notifications_screen.dart';
import 'package:zelyo_1/screens/profile/display_screen.dart';
import 'package:zelyo_1/screens/profile/language_screen.dart';
import 'package:zelyo_1/screens/profile/help_center.dart';
import 'package:zelyo_1/screens/profile/terms_of_service_screen.dart';
import 'package:zelyo_1/screens/profile/privacy_policy_screen.dart';
import 'package:zelyo_1/screens/profile/contact_support_screen.dart';

/// The Profile tab — identity header, profile-completion + account-tier
/// progress, grouped settings sections, and a clearly separated danger
/// zone. No back button since this is a top-level tab, same convention
/// as [CardScreen].
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final LocalAuthentication _localAuth =
      LocalAuthentication();

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
        content: Text(
          '$label — coming soon',
          style: const TextStyle(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Future<void> _onToggleBiometric(bool value) async {
    if (!value) {
      ref
          .read(profileProvider.notifier)
          .setBiometricEnabled(false);
      return;
    }

    try {
      final confirmed =
          await _localAuth.authenticate(
        localizedReason:
            'Confirm your fingerprint to enable biometric login',
        biometricOnly: true,
      );

      if (confirmed && mounted) {
        ref
            .read(profileProvider.notifier)
            .setBiometricEnabled(true);
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              AppColors.surfaceElevated,
          content: Text(
            "Couldn't confirm fingerprint.",
            style: TextStyle(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _onChangePinTap() async {
    final verified =
        await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) =>
            const VerifyTransactionPinScreen(
          purpose:
              'Verify your current PIN to change it',
        ),
      ),
    );

    if (verified != true || !mounted) return;

    // NOTE: CreatePinScreen -> ConfirmPinScreen currently ends by pushing
    // FingerprintSetupScreen, since that chain was built for onboarding.
    // For a true "change PIN" entry point here, ConfirmPinScreen should
    // instead just pop(true) and let the caller decide what's next —
    // worth refactoring before relying on this in production.
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            const CreatePinScreen(),
      ),
    );
  }

  Future<void> _onLogOutTap() async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      barrierColor:
          Colors.black.withOpacity(0.6),
      builder: (context) => _ConfirmDialog(
        icon: Icons.logout_rounded,
        iconColor:
            AppColors.primaryBlueLight,
        title: 'Log out of Zelyo?',
        message:
            "You'll need your passcode or fingerprint to log back in.",
        confirmLabel: 'Log out',
        confirmColor:
            AppColors.primaryBlue,
      ),
    );

    if (confirmed != true || !mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) =>
            const WelcomeBackScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> _onDeleteAccountTap() async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      barrierColor:
          Colors.black.withOpacity(0.6),
      builder: (context) => _ConfirmDialog(
        icon:
            Icons.delete_outline_rounded,
        iconColor: AppColors.danger,
        title: 'Delete your account?',
        message:
            'This permanently closes your Zelyo account and cards. This cannot be undone.',
        confirmLabel: 'Delete',
        confirmColor: AppColors.danger,
      ),
    );

    if (confirmed == true && mounted) {
      // TODO: call the real account-deletion endpoint, then sign out.
      _showComingSoon('Account deletion');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState =
        ref.watch(profileProvider);

    final userName = profileState.userName;
    final userEmail = profileState.userEmail;
    final isVerified = profileState.isVerified;
    final profileCompletion =
        profileState.profileCompletion;
    final accountTier =
        profileState.accountTier;
    final isBiometricEnabled =
        profileState.isBiometricEnabled;

    return Scaffold(
      backgroundColor:
          AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            24,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  color:
                      AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(height: 20),

              _buildHeroCard(
                userName,
                userEmail,
                isVerified,
              ),

              const SizedBox(height: 20),

              _buildProfileCompletionCard(
                profileCompletion,
              ),

              const SizedBox(height: 16),

              _buildAccountTierCard(
                accountTier,
              ),

              const SizedBox(height: 28),

              _buildSectionLabel(
                'Account',
              ),

              const SizedBox(height: 12),

              _buildSettingsCard([
                _SettingsItem(
                  icon:
                      Icons.badge_outlined,
                  label:
                      'Personal information',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const PersonalInformationScreen(),
                    ),
                  ),
                ),
                _SettingsItem(
                  icon:
                      Icons.speed_rounded,
                  label: 'Account Limit',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const AccountLimitScreen(),
                    ),
                  ),
                ),
                _SettingsItem(
                  icon:
                      Icons.description_outlined,
                  label:
                      'Statements & documents',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const StatementsDocumentsScreen(),
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: 24),

              _buildSectionLabel(
                'Security',
              ),

              const SizedBox(height: 12),

              _buildSettingsCard([
                _SettingsItem(
                  icon:
                      Icons.password_rounded,
                  label:
                      'Change transaction PIN',
                  onTap: _onChangePinTap,
                ),
                _SettingsItem(
                  icon:
                      Icons.fingerprint_rounded,
                  label:
                      'Fingerprint & Face ID',
                  trailing: Switch(
                    value:
                        isBiometricEnabled,
                    onChanged:
                        _onToggleBiometric,
                    activeColor:
                        AppColors.primaryBlue,
                  ),
                ),
                _SettingsItem(
                  icon:
                      Icons.history_rounded,
                  label: 'Login activity',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const LoginActivityScreen(),
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: 24),

              _buildSectionLabel(
                'Preferences',
              ),

              const SizedBox(height: 12),

              _buildSettingsCard([
                _SettingsItem(
                  icon:
                      Icons.notifications_none_rounded,
                  label: 'Notifications',
                  onTap: () =>
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const NotificationsScreen(),
                    ),
                  ),
                ),
                _SettingsItem(
                  icon:
                      Icons.display_settings,
                  label: 'Display',
                  onTap: () =>
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const DisplayScreen(),
                    ),
                  ),
                ),
                _SettingsItem(
                  icon:
                      Icons.language_rounded,
                  label: 'Language',
                  onTap: () =>
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const LanguageScreen(),
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: 24),

              _buildSectionLabel(
                'Support',
              ),

              const SizedBox(height: 12),

              _buildSettingsCard([
                _SettingsItem(
                  icon:
                      Icons.help_outline_rounded,
                  label: 'Help center',
                  onTap: () =>
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const HelpCenterScreen(),
                    ),
                  ),
                ),
                _SettingsItem(
                  icon:
                      Icons.headset_mic_outlined,
                  label: 'Contact support',
                  onTap: () =>
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const ContactSupportScreen(),
                    ),
                  ),
                ),
                _SettingsItem(
                  icon:
                      Icons.star_outline_rounded,
                  label: 'Rate Zelyo',
                  onTap: () =>
                      _showComingSoon(
                    'Rate Zelyo',
                  ),
                ),
              ]),

              const SizedBox(height: 24),

              _buildSectionLabel(
                'Legal',
              ),

              const SizedBox(height: 12),

              _buildSettingsCard([
                _SettingsItem(
                  icon:
                      Icons.gavel_rounded,
                  label:
                      'Terms of service',
                  onTap: () =>
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const TermsOfServiceScreen(),
                    ),
                  ),
                ),
                _SettingsItem(
                  icon:
                      Icons.privacy_tip_outlined,
                  label:
                      'Privacy policy',
                  onTap: () =>
                      Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const PrivacyPolicyScreen(),
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: 28),

              SizedBox(
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: _onLogOutTap,
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Log out',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        AppColors.textPrimary,
                    side:
                        const BorderSide(
                      color:
                          AppColors.outlineBorder,
                      width: 1.4,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _buildSectionLabel(
                'Danger zone',
                color: AppColors.danger,
              ),

              const SizedBox(height: 12),

              _buildSettingsCard([
                _SettingsItem(
                  icon:
                      Icons.delete_outline_rounded,
                  label: 'Delete account',
                  isDestructive: true,
                  onTap:
                      _onDeleteAccountTap,
                ),
              ]),

              const SizedBox(height: 28),

              const Center(
                child: Text(
                  'Zelyo v1.0.0',
                  style: TextStyle(
                    color:
                        AppColors.textMuted,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(
    String userName,
    String userEmail,
    bool isVerified,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        24,
        28,
        24,
        22,
      ),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlueDark,
          ],
        ),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      Colors.white.withOpacity(
                    0.18,
                  ),
                  border: Border.all(
                    color: Colors.white
                        .withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),

              Positioned(
                bottom: -2,
                right: -2,
                child: GestureDetector(
                  onTap: () => _showComingSoon(
                    'Profile photo',
                  ),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration:
                        BoxDecoration(
                      shape:
                          BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: AppColors
                            .primaryBlueDark,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons
                          .camera_alt_rounded,
                      color: AppColors
                          .primaryBlue,
                      size: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Text(
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              if (isVerified) ...[
                const SizedBox(width: 8),

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.18),
                    borderRadius:
                        BorderRadius.circular(
                      999,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Icon(
                        Icons
                            .verified_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                      SizedBox(width: 3),
                      Text(
                        'Verified',
                        style: TextStyle(
                          color:
                              Colors.white,
                          fontSize: 10.5,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 4),

          Text(
            userEmail,
            style: TextStyle(
              color: Colors.white
                  .withOpacity(0.75),
              fontSize: 12.5,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              const Expanded(
                child: _HeroStat(
                  label: 'Currencies',
                  value: '5',
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color:
                    Colors.white.withOpacity(
                  0.2,
                ),
              ),
              const Expanded(
                child: _HeroStat(
                  label: 'Cards',
                  value: '1',
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color:
                    Colors.white.withOpacity(
                  0.2,
                ),
              ),
              const Expanded(
                child: _HeroStat(
                  label: 'Member since',
                  value: 'Jan 2025',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionCard(
    double profileCompletion,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Profile completion',
                  style: TextStyle(
                    color:
                        AppColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),

              Text(
                '${(profileCompletion * 100).round()}%',
                style: const TextStyle(
                  color:
                      AppColors.primaryBlueLight,
                  fontSize: 14.5,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(8),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: (profileCompletion *
                            1000)
                        .round(),
                    child: Container(
                      color:
                          AppColors.primaryBlue,
                    ),
                  ),
                  Expanded(
                    flex:
                        ((1 -
                                    profileCompletion) *
                                1000)
                            .round(),
                    child: Container(
                      color: AppColors
                          .surfaceElevated,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          InkWell(
            onTap: () => _showComingSoon(
              'International passport upload',
            ),
            borderRadius:
                BorderRadius.circular(10),
            child: Row(
              children: [
                const Icon(
                  Icons.badge_outlined,
                  color: AppColors
                      .primaryBlueLight,
                  size: 16,
                ),

                const SizedBox(width: 8),

                const Expanded(
                  child: Text(
                    'Add your international passport to unlock higher limits',
                    style: TextStyle(
                      color: AppColors
                          .textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                ),

                const Icon(
                  Icons
                      .chevron_right_rounded,
                  color:
                      AppColors.textMuted,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTierCard(
    String accountTier,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.workspace_premium_outlined,
                color:
                    Color(0xFFF59E0B),
                size: 18,
              ),

              const SizedBox(width: 8),

              const Text(
                'Account tier',
                style: TextStyle(
                  color:
                      AppColors.textPrimary,
                  fontSize: 14.5,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const Spacer(),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration:
                    BoxDecoration(
                  color: AppColors
                      .primaryBlue
                      .withOpacity(0.14),
                  borderRadius:
                      BorderRadius.circular(
                    999,
                  ),
                ),
                child: Text(
                  accountTier,
                  style:
                      const TextStyle(
                    color: AppColors
                        .primaryBlueLight,
                    fontSize: 11.5,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          const Text(
            'Standard gives you access to transfers, deposits, and one virtual card per currency.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              height: 1.5,
            ),
          ),

          const Padding(
            padding:
                EdgeInsets.symmetric(
              vertical: 14,
            ),
            child: Divider(
              color: AppColors.outlineBorder,
              height: 1,
            ),
          ),

          InkWell(
            onTap: () => _showComingSoon(
              'Premium tier upgrade',
            ),
            borderRadius:
                BorderRadius.circular(10),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration:
                      BoxDecoration(
                    color: const Color(
                      0xFFF59E0B,
                    ).withOpacity(0.15),
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: const Icon(
                    Icons.upgrade_rounded,
                    color:
                        Color(0xFFF59E0B),
                    size: 17,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        'Unlock Premium',
                        style:
                            TextStyle(
                          color: AppColors
                              .textPrimary,
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Verify your international passport for higher limits',
                        style:
                            TextStyle(
                          color: AppColors
                              .textMuted,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons
                      .chevron_right_rounded,
                  color:
                      AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(
    String label, {
    Color color =
        AppColors.textPrimary,
  }) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSettingsCard(
    List<_SettingsItem> items,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: List.generate(
          items.length,
          (index) {
            final isLast =
                index == items.length - 1;

            final item = items[index];

            return Column(
              children: [
                InkWell(
                  onTap: item.onTap,
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration:
                              BoxDecoration(
                            color: item
                                    .isDestructive
                                ? AppColors
                                    .danger
                                    .withOpacity(
                                    0.14,
                                  )
                                : AppColors
                                    .primaryBlue
                                    .withOpacity(
                                    0.14,
                                  ),
                            borderRadius:
                                BorderRadius.circular(
                              11,
                            ),
                          ),
                          child: Icon(
                            item.icon,
                            color: item
                                    .isDestructive
                                ? AppColors
                                    .danger
                                : AppColors
                                    .primaryBlueLight,
                            size: 19,
                          ),
                        ),

                        const SizedBox(
                          width: 14,
                        ),

                        Expanded(
                          child: Text(
                            item.label,
                            style:
                                TextStyle(
                              color: item
                                      .isDestructive
                                  ? AppColors
                                      .danger
                                  : AppColors
                                      .textPrimary,
                              fontSize: 14.5,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),

                        item.trailing ??
                            const Icon(
                              Icons
                                  .chevron_right_rounded,
                              color:
                                  AppColors
                                      .textMuted,
                              size: 20,
                            ),
                      ],
                    ),
                  ),
                ),

                if (!isLast)
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: Divider(
                      color:
                          AppColors.outlineBorder,
                      height: 1,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeroStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color:
                Colors.white.withOpacity(0.7),
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDestructive;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
    this.isDestructive = false,
  });
}

class _ConfirmDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;

  const _ConfirmDialog({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor:
          Colors.transparent,
      insetPadding:
          const EdgeInsets.symmetric(
        horizontal: 32,
      ),
      child: Container(
        padding:
            const EdgeInsets.fromLTRB(
          28,
          28,
          28,
          20,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.circular(28),
          border: Border.all(
            color:
                AppColors.outlineBorder,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor
                    .withOpacity(0.15),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 30,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              title,
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                color:
                    AppColors.textPrimary,
                fontSize: 17,
                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                color:
                    AppColors.textMuted,
                fontSize: 13,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child:
                        OutlinedButton(
                      onPressed: () =>
                          Navigator.of(
                        context,
                      ).pop(false),
                      style: OutlinedButton
                          .styleFrom(
                        foregroundColor:
                            AppColors
                                .textPrimary,
                        side:
                            const BorderSide(
                          color: AppColors
                              .outlineBorder,
                          width: 1.4,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),
                      ),
                      child:
                          const Text(
                        'Cancel',
                        style:
                            TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: SizedBox(
                    height: 50,
                    child:
                        ElevatedButton(
                      onPressed: () =>
                          Navigator.of(
                        context,
                      ).pop(true),
                      style: ElevatedButton
                          .styleFrom(
                        backgroundColor:
                            confirmColor,
                        foregroundColor:
                            Colors.white,
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),
                      ),
                      child: Text(
                        confirmLabel,
                        style:
                            const TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/providers/card_provider.dart';
import 'create_card_pin_screen.dart';
import 'verify_transaction_pin_screen.dart';

/// Card settings — customization options, then a clearly separated
/// "Danger zone" for the destructive delete-card action.
class CardSettingsScreen extends ConsumerWidget {
  const CardSettingsScreen({super.key});

  Future<void> _onChangePinTap(
    BuildContext context,
  ) async {
    final verified = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) =>
            const VerifyTransactionPinScreen(
          purpose:
              'Verify your mobile PIN before changing your card PIN',
        ),
      ),
    );

    if (verified != true || !context.mounted) return;

    // TODO: once changed, this should update the specific card's stored
    // PIN rather than just running the same create-PIN flow again.
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            const CreateCardPinScreen(),
      ),
    );
  }

  void _showComingSoonSnackBar(
    BuildContext context,
    String label,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            AppColors.surfaceElevated,
        content: Text(
          '$label — coming soon',
          style: const TextStyle(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Future<void> _onDeleteCardTap(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      barrierColor:
          Colors.black.withOpacity(0.6),
      builder: (context) => Dialog(
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
                  shape:
                      BoxShape.circle,
                  color: AppColors.danger
                      .withOpacity(0.15),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                  size: 30,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Delete this card?',
                style: TextStyle(
                  color:
                      AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'This can\'t be undone. You\'ll need to go through verification again to open a new card.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
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
                      child: OutlinedButton(
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
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.of(
                              context,
                            ).pop(true),
                        style: ElevatedButton
                            .styleFrom(
                          backgroundColor:
                              AppColors
                                  .danger,
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
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w600,
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
      ),
    );

    if (confirmed == true &&
        context.mounted) {
      // ---------------------------------------------------------------
      // Riverpod
      // ---------------------------------------------------------------
      // The card account state is now updated through the centralized
      // cardsProvider instead of modifying CardScreen's local state.
      ref
          .read(cardsProvider.notifier)
          .deleteCard();

      // Keep the existing navigation behavior so CardScreen can react
      // to the successful deletion if needed.
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    // Riverpod watches the card account state so this screen remains
    // connected to the centralized card state.
    ref.watch(cardsProvider);

    return Scaffold(
      backgroundColor:
          AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  4,
                  20,
                  24,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Customize card',
                      style: TextStyle(
                        color:
                            AppColors
                                .textPrimary,
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildSettingsCard(
                      context,
                      [
                        _SettingsItem(
                          icon:
                              Icons.badge_outlined,
                          label:
                              'Custom name',
                          onTap: () =>
                              _showComingSoonSnackBar(
                            context,
                            'Custom name',
                          ),
                        ),
                        _SettingsItem(
                          icon:
                              Icons.password_rounded,
                          label:
                              'Change PIN',
                          onTap: () =>
                              _onChangePinTap(
                            context,
                          ),
                        ),
                        _SettingsItem(
                          icon:
                              Icons.restart_alt_rounded,
                          label:
                              'Reset PIN',
                          onTap: () =>
                              _onChangePinTap(
                            context,
                          ),
                        ),
                        _SettingsItem(
                          icon:
                              Icons.speed_rounded,
                          label:
                              'Card limit',
                          onTap: () =>
                              _showComingSoonSnackBar(
                            context,
                            'Card limit',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Danger zone',
                      style: TextStyle(
                        color:
                            AppColors.danger,
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildSettingsCard(
                      context,
                      [
                        _SettingsItem(
                          icon:
                              Icons.delete_outline_rounded,
                          label:
                              'Delete card',
                          isDestructive:
                              true,
                          onTap: () =>
                              _onDeleteCardTap(
                            context,
                            ref,
                          ),
                        ),
                      ],
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
  ) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        12,
        8,
        20,
        4,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () =>
                Navigator.of(context)
                    .maybePop(),
            icon: const Icon(
              Icons
                  .arrow_back_ios_new_rounded,
              color:
                  AppColors.textPrimary,
              size: 20,
            ),
          ),

          const SizedBox(width: 4),

          const Text(
            'Card settings',
            style: TextStyle(
              color:
                  AppColors.textPrimary,
              fontSize: 19,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context,
    List<_SettingsItem> items,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              AppColors.outlineBorder,
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
                            color:
                                item.isDestructive
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
                                BorderRadius
                                    .circular(
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
                                  FontWeight
                                      .w600,
                            ),
                          ),
                        ),

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
                      color: AppColors
                          .outlineBorder,
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

class _SettingsItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
}
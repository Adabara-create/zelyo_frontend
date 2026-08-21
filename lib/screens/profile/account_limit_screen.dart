import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zelyo_1/theme/app_colors.dart';

class _LimitItem {
  final IconData icon;
  final String label;
  final double used;
  final double limit;
  final String currencySymbol;

  const _LimitItem({
    required this.icon,
    required this.label,
    required this.used,
    required this.limit,
    required this.currencySymbol,
  });

  double get ratio => limit == 0 ? 0 : (used / limit).clamp(0, 1);
}

class AccountLimitState {
  final String tier;
  final List<_LimitItem> limits;

  const AccountLimitState({
    required this.tier,
    required this.limits,
  });

  AccountLimitState copyWith({
    String? tier,
    List<_LimitItem>? limits,
  }) {
    return AccountLimitState(
      tier: tier ?? this.tier,
      limits: limits ?? this.limits,
    );
  }
}

class AccountLimitNotifier extends Notifier<AccountLimitState> {
  @override
  AccountLimitState build() {
    return const AccountLimitState(
      tier: 'Standard tier',
      limits: [
        _LimitItem(
          icon: Icons.swap_horiz_rounded,
          label: 'Daily transfer limit',
          used: 180000,
          limit: 500000,
          currencySymbol: '₦',
        ),
        _LimitItem(
          icon: Icons.calendar_month_outlined,
          label: 'Monthly transfer limit',
          used: 620000,
          limit: 5000000,
          currencySymbol: '₦',
        ),
        _LimitItem(
          icon: Icons.north_east_rounded,
          label: 'Daily withdrawal limit',
          used: 20000,
          limit: 200000,
          currencySymbol: '₦',
        ),
        _LimitItem(
          icon: Icons.south_west_rounded,
          label: 'Daily deposit limit',
          used: 100000,
          limit: 1000000,
          currencySymbol: '₦',
        ),
      ],
    );
  }

  void updateTier(String tier) {
    state = state.copyWith(tier: tier);
  }

  void updateLimits(List<_LimitItem> limits) {
    state = state.copyWith(limits: limits);
  }
}

final accountLimitProvider =
    NotifierProvider<AccountLimitNotifier, AccountLimitState>(
  AccountLimitNotifier.new,
);

class AccountLimitScreen extends ConsumerWidget {
  const AccountLimitScreen({super.key});

  String _formatAmount(num value) {
    final wholePart = value.truncate().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < wholePart.length; i++) {
      if (i > 0 && (wholePart.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(wholePart[i]);
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountLimits = ref.watch(accountLimitProvider);

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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.workspace_premium_outlined,
                          color: Color(0xFFF59E0B),
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          accountLimits.tier,
                          style: const TextStyle(
                            color: AppColors.primaryBlueLight,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...accountLimits.limits.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildLimitCard(item),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.outlineBorder,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            Icons.upgrade_rounded,
                            color: Color(0xFFF59E0B),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 13),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Need higher limits?',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Verify your international passport to unlock Premium.',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11.5,
                                ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildLimitCard(_LimitItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.outlineBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.icon,
                  color: AppColors.primaryBlueLight,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: (item.ratio * 1000).round(),
                    child: Container(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  Expanded(
                    flex: ((1 - item.ratio) * 1000).round(),
                    child: Container(
                      color: AppColors.surfaceElevated,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${item.currencySymbol}${_formatAmount(item.used)} of '
            '${item.currencySymbol}${_formatAmount(item.limit)} used',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11.5,
            ),
          ),
        ],
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
            'Account limits',
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
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zelyo_1/theme/app_colors.dart';

class _Session {
  final String device;
  final String location;
  final String time;
  final IconData icon;
  final bool isCurrent;

  const _Session({
    required this.device,
    required this.location,
    required this.time,
    required this.icon,
    required this.isCurrent,
  });
}

class LoginActivityState {
  final List<_Session> sessions;

  const LoginActivityState({
    required this.sessions,
  });

  LoginActivityState copyWith({
    List<_Session>? sessions,
  }) {
    return LoginActivityState(
      sessions: sessions ?? this.sessions,
    );
  }
}

class LoginActivityNotifier extends Notifier<LoginActivityState> {
  @override
  LoginActivityState build() {
    return const LoginActivityState(
      sessions: [
        _Session(
          device: 'iPhone 15 Pro',
          location: 'Lagos, Nigeria',
          time: 'Active now',
          icon: Icons.phone_iphone_rounded,
          isCurrent: true,
        ),
        _Session(
          device: 'Chrome on Windows',
          location: 'Lagos, Nigeria',
          time: '2 days ago',
          icon: Icons.desktop_windows_outlined,
          isCurrent: false,
        ),
        _Session(
          device: 'Samsung Galaxy S23',
          location: 'Abuja, Nigeria',
          time: '3 weeks ago',
          icon: Icons.phone_android_rounded,
          isCurrent: false,
        ),
      ],
    );
  }

  void removeSession(int index) {
    final updatedSessions = List<_Session>.of(state.sessions)
      ..removeAt(index);

    state = state.copyWith(
      sessions: updatedSessions,
    );
  }

  void updateSessions(List<_Session> sessions) {
    state = state.copyWith(
      sessions: sessions,
    );
  }
}

final loginActivityProvider =
    NotifierProvider<LoginActivityNotifier, LoginActivityState>(
  LoginActivityNotifier.new,
);

class LoginActivityScreen extends ConsumerWidget {
  const LoginActivityScreen({super.key});

  Future<void> _onSignOutTap(
    BuildContext context,
    WidgetRef ref,
    int index,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.outlineBorder,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.danger.withOpacity(0.15),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.danger,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sign out this device?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "This device will need to log in again to access your account.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(
                            color: AppColors.outlineBorder,
                            width: 1.4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Sign out',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
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

    if (confirmed == true) {
      // TODO: revoke the real session on the backend.
      ref
          .read(loginActivityProvider.notifier)
          .removeSession(index);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginActivityProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                itemCount: state.sessions.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final session = state.sessions[index];

                  return _buildSessionCard(
                    context,
                    ref,
                    session,
                    index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(
    BuildContext context,
    WidgetRef ref,
    _Session session,
    int index,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: session.isCurrent
              ? AppColors.primaryBlue.withOpacity(0.35)
              : AppColors.outlineBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryBlue.withOpacity(0.14),
            ),
            child: Icon(
              session.icon,
              color: AppColors.primaryBlueLight,
              size: 19,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        session.device,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (session.isCurrent) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'This device',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${session.location} • ${session.time}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          if (!session.isCurrent)
            IconButton(
              onPressed: () => _onSignOutTap(
                context,
                ref,
                index,
              ),
              icon: const Icon(
                Icons.logout_rounded,
                color: AppColors.danger,
                size: 18,
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
            'Login activity',
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
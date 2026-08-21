import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileState {
  final String userName;
  final String userEmail;
  final bool isVerified;
  final double profileCompletion;
  final String accountTier;
  final bool isBiometricEnabled;

  const ProfileState({
    required this.userName,
    required this.userEmail,
    required this.isVerified,
    required this.profileCompletion,
    required this.accountTier,
    required this.isBiometricEnabled,
  });

  const ProfileState.initial()
      : userName = 'Amara Johnson',
        userEmail = 'amara.johnson@email.com',
        isVerified = true,
        profileCompletion = 0.8,
        accountTier = 'Standard',
        isBiometricEnabled = true;

  ProfileState copyWith({
    String? userName,
    String? userEmail,
    bool? isVerified,
    double? profileCompletion,
    String? accountTier,
    bool? isBiometricEnabled,
  }) {
    return ProfileState(
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      isVerified: isVerified ?? this.isVerified,
      profileCompletion:
          profileCompletion ?? this.profileCompletion,
      accountTier: accountTier ?? this.accountTier,
      isBiometricEnabled:
          isBiometricEnabled ?? this.isBiometricEnabled,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    // TODO: Replace with the signed-in user's real profile data.
    return const ProfileState.initial();
  }

  void setBiometricEnabled(bool enabled) {
    state = state.copyWith(
      isBiometricEnabled: enabled,
    );
  }

  void updateProfile({
    String? userName,
    String? userEmail,
    bool? isVerified,
    double? profileCompletion,
    String? accountTier,
  }) {
    state = state.copyWith(
      userName: userName,
      userEmail: userEmail,
      isVerified: isVerified,
      profileCompletion: profileCompletion,
      accountTier: accountTier,
    );
  }

  void reset() {
    state = const ProfileState.initial();
  }
}

final profileProvider =
    NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);
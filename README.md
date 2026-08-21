# Zelyo

A multi-currency fintech mobile app built with Flutter — transfers, deposits, withdrawals, currency conversion, virtual cards, and account management, in a dark, electric-blue design system.

> **Status:** Active development. Most screens are fully designed and functional in the UI; several critical integrations (payments, biometrics, backend, real KYC) are currently simulated. See [Known Limitations](#known-limitations--todos) before treating any flow as production-ready.

---

## Table of contents

- [Overview](#overview)
- [Features](#features)
- [Tech stack](#tech-stack)
- [Getting started](#getting-started)
- [Project structure](#project-structure)
- [Design system](#design-system)
- [State management](#state-management)
- [Known limitations & TODOs](#known-limitations--todos)
- [Roadmap](#roadmap)

---

## Overview

Zelyo lets a user hold balances in five currencies (NGN, USD, EUR, GBP, JPY), move money between their own accounts and to other people, and spend online through per-currency virtual cards — all behind biometric and PIN-based security, with a full onboarding/KYC flow.

The app is organized around three main tabs — **Home**, **Card**, and **Profile** — sitting on top of an authentication flow (welcome → login/sign up → email OTP → ID verification → passcode setup → fingerprint enrollment → biometric unlock on return visits).

## Features

**Authentication & onboarding**
- Email/password sign up and login, with a carousel welcome/onboarding screen
- Forgot-password flow
- Email OTP verification
- ID verification: National ID capture, date-of-birth age gate (16 and under blocked), selfie + animated face-match scan
- 6-digit app passcode (create + confirm), separate 4-digit transaction PIN
- Fingerprint/Face ID enrollment, with a "Welcome back" biometric unlock screen and passcode fallback

**Home**
- Multi-currency wallet carousel with balance show/hide, copyable account numbers, and per-card frosted-glass action pills
- Transfer flow: recipient search/detection by account number, bank auto-lookup, recipient confirmation, amount entry, review with fee breakdown, PIN authorization, success receipt
- Deposit via bank transfer (virtual account) or debit card
- Withdraw to a saved bank account, with inline PIN authorization
- Currency conversion between the user's own wallets, with live rate display and fee breakdown
- Spending analytics, income vs. expenses, and exchange rate widgets
- Notifications (grouped, swipe-to-dismiss, read/unread state)
- Full transaction history with category/currency filters and search
- Transaction detail screen with status timeline, fee breakdown, and narration

**Card**
- Virtual card intro/benefits screen, gated behind selfie + face scan + PIN verification + a dedicated card PIN
- Swipeable card carousel, one card per currency, each with a unique gradient and decorative pattern
- Card details (PIN-gated), block card (with reason capture), disputes, and card settings

**Profile**
- Identity header with verification badge, profile completion, and account tier progress
- Grouped settings: Account, Security, Preferences, Support, Legal
- Sub-screens: Personal information, Account limits, Statements & documents, Change transaction PIN, Login activity, Display (theme picker), Language, Help center, Contact support, Terms of Service, Privacy Policy

## Tech stack

- **Flutter** / Dart
- **State management:** [Riverpod](https://riverpod.dev) (`flutter_riverpod`) — migration in progress, see [State management](#state-management)
- **Biometrics:** `local_auth`
- **Camera/image capture:** `image_picker`

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  local_auth: ^2.3.0
  image_picker: ^1.1.2
```

## Getting started

1. Ensure the Flutter SDK is installed (`flutter --version` to check).
2. Add the dependencies above to `pubspec.yaml` if they aren't already present, then run:
   ```bash
   flutter pub get
   ```
3. **Platform setup required for biometrics** (`local_auth`):
   - iOS: add `NSFaceIDUsageDescription` to `Info.plist`
   - Android: add `<uses-permission android:name="android.permission.USE_BIOMETRIC" />` to `AndroidManifest.xml`, and ensure the launch `Activity` extends `FlutterFragmentActivity`
4. Run the app:
   ```bash
   flutter run
   ```

## Project structure

```
lib/
├── main.dart                      # App entry point, ProviderScope + MaterialApp
├── theme/
│   └── app_colors.dart            # Centralized color palette (dark theme)
├── models/
│   ├── transfer_models.dart       # TransferCurrency, Recipient, TransferRequest
│   └── card_models.dart           # VirtualCardData, CardPattern
├── providers/                     # Riverpod state, mirrors the screens/ split
│   ├── home/
│   │   ├── accounts_provider.dart
│   │   └── transactions_provider.dart
│   └── card/
│       └── cards_provider.dart
├── widgets/                       # Shared, reusable UI
│   ├── pin_dot_indicator.dart
│   ├── pin_keypad.dart
│   ├── carousel_dots.dart
│   ├── onboarding_slide.dart
│   ├── recipient_confirm_sheet.dart
│   └── app_transitions.dart
└── screens/
    ├── auth/                      # Welcome through fingerprint enrollment
    ├── home/                      # Home tab + transfer/deposit/withdraw/convert
    ├── card/                      # Card tab + card sub-flows
    ├── profile/                   # Profile tab + settings sub-screens
    └── home_shell.dart            # Bottom nav wrapper (Home / Card / Profile)
```

Each top-level tab (`home/`, `card/`, `profile/`) owns its own screens *and* its own `providers/<tab>/` folder — state that's shared across a tab's screens lives there rather than being duplicated per screen.

## Design system

- **Palette:** deep navy background (`#0B0F1A`), electric blue accent gradient (`#2563FF → #3B82F6`), soft navy-tinted surfaces — defined once in `AppColors` and used everywhere rather than inline hex values.
- **Shape language:** large rounded corners (20–28px) on cards, pill-shaped (999px radius) buttons and chips.
- **Motion:** consistent shake-on-error for PIN entry, fade/scale transitions for success states, animated icon crossfades in navigation.
- **Components:** every screen composes from the same small set of primitives — `PinDotIndicator`/`PinKeypad` for all PIN flows, a shared bottom-sheet pattern for pickers and confirmations, a shared card-list-row pattern for settings and transactions.

## State management

Zelyo is mid-migration from per-screen `StatefulWidget`/`setState` to shared Riverpod providers, tab by tab. The goal: state that's read or written from more than one screen (account balances, transaction history, card status) lives in one provider instead of being duplicated as separate hardcoded lists per screen.

**Done:**
- `accounts_provider.dart` — multi-currency wallet balances
- `transactions_provider.dart` — unified transaction history
- `cards_provider.dart` — card issuance/block status

**Not yet migrated:** the screens that should *consume* these providers (`home_screen.dart`, `transfer_screen.dart`, `deposit_screen.dart`, `withdraw_screen.dart`, `convert_screen.dart`, `card_screen.dart`, etc.) still use their own local state in places — see each provider file's doc comment for exactly which screen(s) it's meant to replace.

**Planned but not started:** `notifications_provider.dart`, `transfer_flow_provider.dart`, `card_transactions_provider.dart`, `disputes_provider.dart`, `profile_provider.dart`, `sessions_provider.dart`, `language_provider.dart`.

## Known limitations & TODOs

These are called out here deliberately, not hidden — every one of them is also marked `// TODO` at its exact location in code.

| Area | Current state |
|---|---|
| Face verification (onboarding + card opening) | UI simulation only — no real liveness/face-match provider wired in |
| Transaction PIN / card PIN checks | Hardcoded placeholder values, not real stored/verified secrets |
| Bank account resolution (transfer flow) | Simulated lookup, not a real NUBAN/account-resolve API |
| Card payment (deposit) | No real payment gateway (Stripe/Paystack/Flutterwave) integrated |
| Card capture form | UI shell only — **do not** wire this to a real backend as-is; real card data must go through a payment SDK's client-side tokenization, not your own server, for PCI-DSS reasons (see the security note in `deposit_screen.dart`) |
| Light theme | Palette structure exists but isn't wired up; app is dark-only today |
| "Share receipt" buttons | No real receipt generation/share-sheet integration yet |
| Legal content (Terms, Privacy) | Placeholder structure only — needs real, lawyer-reviewed text before shipping |

## Roadmap

- [ ] Finish Riverpod migration across Home, Card, and Profile
- [ ] Wire a real payment gateway for card deposits
- [ ] Wire a real identity-verification/liveness provider
- [ ] Implement light theme
- [ ] Replace all hardcoded PIN/session/document sample data with real backend integration

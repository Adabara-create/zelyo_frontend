import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/widgets/carousel_dots.dart';
import 'history_screen.dart';
import 'transfer_screen.dart';
import 'deposit_screen.dart';
import 'notifications_screen.dart';
import 'withdraw_screen.dart';
import 'convert_screen.dart';
import 'transaction_detail_screen.dart';


/// All data below (accounts, contacts, transactions, insights) is
/// sample/static — every section is broken into its own method so
/// wiring in real data later doesn't require touching the layout.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Consistent spacing rhythm across every section, per the 24px rule.
  static const double _kSpacing = 24;

  final PageController _cardController = PageController();
  int _activeCardIndex = 0;

  // TODO: replace with the signed-in user's real name.
  static const String _userFullName = 'Amara Johnson';

  // TODO: replace with the user's real multi-currency accounts.
  final List<_CurrencyAccount> _accounts = const [
    _CurrencyAccount(
      code: 'NGN',
      flag: '🇳🇬',
      symbol: '₦',
      accountNumber: '2203 4471 902',
      balance: 482350.75,
      lastUpdatedLabel: 'Updated 2 mins ago',
    ),
    _CurrencyAccount(
      code: 'USD',
      flag: '🇺🇸',
      symbol: '\$',
      accountNumber: '8814 2290 117',
      balance: 3240.50,
      lastUpdatedLabel: 'Updated 5 mins ago',
    ),
    _CurrencyAccount(
      code: 'EUR',
      flag: '🇪🇺',
      symbol: '€',
      accountNumber: '5502 8834 663',
      balance: 1875.20,
      lastUpdatedLabel: 'Updated 12 mins ago',
    ),
    _CurrencyAccount(
      code: 'GBP',
      flag: '🇬🇧',
      symbol: '£',
      accountNumber: '7719 4402 258',
      balance: 962.00,
      lastUpdatedLabel: 'Updated 20 mins ago',
    ),
    _CurrencyAccount(
      code: 'JPY',
      flag: '🇯🇵',
      symbol: '¥',
      accountNumber: '3390 1187 542',
      balance: 158400,
      lastUpdatedLabel: 'Updated 1 hour ago',
    ),
  ];

  
  // TODO: replace with the user's real recent transactions.
  final List<_Transaction> _transactions = const [
    _Transaction(
      name: 'David Eze',
      subtitle: 'Transfer received',
      date: 'Today',
      time: '10:42 AM',
      amount: 45000,
      type: _TransactionType.received,
    ),
    _Transaction(
      name: 'Netflix Subscription',
      subtitle: 'Entertainment',
      date: 'Today',
      time: '8:15 AM',
      amount: -4500,
      type: _TransactionType.sent,
    ),
    _Transaction(
      name: 'Currency conversion',
      subtitle: 'USD → NGN',
      date: 'Yesterday',
      time: '4:52 PM',
      amount: -120,
      type: _TransactionType.convert,
    ),
    _Transaction(
      name: 'Withdrawal',
      subtitle: 'GTBank ATM',
      date: 'Yesterday',
      time: '11:30 AM',
      amount: -20000,
      type: _TransactionType.withdraw,
    ),
    _Transaction(
      name: 'Tomiwa Precious',
      subtitle: 'Transfer received',
      date: 'Mon, 21 Jul',
      time: '6:08 PM',
      amount: 15000,
      type: _TransactionType.received,
    ),
  ];



  // TODO: replace with real monthly totals.
  static const double _monthlyIncome = 620000;
  static const double _monthlyExpenses = 391000;

  // TODO: replace with live exchange rate data.
  final List<_ExchangeRate> _exchangeRates = const [
    _ExchangeRate(pair: 'USD → NGN', rate: '1,612.40', changePercent: 0.42, isUp: true),
    _ExchangeRate(pair: 'EUR → NGN', rate: '1,748.90', changePercent: 0.18, isUp: true),
    _ExchangeRate(pair: 'GBP → NGN', rate: '2,041.10', changePercent: 0.27, isUp: false),
  ];

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  String get _timeOfDayGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  Future<void> _copyAccountNumber(String accountNumber) async {
    await Clipboard.setData(ClipboardData(text: accountNumber));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
        content: Text(
          'Account number copied',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Subtle brand glow behind the header/wallet area — ties this
          // screen back to the auth flow's signature orb, at low enough
          // opacity to stay out of the way of content and legibility.
          Positioned(
            top: -140,
            right: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBlue.withOpacity(0.18),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 23, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildWalletCarousel(),
                  const SizedBox(height: 14),
                  Center(
                    child: CarouselDots(
                      itemCount: _accounts.length,
                      activeIndex: _activeCardIndex,
                    ),
                  ),
                  const SizedBox(height: _kSpacing),
                  _buildQuickActionsGrid(),
                  const SizedBox(height: _kSpacing),
                  _buildSectionHeader(
                    title: 'Recent transactions',
                    actionLabel: 'View all',
                    onActionTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const HistoryScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildTransactionsCard(),
                  const SizedBox(height: _kSpacing),
                  _buildIncomeExpenseCard(),
                  const SizedBox(height: _kSpacing),
                  _buildExchangeRatesCard(),
                  const SizedBox(height: _kSpacing),
                  _buildPromoCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Header: avatar + greeting, support / notifications / QR
  // ---------------------------------------------------------------------
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryBlue, AppColors.primaryBlueLight],
            ),
            
          ),
          // TODO: swap for the user's real profile photo (Image.network /
          // CachedNetworkImage) once avatars are wired up.
          child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _timeOfDayGreeting,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _userFullName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        _CircleIconButton(
          icon: Icons.headset_mic_rounded,
          onTap: () {
            // TODO: open customer care / support chat.
          },
        ),
        const SizedBox(width: 10),
        _CircleIconButton(
          icon: Icons.notifications_none_rounded,
          showBadge: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),

            );
          },
        ),
        const SizedBox(width: 10),
        _CircleIconButton(
          icon: Icons.qr_code_scanner_rounded,
          onTap: () {
            // TODO: open QR scan-to-pay.
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Wallet carousel
  // ---------------------------------------------------------------------
  Widget _buildWalletCarousel() {
    return SizedBox(
      height: 216,
      child: PageView.builder(
        controller: _cardController,
        itemCount: _accounts.length,
        onPageChanged: (index) => setState(() => _activeCardIndex = index),
        itemBuilder: (context, index) => _WalletCard(
          account: _accounts[index],
          onCopyTap: () => _copyAccountNumber(_accounts[index].accountNumber),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Quick actions — rounded-square cards, 4-column grid
  // ---------------------------------------------------------------------
  Widget _buildQuickActionsGrid() {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.swap_horiz_rounded,
            label: 'Transfer',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransferScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.south_west_rounded,
            label: 'Deposit',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DepositScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.north_east_rounded,
            label: 'Withdraw',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WithdrawScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.currency_exchange_rounded,
            label: 'Convert',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConvertScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  

  // ---------------------------------------------------------------------
  // Section header: title + "View all"
  // ---------------------------------------------------------------------
  Widget _buildSectionHeader({
    required String title,
    required String actionLabel,
    required VoidCallback onActionTap,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: onActionTap,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'View all',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Recent transactions card
  // ---------------------------------------------------------------------
  Widget _buildTransactionsCard() {
    return _SectionCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: List.generate(_transactions.length, (index) {
          final isLast = index == _transactions.length - 1;
          final transaction = _transactions[index];
          return Column(
            children: [
              _TransactionRow(
                transaction: transaction,
                onTap: () {
                  final visuals = _transactionVisuals(transaction.type);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionDetailScreen(
                        name: transaction.name,
                        subtitle: transaction.subtitle,
                        date: transaction.date,
                        time: transaction.time,
                        amount: transaction.amount,
                        currencySymbol: '₦',
                        icon: visuals.icon,
                        iconColor: visuals.color,
                      ),
                    ),
                  );
                },
              ),
              if (!isLast)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Divider(
                    color: AppColors.outlineBorder,
                    height: 1,
                    thickness: 1,
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  
  // ---------------------------------------------------------------------
  // Monthly income vs expenses
  // ---------------------------------------------------------------------
  Widget _buildIncomeExpenseCard() {
    final total = _monthlyIncome + _monthlyExpenses;
    final incomeRatio = total == 0 ? 0.5 : _monthlyIncome / total;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This month',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _IncomeExpenseStat(
                  icon: Icons.south_west_rounded,
                  label: 'Income',
                  amount: _monthlyIncome,
                  color: AppColors.success,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.outlineBorder,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: _IncomeExpenseStat(
                  icon: Icons.north_east_rounded,
                  label: 'Expenses',
                  amount: _monthlyExpenses,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: (incomeRatio * 1000).round(),
                    child: Container(color: AppColors.success),
                  ),
                  Expanded(
                    flex: ((1 - incomeRatio) * 1000).round(),
                    child: Container(color: AppColors.danger),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Exchange rates widget
  // ---------------------------------------------------------------------
  Widget _buildExchangeRatesCard() {
    return _SectionCard(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Exchange rates',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(_exchangeRates.length, (index) {
            final isLast = index == _exchangeRates.length - 1;
            final rate = _exchangeRates[index];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Text(
                        rate.pair,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        rate.rate,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        rate.isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        size: 13,
                        color: rate.isUp ? AppColors.success : AppColors.danger,
                      ),
                      Text(
                        '${rate.changePercent.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: rate.isUp ? AppColors.success : AppColors.danger,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(color: AppColors.outlineBorder, height: 1),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Promo card
  // ---------------------------------------------------------------------
  Widget _buildPromoCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryBlueDark, AppColors.primaryBlue],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              right: 30,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Do seamless transfers\nwith Zelyo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Send money instantly across currencies, with zero hidden fees.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Data models
// ===========================================================================

class _CurrencyAccount {
  final String code;
  final String flag;
  final String symbol;
  final String accountNumber;
  final num balance;
  final String lastUpdatedLabel;

  const _CurrencyAccount({
    required this.code,
    required this.flag,
    required this.symbol,
    required this.accountNumber,
    required this.balance,
    required this.lastUpdatedLabel,
  });
}



enum _TransactionType { received, sent, withdraw, convert }

class _Transaction {
  final String name;
  final String subtitle;
  final String date;
  final String time;
  final double amount; // positive = money in, negative = money out
  final _TransactionType type;

  const _Transaction({
    required this.name,
    required this.subtitle,
    required this.date,
    required this.time,
    required this.amount,
    required this.type,
  });
}

/// Shared between [_TransactionRow] and the tap handler that opens
/// [TransactionDetailScreen] — kept as one function so the icon/color
/// per type can't drift between the two.
({IconData icon, Color color}) _transactionVisuals(_TransactionType type) {
  switch (type) {
    case _TransactionType.received:
      return (icon: Icons.south_west_rounded, color: AppColors.success);
    case _TransactionType.sent:
      return (icon: Icons.north_east_rounded, color: AppColors.danger);
    case _TransactionType.withdraw:
      return (icon: Icons.account_balance_wallet_outlined, color: const Color(0xFFF59E0B));
    case _TransactionType.convert:
      return (icon: Icons.currency_exchange_rounded, color: AppColors.primaryBlueLight);
  }
}

class _ExchangeRate {
  final String pair;
  final String rate;
  final double changePercent;
  final bool isUp;

  const _ExchangeRate({
    required this.pair,
    required this.rate,
    required this.changePercent,
    required this.isUp,
  });
}

// ===========================================================================
// Shared small helpers
// ===========================================================================

String _formatAmount(num value) {
  final isNegative = value < 0;
  final absValue = value.abs();
  final wholePart = absValue.truncate().toString();
  final decimalPart =
      ((absValue - absValue.truncate()) * 100).round().toString().padLeft(2, '0');

  final buffer = StringBuffer();
  for (int i = 0; i < wholePart.length; i++) {
    if (i > 0 && (wholePart.length - i) % 3 == 0) buffer.write(',');
    buffer.write(wholePart[i]);
  }

  return '${isNegative ? '-' : ''}$buffer.$decimalPart';
}

// ===========================================================================
// Widgets
// ===========================================================================

/// Circular icon button used for support / notifications / QR scan, with
/// an optional small unread-indicator badge.
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.outlineBorder, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        splashColor: AppColors.primaryBlue.withOpacity(0.15),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 19),
              if (showBadge)
                Positioned(
                  top: 9,
                  right: 10,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.danger,
                      border: Border.all(color: AppColors.surface, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One swipeable wallet card — gradient, soft lighting glow, frosted
/// glass pill actions.
class _WalletCard extends StatefulWidget {
  final _CurrencyAccount account;
  final VoidCallback onCopyTap;

  const _WalletCard({required this.account, required this.onCopyTap});

  @override
  State<_WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<_WalletCard> {
  bool _isHidden = false;

  @override
  Widget build(BuildContext context) {
    final account = widget.account;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.4),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Soft lighting effect, upper-right of the card.
            Positioned(
              top: -50,
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.white.withOpacity(0.16), Colors.white.withOpacity(0)],
                  ),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ----- Currency chip -----
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(account.flag, style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 5),
                          Text(
                            account.code,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _isHidden = !_isHidden),
                      child: Icon(
                        _isHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.white.withOpacity(0.85),
                        size: 19,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ----- Balance -----
                Text(
                  _isHidden ? '${account.symbol} •••••••' : '${account.symbol} ${_formatAmount(account.balance)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // ----- Account number + copy -----
                Row(
                  children: [
                    Text(
                      account.accountNumber,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: widget.onCopyTap,
                      child: Icon(Icons.copy_rounded, color: Colors.white.withOpacity(0.7), size: 13),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  account.lastUpdatedLabel,
                  style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 11),
                ),

                const Spacer(),

                // ----- Frosted glass pill actions -----
                Row(
                  children: [
                    _FrostedPillButton(
                      icon: Icons.add_rounded,
                      label: 'Add money',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DepositScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _FrostedPillButton(
                      icon: Icons.send_rounded,
                      label: 'Send',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TransferScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _FrostedPillButton(
                      icon: Icons.history_rounded,
                      label: 'History',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoryScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A true frosted-glass pill button — blurs whatever's behind it (the
/// wallet gradient) rather than just sitting on a translucent color.
class _FrostedPillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FrostedPillButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.white.withOpacity(0.16),
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.white.withOpacity(0.18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.18)),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One quick-action rounded-square card (Transfer / Deposit / Withdraw /
/// Convert), used in a 4-column row.
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.primaryBlue.withOpacity(0.12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outlineBorder, width: 1),
          ),
          child: Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primaryBlueLight, size: 19),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable rounded card wrapper matching the app's surface/border style,
/// with a soft ambient shadow for a premium, lifted feel.
class _SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// One row inside the recent-transactions card. Now tappable — see
/// [TransactionDetailScreen].
class _TransactionRow extends StatelessWidget {
  final _Transaction transaction;
  final VoidCallback onTap;

  const _TransactionRow({required this.transaction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final visuals = _transactionVisuals(transaction.type);
    final isPositive = transaction.amount >= 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: AppColors.primaryBlue.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: visuals.color.withOpacity(0.15),
              ),
              child: Icon(visuals.icon, color: visuals.color, size: 19),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${transaction.subtitle} • ${transaction.date}, ${transaction.time}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${isPositive ? '+' : '-'}₦${_formatAmount(transaction.amount.abs())}',
              style: TextStyle(
                color: isPositive ? AppColors.success : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),

          ],
        ),
      ),
    );
  }
}

/// One stat block (Income or Expenses) inside the monthly summary card.
class _IncomeExpenseStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;

  const _IncomeExpenseStat({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.15)),
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '₦${_formatAmount(amount)}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
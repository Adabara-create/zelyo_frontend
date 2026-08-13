import 'package:flutter/material.dart';
import 'package:zelyo_1/theme/app_colors.dart';
import 'package:zelyo_1/models/transfer_models.dart';
import 'transaction_detail_screen.dart';

/// Full transaction history — filterable by category (Deposit / Withdraw
/// / Transfer / Convert) and by currency, with an expandable search
/// field tucked into the top-left of the header. This is where
/// [HomeScreen]'s "Recent transactions" → "View all" button should
/// navigate to.
///
/// All data below is sample/static — wire it up to your real
/// transaction history when ready; filtering/grouping/search all work
/// off the real fields on [_HistoryTransaction], so nothing else needs
/// to change once real data flows in.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

enum _Category { all, deposit, withdraw, transfer, convert }

String _categoryLabel(_Category category) {
  switch (category) {
    case _Category.deposit:
      return 'Deposit';
    case _Category.withdraw:
      return 'Withdraw';
    case _Category.transfer:
      return 'Transfer';
    case _Category.convert:
      return 'Convert';
    case _Category.all:
      return 'Transaction';
  }
}

class _HistoryTransaction {
  final String name;
  final String subtitle;
  final _Category category;
  final String currencyCode;
  final String currencySymbol;
  final double amount; // positive = inflow, negative = outflow
  final DateTime timestamp;

  const _HistoryTransaction({
    required this.name,
    required this.subtitle,
    required this.category,
    required this.currencyCode,
    required this.currencySymbol,
    required this.amount,
    required this.timestamp,
  });

  ({IconData icon, Color color}) get visuals {
    switch (category) {
      case _Category.deposit:
        return (icon: Icons.south_west_rounded, color: AppColors.success);
      case _Category.withdraw:
        return (icon: Icons.north_east_rounded, color: const Color(0xFFF59E0B));
      case _Category.transfer:
        return (icon: Icons.swap_horiz_rounded, color: AppColors.primaryBlueLight);
      case _Category.convert:
        return (icon: Icons.currency_exchange_rounded, color: const Color(0xFF7C5CFC));
      case _Category.all:
        return (icon: Icons.receipt_long_rounded, color: AppColors.textMuted);
    }
  }
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const List<String> _currencyOptions = ['All', 'NGN', 'USD', 'EUR', 'GBP', 'JPY'];

  bool _isSearching = false;
  String _searchQuery = '';
  _Category _selectedCategory = _Category.all;
  String _selectedCurrency = 'All';

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // TODO: replace with the user's real transaction history.
  late final List<_HistoryTransaction> _transactions = _buildSampleTransactions();

  List<_HistoryTransaction> _buildSampleTransactions() {
    final now = DateTime.now();
    return [
      _HistoryTransaction(
        name: 'David Eze',
        subtitle: 'Transfer received',
        category: _Category.transfer,
        currencyCode: 'NGN',
        currencySymbol: '₦',
        amount: 45000,
        timestamp: now.subtract(const Duration(minutes: 25)),
      ),
      _HistoryTransaction(
        name: 'Netflix Subscription',
        subtitle: 'Transfer sent',
        category: _Category.transfer,
        currencyCode: 'USD',
        currencySymbol: '\$',
        amount: -15.99,
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      _HistoryTransaction(
        name: 'Wallet top-up',
        subtitle: 'Bank transfer deposit',
        category: _Category.deposit,
        currencyCode: 'NGN',
        currencySymbol: '₦',
        amount: 100000,
        timestamp: now.subtract(const Duration(hours: 5)),
      ),
      _HistoryTransaction(
        name: 'GTBank ATM',
        subtitle: 'Cash withdrawal',
        category: _Category.withdraw,
        currencyCode: 'NGN',
        currencySymbol: '₦',
        amount: -20000,
        timestamp: now.subtract(const Duration(hours: 8)),
      ),
      _HistoryTransaction(
        name: 'USD to NGN',
        subtitle: 'Currency conversion',
        category: _Category.convert,
        currencyCode: 'USD',
        currencySymbol: '\$',
        amount: -50,
        timestamp: now.subtract(const Duration(days: 1, hours: 1)),
      ),
      _HistoryTransaction(
        name: 'Tomiwa Precious',
        subtitle: 'Transfer received',
        category: _Category.transfer,
        currencyCode: 'NGN',
        currencySymbol: '₦',
        amount: 15000,
        timestamp: now.subtract(const Duration(days: 1, hours: 4)),
      ),
      _HistoryTransaction(
        name: 'Card deposit',
        subtitle: 'Debit card top-up',
        category: _Category.deposit,
        currencyCode: 'USD',
        currencySymbol: '\$',
        amount: 500,
        timestamp: now.subtract(const Duration(days: 1, hours: 9)),
      ),
      _HistoryTransaction(
        name: 'Rent payment',
        subtitle: 'Transfer sent',
        category: _Category.transfer,
        currencyCode: 'GBP',
        currencySymbol: '£',
        amount: -650,
        timestamp: now.subtract(const Duration(days: 3)),
      ),
      _HistoryTransaction(
        name: 'Access Bank',
        subtitle: 'Bank withdrawal',
        category: _Category.withdraw,
        currencyCode: 'EUR',
        currencySymbol: '€',
        amount: -200,
        timestamp: now.subtract(const Duration(days: 4)),
      ),
      _HistoryTransaction(
        name: 'EUR to GBP',
        subtitle: 'Currency conversion',
        category: _Category.convert,
        currencyCode: 'EUR',
        currencySymbol: '€',
        amount: -300,
        timestamp: now.subtract(const Duration(days: 6)),
      ),
      _HistoryTransaction(
        name: 'Moyo Adebayo',
        subtitle: 'Transfer received',
        category: _Category.transfer,
        currencyCode: 'NGN',
        currencySymbol: '₦',
        amount: 32000,
        timestamp: now.subtract(const Duration(days: 9)),
      ),
      _HistoryTransaction(
        name: 'Salary',
        subtitle: 'Bank transfer deposit',
        category: _Category.deposit,
        currencyCode: 'NGN',
        currencySymbol: '₦',
        amount: 620000,
        timestamp: now.subtract(const Duration(days: 12)),
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
    if (_isSearching) {
      Future.delayed(const Duration(milliseconds: 50), () => _searchFocusNode.requestFocus());
    }
  }

  Future<void> _pickCurrency() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _CurrencyFilterSheet(
        options: _currencyOptions,
        selected: _selectedCurrency,
      ),
    );
    if (picked != null) setState(() => _selectedCurrency = picked);
  }

  void _onTransactionTap(_HistoryTransaction transaction) {
    final visuals = transaction.visuals;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransactionDetailScreen(
          name: transaction.name,
          subtitle: transaction.subtitle,
          date: _formatDate(transaction.timestamp),
          time: _formatTime(transaction.timestamp),
          amount: transaction.amount,
          currencySymbol: transaction.currencySymbol,
          icon: visuals.icon,
          iconColor: visuals.color,
          category: _categoryLabel(transaction.category),
        ),
      ),
    );
  }

  List<_HistoryTransaction> get _filteredTransactions {
    return _transactions.where((t) {
      final matchesCategory = _selectedCategory == _Category.all || t.category == _selectedCategory;
      final matchesCurrency = _selectedCurrency == 'All' || t.currencyCode == _selectedCurrency;
      final matchesSearch = _searchQuery.isEmpty ||
          t.name.toLowerCase().contains(_searchQuery) ||
          t.subtitle.toLowerCase().contains(_searchQuery);
      return matchesCategory && matchesCurrency && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupByDate(_filteredTransactions);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 14),
            _buildCategoryChips(),
            const SizedBox(height: 12),
            _buildCurrencyFilterPill(),
            const SizedBox(height: 4),
            Expanded(
              child: groups.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: groups.length,
                      itemBuilder: (context, groupIndex) {
                        final group = groups[groupIndex];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: groupIndex == 0 ? 4 : 18, bottom: 10),
                              child: Text(
                                group.label,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.outlineBorder, width: 1),
                              ),
                              child: Column(
                                children: List.generate(group.items.length, (index) {
                                  final isLast = index == group.items.length - 1;
                                  final transaction = group.items[index];
                                  return Column(
                                    children: [
                                      _HistoryRow(
                                        transaction: transaction,
                                        onTap: () => _onTransactionTap(transaction),
                                      ),
                                      if (!isLast)
                                        const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 16),
                                          child: Divider(color: AppColors.outlineBorder, height: 1),
                                        ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Header: back button, search icon <-> expanding search field
  // ---------------------------------------------------------------------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: _isSearching
            ? Row(
                key: const ValueKey('searching'),
                children: [
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.4), width: 1.2),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 19),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                              cursorColor: AppColors.primaryBlue,
                              decoration: const InputDecoration(
                                hintText: 'Search transactions',
                                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (value) => setState(() => _searchQuery = value.trim().toLowerCase()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleSearch,
                    icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary, size: 22),
                  ),
                ],
              )
            : Row(
                key: const ValueKey('idle'),
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
                  ),
                  IconButton(
                    onPressed: _toggleSearch,
                    icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary, size: 22),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'History',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 19, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Category filter chips
  // ---------------------------------------------------------------------
  Widget _buildCategoryChips() {
    const categories = [
      (_Category.all, 'All'),
      (_Category.deposit, 'Deposit'),
      (_Category.withdraw, 'Withdraw'),
      (_Category.transfer, 'Transfer'),
      (_Category.convert, 'Convert'),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (category, label) = categories[index];
          final isSelected = _selectedCategory == category;
          return InkWell(
            onTap: () => setState(() => _selectedCategory = category),
            borderRadius: BorderRadius.circular(999),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : AppColors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : AppColors.outlineBorder,
                  width: 1,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Currency filter pill
  // ---------------------------------------------------------------------
  Widget _buildCurrencyFilterPill() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: _pickCurrency,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.outlineBorder, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.language_rounded, color: AppColors.primaryBlueLight, size: 14),
                const SizedBox(width: 6),
                Text(
                  _selectedCurrency == 'All' ? 'All currencies' : _selectedCurrency,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryBlue.withOpacity(0.12)),
              child: const Icon(Icons.search_off_rounded, color: AppColors.primaryBlueLight, size: 34),
            ),
            const SizedBox(height: 18),
            const Text(
              'No transactions found',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a different search term or adjust your filters.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Grouping
// ===========================================================================

class _HistoryGroup {
  final String label;
  final List<_HistoryTransaction> items;

  const _HistoryGroup({required this.label, required this.items});
}

List<_HistoryGroup> _groupByDate(List<_HistoryTransaction> items) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final weekAgo = today.subtract(const Duration(days: 7));

  final todayItems = <_HistoryTransaction>[];
  final yesterdayItems = <_HistoryTransaction>[];
  final thisWeekItems = <_HistoryTransaction>[];
  final earlierItems = <_HistoryTransaction>[];

  for (final item in items) {
    final itemDay = DateTime(item.timestamp.year, item.timestamp.month, item.timestamp.day);
    if (itemDay == today) {
      todayItems.add(item);
    } else if (itemDay == yesterday) {
      yesterdayItems.add(item);
    } else if (itemDay.isAfter(weekAgo)) {
      thisWeekItems.add(item);
    } else {
      earlierItems.add(item);
    }
  }

  return [
    if (todayItems.isNotEmpty) _HistoryGroup(label: 'Today', items: todayItems),
    if (yesterdayItems.isNotEmpty) _HistoryGroup(label: 'Yesterday', items: yesterdayItems),
    if (thisWeekItems.isNotEmpty) _HistoryGroup(label: 'This week', items: thisWeekItems),
    if (earlierItems.isNotEmpty) _HistoryGroup(label: 'Earlier', items: earlierItems),
  ];
}

String _formatTime(DateTime timestamp) {
  final hour = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
  final minute = timestamp.minute.toString().padLeft(2, '0');
  final period = timestamp.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

const List<String> _monthAbbreviations = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatDate(DateTime timestamp) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final itemDay = DateTime(timestamp.year, timestamp.month, timestamp.day);

  if (itemDay == today) return 'Today';
  if (itemDay == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return '${timestamp.day} ${_monthAbbreviations[timestamp.month - 1]} ${timestamp.year}';
}

// ===========================================================================
// Widgets
// ===========================================================================

class _HistoryRow extends StatelessWidget {
  final _HistoryTransaction transaction;
  final VoidCallback onTap;

  const _HistoryRow({required this.transaction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final visuals = transaction.visuals;
    final isPositive = transaction.amount >= 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: AppColors.primaryBlue.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(shape: BoxShape.circle, color: visuals.color.withOpacity(0.15)),
              child: Icon(visuals.icon, color: visuals.color, size: 19),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.name,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${transaction.subtitle} • ${_formatTime(transaction.timestamp)}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isPositive ? '+' : '-'}${transaction.currencySymbol}${formatAmount(transaction.amount.abs())}',
                  style: TextStyle(
                    color: isPositive ? AppColors.success : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.currencyCode,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 10.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}

class _CurrencyFilterSheet extends StatelessWidget {
  final List<String> options;
  final String selected;

  const _CurrencyFilterSheet({required this.options, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: AppColors.outlineBorder, borderRadius: BorderRadius.circular(4)),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Filter by currency', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 16),
          ...options.map((code) {
            final isSelected = code == selected;
            return InkWell(
              onTap: () => Navigator.of(context).pop(code),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Text(
                      code == 'All' ? 'All currencies' : code,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue, size: 20),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:zelyo_1/theme/app_colors.dart';

/// Notifications screen — grouped by recency (Today / Yesterday / This
/// week / Earlier), swipe-to-dismiss, unread state, and a "mark all
/// read" action. Pushed from the bell icon on [HomeScreen].
///
/// All data below is sample/static — wire it up to your real
/// notifications source (backend, push payloads, local store) when
/// ready. The grouping logic works off each item's real [DateTime], so
/// once real data flows in, the sections keep working without changes.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // TODO: replace with real notifications from your backend / push store.
  late List<_NotificationItem> _notifications = _buildSampleNotifications();

  List<_NotificationItem> _buildSampleNotifications() {
    final now = DateTime.now();
    return [
      _NotificationItem(
        id: '1',
        type: _NotificationType.transaction,
        title: 'Money received',
        message: 'David Eze sent you ₦45,000.',
        timestamp: now.subtract(const Duration(minutes: 12)),
        isRead: false,
      ),
      _NotificationItem(
        id: '2',
        type: _NotificationType.security,
        title: 'New device login',
        message: 'Your account was accessed from a new iPhone in Lagos.',
        timestamp: now.subtract(const Duration(hours: 3)),
        isRead: false,
      ),
      _NotificationItem(
        id: '3',
        type: _NotificationType.system,
        title: 'Scheduled maintenance',
        message: 'Transfers may be briefly delayed tonight between 1–2 AM.',
        timestamp: now.subtract(const Duration(hours: 7)),
        isRead: true,
      ),
      _NotificationItem(
        id: '4',
        type: _NotificationType.transaction,
        title: 'Withdrawal successful',
        message: '₦20,000 was withdrawn at a GTBank ATM.',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        isRead: true,
      ),
      _NotificationItem(
        id: '5',
        type: _NotificationType.reward,
        title: 'Cashback earned',
        message: 'You earned ₦850 cashback on your Netflix payment.',
        timestamp: now.subtract(const Duration(days: 1, hours: 5)),
        isRead: true,
      ),
      _NotificationItem(
        id: '6',
        type: _NotificationType.promo,
        title: 'Zero-fee weekend',
        message: 'Send money to any Zelyo user for free, this weekend only.',
        timestamp: now.subtract(const Duration(days: 3)),
        isRead: true,
      ),
      _NotificationItem(
        id: '7',
        type: _NotificationType.security,
        title: 'Password changed',
        message: 'Your account password was changed successfully.',
        timestamp: now.subtract(const Duration(days: 6)),
        isRead: true,
      ),
    ];
  }

  bool get _hasUnread => _notifications.any((item) => !item.isRead);

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications
          .map((item) => item.copyWith(isRead: true))
          .toList();
    });
  }

  void _markAsRead(String id) {
    if (_notifications.firstWhere((item) => item.id == id).isRead) return;
    setState(() {
      _notifications = _notifications
          .map((item) => item.id == id ? item.copyWith(isRead: true) : item)
          .toList();
    });
  }

  void _dismiss(String id) {
    setState(() {
      _notifications = _notifications.where((item) => item.id != id).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupNotifications(_notifications);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _notifications.isEmpty
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
                              padding: EdgeInsets.only(
                                top: groupIndex == 0 ? 4 : 20,
                                bottom: 12,
                              ),
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
                            ...group.items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _NotificationCard(
                                  item: item,
                                  onTap: () => _markAsRead(item.id),
                                  onDismiss: () => _dismiss(item.id),
                                ),
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
  // Header: back button, title, "mark all read"
  // ---------------------------------------------------------------------
  Widget _buildHeader() {
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
          const Expanded(
            child: Text(
              'Notifications',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (_hasUnread)
            TextButton(
              onPressed: _markAllAsRead,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Empty state
  // ---------------------------------------------------------------------
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue.withOpacity(0.12),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.primaryBlueLight,
                size: 38,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "You're all caught up",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'New notifications about your account and transactions will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Grouping logic
// ===========================================================================

class _NotificationGroup {
  final String label;
  final List<_NotificationItem> items;

  const _NotificationGroup({required this.label, required this.items});
}

List<_NotificationGroup> _groupNotifications(List<_NotificationItem> items) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final weekAgo = today.subtract(const Duration(days: 7));

  final todayItems = <_NotificationItem>[];
  final yesterdayItems = <_NotificationItem>[];
  final thisWeekItems = <_NotificationItem>[];
  final earlierItems = <_NotificationItem>[];

  for (final item in items) {
    final itemDay = DateTime(
      item.timestamp.year,
      item.timestamp.month,
      item.timestamp.day,
    );
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
    if (todayItems.isNotEmpty) _NotificationGroup(label: 'Today', items: todayItems),
    if (yesterdayItems.isNotEmpty) _NotificationGroup(label: 'Yesterday', items: yesterdayItems),
    if (thisWeekItems.isNotEmpty) _NotificationGroup(label: 'This week', items: thisWeekItems),
    if (earlierItems.isNotEmpty) _NotificationGroup(label: 'Earlier', items: earlierItems),
  ];
}

String _formatTime(DateTime timestamp) {
  final hour = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
  final minute = timestamp.minute.toString().padLeft(2, '0');
  final period = timestamp.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

// ===========================================================================
// Data model
// ===========================================================================

enum _NotificationType { transaction, security, promo, system, reward }

class _NotificationItem {
  final String id;
  final _NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  const _NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });

  _NotificationItem copyWith({bool? isRead}) {
    return _NotificationItem(
      id: id,
      type: type,
      title: title,
      message: message,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  ({IconData icon, Color color}) get visuals {
    switch (type) {
      case _NotificationType.transaction:
        return (icon: Icons.swap_horiz_rounded, color: AppColors.primaryBlueLight);
      case _NotificationType.security:
        return (icon: Icons.shield_outlined, color: AppColors.danger);
      case _NotificationType.promo:
        return (icon: Icons.local_offer_outlined, color: const Color(0xFF7C5CFC));
      case _NotificationType.system:
        return (icon: Icons.info_outline_rounded, color: const Color(0xFF14B8A6));
      case _NotificationType.reward:
        return (icon: Icons.card_giftcard_rounded, color: const Color(0xFFF59E0B));
    }
  }
}

// ===========================================================================
// Notification card, with swipe-to-dismiss
// ===========================================================================

class _NotificationCard extends StatelessWidget {
  final _NotificationItem item;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.item,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = item.visuals;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        margin: const EdgeInsets.only(bottom: 0),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 22),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: AppColors.primaryBlue.withOpacity(0.08),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: item.isRead ? AppColors.surface : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: item.isRead
                    ? AppColors.outlineBorder
                    : AppColors.primaryBlue.withOpacity(0.35),
                width: 1,
              ),
              boxShadow: item.isRead
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14.5,
                                fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!item.isRead) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.message,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(item.timestamp),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
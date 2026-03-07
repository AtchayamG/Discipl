import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/theme_utils.dart';
import '../../../providers/app_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Notifications Screen
// ─────────────────────────────────────────────────────────────────────────────
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    final provider = context.watch<AppProvider>();
    final notifications = provider.notifications;
    final unread = provider.unreadCount;

    return Scaffold(
      backgroundColor: tc.pageBg,
      appBar: AppBar(
        backgroundColor: tc.topBarBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 18, color: tc.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: TextStyle(
                fontFamily: AppTypography.displayFont,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: tc.textPrimary,
              ),
            ),
            if (unread > 0)
              Text(
                '$unread unread',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFont,
                  fontSize: 11,
                  color: tc.lime,
                ),
              ),
          ],
        ),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () => provider.markAllNotificationsRead(),
              child: Text(
                'Mark all read',
                style: TextStyle(
                  fontFamily: AppTypography.displayFont,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: tc.lime,
                ),
              ),
            ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: tc.border),
        ),
      ),
      body: notifications.isEmpty
          ? _EmptyNotifications(tc: tc)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              itemBuilder: (context, i) {
                final n = notifications[i];
                return _NotificationTile(
                  notification: n,
                  onTap: () => provider.markNotificationRead(n['id'] as String),
                  onDismiss: () => provider.deleteNotification(n['id'] as String),
                );
              },
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification Tile
// ─────────────────────────────────────────────────────────────────────────────
class _NotificationTile extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final tc = TC.of(context);
    final isUnread = notification['read'] == false;
    final type = notification['type'] as String? ?? '';

    return Dismissible(
      key: Key(notification['id'] as String),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: const Color(AppColors.red).withOpacity(0.12),
        child: const Icon(Icons.delete_outline_rounded, color: Color(AppColors.red), size: 22),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUnread
                ? (tc.isDark ? const Color(0xFF0F1A0A) : const Color(AppColors.limeLightBg))
                : tc.cardBg,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: isUnread ? tc.limeBorder : tc.border,
              width: isUnread ? 1.5 : 1,
            ),
            boxShadow: tc.cardShadow,
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Icon circle
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: _iconBg(type, tc),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _iconBorderColor(type, tc)),
              ),
              child: Center(
                child: Icon(_iconData(type), size: 18, color: _iconColor(type, tc)),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Text(
                      notification['title'] as String? ?? '',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFont,
                        fontSize: 13,
                        fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                        color: tc.textPrimary,
                      ),
                    ),
                  ),
                  if (isUnread)
                    Container(
                      width: 8, height: 8,
                      margin: const EdgeInsets.only(left: 8, top: 2),
                      decoration: BoxDecoration(
                        color: tc.lime,
                        shape: BoxShape.circle,
                      ),
                    ),
                ]),
                const SizedBox(height: 4),
                Text(
                  notification['body'] as String? ?? '',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFont,
                    fontSize: 12,
                    color: tc.textMuted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  notification['time'] as String? ?? '',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFont,
                    fontSize: 10,
                    color: tc.textMuted2,
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  IconData _iconData(String type) {
    switch (type) {
      case 'streak':      return Icons.local_fire_department_rounded;
      case 'habit':       return Icons.check_circle_outline_rounded;
      case 'achievement': return Icons.emoji_events_rounded;
      case 'community':   return Icons.people_outline_rounded;
      case 'ai':          return Icons.auto_awesome_outlined;
      case 'challenge':   return Icons.flag_outlined;
      case 'workout':     return Icons.fitness_center_rounded;
      case 'leaderboard': return Icons.leaderboard_rounded;
      default:            return Icons.notifications_outlined;
    }
  }

  Color _iconBg(String type, TC tc) {
    switch (type) {
      case 'streak':
      case 'habit':       return tc.limeBg;
      case 'achievement':
      case 'challenge':   return const Color(0x1FFF7A3D);
      case 'community':   return const Color(0x1F3DD6C8);
      case 'ai':          return const Color(0x1F9D7FEA);
      case 'workout':     return tc.limeBg;
      case 'leaderboard': return const Color(0x1FFF7A3D);
      default:            return tc.cardBg2;
    }
  }

  Color _iconBorderColor(String type, TC tc) {
    switch (type) {
      case 'streak':
      case 'habit':
      case 'workout':     return tc.limeBorder;
      case 'achievement':
      case 'challenge':
      case 'leaderboard': return const Color(AppColors.orange).withOpacity(0.25);
      case 'community':   return const Color(AppColors.teal).withOpacity(0.25);
      case 'ai':          return const Color(AppColors.violet).withOpacity(0.25);
      default:            return tc.border;
    }
  }

  Color _iconColor(String type, TC tc) {
    switch (type) {
      case 'streak':
      case 'habit':
      case 'workout':     return tc.limeIcon;
      case 'achievement':
      case 'challenge':
      case 'leaderboard': return const Color(AppColors.orange);
      case 'community':   return const Color(AppColors.teal);
      case 'ai':          return const Color(AppColors.violet);
      default:            return tc.textMuted;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyNotifications extends StatelessWidget {
  final TC tc;
  const _EmptyNotifications({required this.tc});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: tc.limeBg,
            shape: BoxShape.circle,
            border: Border.all(color: tc.limeBorder),
          ),
          child: Icon(Icons.notifications_none_rounded, size: 32, color: tc.limeIcon),
        ),
        const SizedBox(height: 16),
        Text(
          'All caught up!',
          style: TextStyle(
            fontFamily: AppTypography.displayFont,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: tc.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'No notifications right now.\nCheck back later.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.bodyFont,
            fontSize: 13,
            color: tc.textMuted,
            height: 1.5,
          ),
        ),
      ]),
    );
  }
}

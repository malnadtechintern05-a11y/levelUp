import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshNotifications();
    });
  }

  Future<void> _refreshNotifications() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      await context.read<AppState>().fetchOnlineNotifications();
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24 && dt.day == now.day) {
      return 'Today, ${DateFormat('h:mm a').format(dt)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${DateFormat('h:mm a').format(dt)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(dt);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Fitness':
        return Colors.redAccent;
      case 'Study':
        return Colors.blueAccent;
      case 'Health':
        return Colors.green;
      case 'Work':
        return Colors.purpleAccent;
      case 'LevelUp':
      case 'Achievement':
        return const Color(0xFFF5B942);
      case 'Personal':
      default:
        return const Color(0xFF38BDF8);
    }
  }

  IconData _getCategoryIcon(String category, String type) {
    if (type == 'levelUp') return Icons.military_tech;
    if (type == 'achievement') return Icons.emoji_events;
    switch (category) {
      case 'Fitness':
        return Icons.fitness_center;
      case 'Study':
        return Icons.menu_book;
      case 'Health':
        return Icons.favorite;
      case 'Work':
        return Icons.work;
      case 'Personal':
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = context.watch<AppState>();
    final notifications = state.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF5B942)),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Sync Notifications',
            onPressed: _refreshNotifications,
          ),
          if (notifications.isNotEmpty) ...[
            TextButton(
              onPressed: () => state.markAllNotificationsAsRead(),
              child: const Text('Mark all read', style: TextStyle(color: Color(0xFFF5B942), fontWeight: FontWeight.bold)),
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear all',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear all notifications?'),
                    content: const Text('This will remove all notification history.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                        onPressed: () {
                          Navigator.pop(ctx);
                          state.clearAllNotifications();
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        color: const Color(0xFFF5B942),
        backgroundColor: isDark ? const Color(0xFF162033) : Colors.white,
        child: notifications.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (isDark ? const Color(0xFF162033) : const Color(0xFFF1F5F9)),
                          ),
                          child: Icon(
                            Icons.notifications_off_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No Notifications Yet',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pull down to refresh. Broadcasts from the Realm Admin, quest alerts, and milestone rewards will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  final color = _getCategoryColor(notif.category);
                  final cardBg = isDark
                      ? (notif.isRead ? const Color(0xFF162033) : const Color(0xFF1E293B))
                      : (notif.isRead ? Colors.white : const Color(0xFFF8FAFC));
                  final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: !notif.isRead ? const Color(0xFFF5B942).withValues(alpha: 0.6) : borderColor,
                        width: !notif.isRead ? 1.5 : 1,
                      ),
                      boxShadow: [
                        if (!notif.isRead)
                          BoxShadow(
                            color: const Color(0xFFF5B942).withValues(alpha: isDark ? 0.1 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          if (!notif.isRead) {
                            state.markNotificationAsRead(notif.id);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category Icon
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color.withValues(alpha: 0.15),
                                  border: Border.all(color: color.withValues(alpha: 0.4)),
                                  ),
                                child: Icon(
                                  _getCategoryIcon(notif.category, notif.type),
                                  color: color,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Notification Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            notif.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: theme.colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                        if (!notif.isRead)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFFF5B942),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notif.body,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: theme.colorScheme.onSurfaceVariant,
                                        height: 1.4,
                                      ),
                                    ),
                                    if (notif.motivationalQuote != null && notif.motivationalQuote!.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF5B942).withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          notif.motivationalQuote!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFF5B942),
                                          ),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        if (notif.xpReward != null && notif.xpReward! > 0) ...[
                                          Text(
                                            '+${notif.xpReward} XP',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? const Color(0xFF4CAF50) : const Color(0xFF16A34A),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text('•', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                                          const SizedBox(width: 8),
                                        ],
                                        Text(
                                          _formatTimestamp(notif.timestamp),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                                          ),
                                        ),
                                      ],
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
                },
              ),
      ),
    );
  }
}

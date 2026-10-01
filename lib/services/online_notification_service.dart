import '../models/models.dart';
import 'api_client.dart';

/// Service for synchronizing notifications with the LevelUp backend.
class OnlineNotificationService {
  static final OnlineNotificationService instance = OnlineNotificationService._internal();
  OnlineNotificationService._internal();

  /// Fetches the latest notifications (announcements & user-specific alerts) from the server.
  Future<List<AppNotification>> fetchNotifications() async {
    try {
      final response = await ApiClient.instance.get('/notifications/list.php');
      if (response['status'] == 'success' && response['data'] is List) {
        final list = (response['data'] as List).map((item) {
          DateTime parsedTime = DateTime.tryParse(item['created_at']?.toString() ?? '') ?? DateTime.now();
          final isRead = item['is_read'] == true || item['is_read'] == 1 || item['is_read'] == '1';
          final rawCat = item['category']?.toString().trim() ?? '';
          final category = rawCat.isNotEmpty ? rawCat : 'System';

          return AppNotification(
            id: item['id']?.toString() ?? '',
            title: item['title']?.toString() ?? 'LevelUp Alert',
            body: item['message']?.toString() ?? item['body']?.toString() ?? '',
            category: category,
            type: item['type']?.toString() ?? 'announcement',
            timestamp: parsedTime,
            isRead: isRead,
          );
        }).toList();
        return list;
      }
    } catch (e) {
      // Offline fallback
    }
    return [];
  }

  /// Marks a specific notification as read on the server.
  Future<void> markAsRead(String notifId) async {
    try {
      await ApiClient.instance.post('/notifications/list.php', body: {'id': notifId});
    } catch (_) {}
  }

  /// Marks all notifications as read on the server.
  Future<void> markAllAsRead() async {
    try {
      await ApiClient.instance.post('/notifications/list.php', body: {});
    } catch (_) {}
  }
}

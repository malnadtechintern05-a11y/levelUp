import '../models/models.dart';
import 'api_client.dart';

class OnlineAchievementService {
  static final OnlineAchievementService instance = OnlineAchievementService._internal();
  OnlineAchievementService._internal();

  Future<List<Achievement>> fetchAchievements() async {
    final response = await ApiClient.instance.get('/achievements/list.php');
    if (response['status'] == 'success' && response['data'] is List) {
      final list = (response['data'] as List).map((item) {
        return Achievement(
          id: item['id']?.toString() ?? '',
          name: item['name']?.toString() ?? '',
          description: item['description']?.toString() ?? '',
          xpReward: int.tryParse(item['xp_reward']?.toString() ?? '0') ?? 0,
          unlockRequirement: item['unlock_requirement']?.toString() ?? '',
          iconPath: item['icon_path']?.toString(),
          isUnlocked: item['is_unlocked'] == true || item['is_unlocked'] == 1,
        );
      }).toList();
      return list;
    }
    return [];
  }
}

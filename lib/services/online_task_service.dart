import '../models/models.dart';
import 'api_client.dart';

class OnlineTaskService {
  static final OnlineTaskService instance = OnlineTaskService._internal();
  OnlineTaskService._internal();

  Future<List<RPGTask>> fetchTasks() async {
    final response = await ApiClient.instance.get('/tasks/list.php');
    if (response['status'] == 'success' && response['data'] is List) {
      final list = (response['data'] as List).map((item) {
        DateTime parsedDue = DateTime.tryParse(item['scheduled_date']?.toString() ?? '') ?? DateTime.now();
        return RPGTask(
          id: item['id']?.toString() ?? '',
          title: item['title']?.toString() ?? '',
          description: item['description']?.toString() ?? '',
          category: item['category']?.toString() ?? 'Personal',
          xpReward: int.tryParse(item['xp_reward']?.toString() ?? '50') ?? 50,
          isCompleted: item['is_completed'] == true || item['is_completed'] == 1,
          dueDate: parsedDue,
          time: item['scheduled_time']?.toString(),
          durationMinutes: int.tryParse(item['duration_minutes']?.toString() ?? '30') ?? 30,
          remainingSeconds: (item['is_completed'] == true) ? 0 : (int.tryParse(item['duration_minutes']?.toString() ?? '30') ?? 30) * 60,
          timeSpentSeconds: int.tryParse(item['time_spent_seconds']?.toString() ?? '0') ?? 0,
          timerStatus: item['timer_status']?.toString() ?? 'Not Started',
          taskType: item['task_type']?.toString() ?? 'normal',
          waterGoalMl: int.tryParse(item['water_goal_ml']?.toString() ?? '2500') ?? 2500,
          currentWaterMl: int.tryParse(item['current_water_ml']?.toString() ?? '0') ?? 0,
        );
      }).toList();
      return list;
    }
    return [];
  }

  Future<RPGTask> createTask(RPGTask task) async {
    final dateStr = "${task.dueDate.year}-${task.dueDate.month.toString().padLeft(2, '0')}-${task.dueDate.day.toString().padLeft(2, '0')}";

    final response = await ApiClient.instance.post('/tasks/create.php', body: {
      'title': task.title,
      'description': task.description,
      'category': task.category,
      'xp_reward': task.xpReward,
      'scheduled_date': dateStr,
      'scheduled_time': task.time ?? '12:00',
      'duration_minutes': task.durationMinutes,
      'task_type': task.taskType,
      'water_goal_ml': task.waterGoalMl,
    });

    if (response['status'] == 'success' && response['data'] != null) {
      final d = response['data'];
      return RPGTask(
        id: d['id'].toString(),
        title: d['title'].toString(),
        description: d['description'].toString(),
        category: d['category'].toString(),
        xpReward: d['xp_reward'] as int,
        isCompleted: false,
        dueDate: task.dueDate,
        time: task.time,
        durationMinutes: task.durationMinutes,
        remainingSeconds: task.durationMinutes * 60,
        taskType: task.taskType,
        waterGoalMl: task.waterGoalMl,
        currentWaterMl: 0,
      );
    }
    throw ApiException('Failed to create quest on server.');
  }

  Future<Map<String, dynamic>> completeTask(String taskId) async {
    final response = await ApiClient.instance.post('/tasks/complete.php', body: {
      'task_id': taskId,
    });
    return response;
  }

  Future<void> deleteTask(String taskId) async {
    await ApiClient.instance.post('/tasks/delete.php', body: {
      'task_id': taskId,
    });
  }
}

import 'api_client.dart';

class OnlineHydrationService {
  static final OnlineHydrationService instance = OnlineHydrationService._internal();
  OnlineHydrationService._internal();

  Future<Map<String, dynamic>> addWater(int amountMl, {String? taskId}) async {
    final response = await ApiClient.instance.post('/hydration/add.php', body: {
      'amount_ml': amountMl,
      'task_id': taskId,
    });
    return response;
  }

  Future<Map<String, dynamic>> fetchHistory() async {
    final response = await ApiClient.instance.get('/hydration/history.php');
    return response;
  }
}

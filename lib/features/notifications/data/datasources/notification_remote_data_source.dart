import 'package:flutter_tcc/core/network/dio_client.dart';
import 'package:flutter_tcc/features/notifications/data/models/notification_model.dart';

class NotificationRemoteDataSource {
  final DioClient dioClient;

  NotificationRemoteDataSource({required this.dioClient});

  Future<List<NotificationModel>> fetchUnread() async {
    final response = await dioClient.dio.get('/notifications', queryParameters: {'unread': 'true'});
    final list = response.data as List;
    return list.map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<List<NotificationModel>> fetchAll() async {
    final response = await dioClient.dio.get('/notifications');
    final list = response.data as List;
    return list.map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<int> fetchUnreadCount() async {
    final response = await dioClient.dio.get('/notifications/count');
    return response.data['count'] as int;
  }

  Future<void> markAsRead(String id) async {
    await dioClient.dio.patch('/notifications/$id/read');
  }

  Future<void> markMultipleAsRead(List<String> ids) async {
    await dioClient.dio.patch('/notifications/read', data: {'ids': ids});
  }
}

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_tcc/core/network/dio_client.dart';
import 'package:flutter_tcc/features/profile/data/models/project_model.dart';

abstract class ProfileRemoteDataSource {
  Future<List<ProjectModel>> getProjects();
  Future<String> updateOrganizationAvatar(File file);
  Future<void> updateOrganizationName(String name);
  Future<void> updateUserName(String name);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient dioClient;

  ProfileRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<ProjectModel>> getProjects() async {
    try {
      final response = await dioClient.dio.get('/projects');
      final list = response.data as List<dynamic>;
      return list
          .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final message = e.response?.data['message'];
        if (message != null) {
          throw Exception(message);
        }
      }
      rethrow;
    }
  }

  @override
  Future<String> updateOrganizationAvatar(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });
      final response = await dioClient.dio.post(
        '/organizations/avatar',
        data: formData,
      );
      return response.data['avatarUrl'] as String;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final message = e.response?.data['message'];
        if (message != null) {
          throw Exception(message);
        }
      }
      rethrow;
    }
  }

  @override
  Future<void> updateOrganizationName(String name) async {
    try {
      await dioClient.dio.patch(
        '/organizations/name',
        data: {'name': name},
      );
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final message = e.response?.data['message'];
        if (message != null) {
          throw Exception(message);
        }
      }
      rethrow;
    }
  }

  @override
  Future<void> updateUserName(String name) async {
    try {
      await dioClient.dio.patch(
        '/users/profile',
        data: {'name': name},
      );
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final message = e.response?.data['message'];
        if (message != null) {
          throw Exception(message);
        }
      }
      rethrow;
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../router/app_router.dart';

class AuthGuard {
  static bool handleUnauthorized(BuildContext context, dynamic error) {
    int? statusCode;
    if (error is DioException) {
      statusCode = error.response?.statusCode;
    } else if (error is ApiException) {
      statusCode = error.statusCode;
    }

    if (statusCode == 401) {
      context.go(AppRoutes.login);
      return true;
    }
    if (statusCode == 403) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu amal uchun ruxsat yo\'q'),
          backgroundColor: Colors.red,
        ),
      );
      return true;
    }
    return false;
  }
}

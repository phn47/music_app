import 'package:client/core/constants/server_constant.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'dio_provider.g.dart';

@Riverpod(keepAlive: true)
Dio dio(DioRef ref) {
  final dio = Dio();
  // Cấu hình dio ở đây
  dio.options.baseUrl = kIsWeb
      ? 'http://127.0.0.1:8000' // URL cho web
      : 'http://10.0.2.2:8000'; // URL cho Android emulator

  dio.options.headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  dio.interceptors.add(LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
  ));

  return dio;
}

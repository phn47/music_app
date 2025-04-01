import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:artist/models/album.dart';
import '../core/constants/server_constant.dart';

class AlbumService {
  final storage = const FlutterSecureStorage();
  final String baseUrl = '${ServerConstant.serverURL}/albums';

  Future<String> getToken() async {
    return await storage.read(key: 'token') ?? '';
  }
}

import 'package:client/core/constants/server_constant.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/features/home/models/genre_model.dart';
//import 'package:client/features/home/repositories/home_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Provider để lấy danh sách thể loại
final genresProvider = FutureProvider<List<GenreModel>>((ref) async {
  final token = ref.read(currentUserNotifierProvider)!.token;

  final response = await http.get(
    Uri.parse('${ServerConstant.serverURL}/genre/list'),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'x-auth-token': token,
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Không thể lấy danh sách thể loại');
  }

  final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
  return data.map((e) => GenreModel.fromMap(e)).toList();
});

// Provider để lấy chi tiết một thể loại
final genreDetailProvider =
    FutureProvider.family<GenreModel, String>((ref, genreId) async {
  final token = ref.read(currentUserNotifierProvider)!.token;

  final response = await http.get(
    Uri.parse('${ServerConstant.serverURL}/genre/$genreId'),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'x-auth-token': token,
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Không thể lấy thông tin thể loại');
  }

  final data = jsonDecode(utf8.decode(response.bodyBytes));
  return GenreModel.fromMap(data);
});

final genresSongProvider = FutureProvider<List<GenreModel>>((ref) async {
  final token = ref.read(currentUserNotifierProvider)!.token;

  final response = await http.get(
    Uri.parse('${ServerConstant.serverURL}/songs/genres'),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'x-auth-token': token,
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Không thể lấy danh sách thể loại');
  }

  final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
  return data.map((e) => GenreModel.fromMap(e)).toList();
});

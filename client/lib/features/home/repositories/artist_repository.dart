import 'dart:convert';
import 'dart:io';
import 'package:client/core/failure/failure.dart';

import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:client/core/constants/server_constant.dart';
import 'package:client/features/home/models/artist_model.dart';

class ArtistRepository {
  Future<Either<AppFailure, List<ArtistModel>>> getArtists({
    required String token,
    String query = "",
  }) async {
    try {
      final res = await http.get(
        Uri.parse(
            '${ServerConstant.serverURL}/auth/artist/listartists?query=$query'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      if (res.statusCode != 200) {
        return Left(AppFailure('Không thể lấy danh sách nghệ sĩ'));
      }

      final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
      return Right(data.map((e) => ArtistModel.fromMap(e)).toList());
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, ArtistModel>> getArtistDetail({
    required String artistId,
    required String token,
  }) async {
    try {
      final res = await http.get(
        Uri.parse('${ServerConstant.serverURL}/auth/artist/$artistId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      if (res.statusCode != 200) {
        return Left(AppFailure('Không thể lấy thông tin nghệ sĩ'));
      }

      final data = jsonDecode(utf8.decode(res.bodyBytes));
      return Right(ArtistModel.fromMap(data));
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, List<ArtistModel>>> searchArtists({
    required String query,
    required String token,
  }) async {
    try {
      final res = await http.get(
        Uri.parse(
            '${ServerConstant.serverURL}/auth/artist/search?query=$query'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      if (res.statusCode != 200) {
        return Left(AppFailure('Không thể tìm kiếm nghệ sĩ'));
      }

      final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
      final artists = data.map((e) => ArtistModel.fromMap(e)).toList();
      return Right(artists);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, Map<String, dynamic>>> checkArtist({
    required String artistName,
    File? artistImage,
    required String token,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ServerConstant.serverURL}/auth/artist/check-artist'),
      );

      request.fields['artist_name'] = artistName;

      if (artistImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('artist_image', artistImage.path),
        );
      }

      request.headers.addAll({
        'x-auth-token': token,
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        return Left(AppFailure('Không thể kiểm tra nghệ sĩ'));
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return Right(data);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }
}

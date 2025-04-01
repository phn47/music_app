import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:client/core/constants/server_constant.dart';
import 'package:client/core/failure/failure.dart';
import 'package:client/core/models/user_model.dart';
import 'package:client/features/home/models/album_model.dart';
import 'package:client/features/home/models/genre_model.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'home_repository.g.dart';

@riverpod
HomeRepository homeRepository(HomeRepositoryRef ref) {
  return HomeRepository();
}

class HomeRepository {
  Future<Either<AppFailure, String>> uploadSong({
    required File selectedAudio,
    required File selectedThumbnail,
    required String songName,
    required List<String> artistNames,
    required List<String> genreIds,
    required String hexCode,
    List<File>? artistImages,
    required String token,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ServerConstant.serverURL}/songs/upload'),
      );

      request.files.addAll([
        await http.MultipartFile.fromPath('song', selectedAudio.path),
        await http.MultipartFile.fromPath('thumbnail', selectedThumbnail.path),
      ]);

      if (artistImages != null) {
        for (var i = 0; i < artistImages.length; i++) {
          request.files.add(
            await http.MultipartFile.fromPath(
                'artist_images', artistImages[i].path),
          );
        }
      }

      request.fields.addAll({
        'song_name': songName,
        'hex_code': hexCode,
      });

      for (var artistName in artistNames) {
        request.fields['artist_names'] = artistName;
      }

      for (var genreId in genreIds) {
        request.fields['genre_ids'] = genreId;
      }

      request.headers.addAll({
        'x-auth-token': token,
      });

      final res = await request.send();

      if (res.statusCode != 201) {
        return Left(AppFailure(await res.stream.bytesToString()));
      }

      return Right(await res.stream.bytesToString());
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, List<SongModel>>> getAllSongs({
    required String token,
  }) async {
    try {
      final res = await http.get(
        Uri.parse('${ServerConstant.serverURL}/songs/list'),
        headers: {
          'Content-Type':
              'application/json; charset=UTF-8', // Đảm bảo server biết mã hóa UTF-8
          'x-auth-token': token,
        },
      );

      // Sử dụng utf8.decode để giải mã body
      final body = utf8.decode(res.bodyBytes);

      // In ra body để kiểm tra định dạng dữ liệu trả về
      // print('Response body: $body');

      // Xử lý mã trạng thái
      if (res.statusCode == 200) {
        final resBodyMap = jsonDecode(body);

        // Kiểm tra nếu resBodyMap là List
        if (resBodyMap is List) {
          List<SongModel> songs = [];
          for (final map in resBodyMap) {
            // print('Song map: $map');
            songs.add(SongModel.fromMap(map));
          }
          return Right(songs);
        } else {
          return Left(AppFailure("Dữ liệu trả về không phải là danh sách"));
        }
      } else {
        // Xử lý trường hợp không phải là 200
        final resBodyMap = jsonDecode(body);

        // Kiểm tra nếu resBodyMap là Map
        if (resBodyMap is Map<String, dynamic>) {
          // Có thể có các trường thông báo lỗi khác nhau
          String errorMessage = resBodyMap['detail'] ?? 'Có lỗi xảy ra';
          return Left(AppFailure(errorMessage));
        } else {
          return Left(
              AppFailure("Có lỗi xảy ra với mã trạng thái: ${res.statusCode}"));
        }
      }
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, bool>> favSong({
    required String token,
    required String songId,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${ServerConstant.serverURL}/songs/favorite'),
        headers: {
          'Content-Type':
              'application/json; charset=UTF-8', // Đảm bảo mã hóa UTF-8
          'x-auth-token': token,
        },
        body: jsonEncode(
          {
            "song_id": songId,
          },
        ),
      );

      // Giải mã nội dung phản hồi với UTF-8 để đảm bảo xử lý đúng tiếng Việt
      final body = utf8.decode(res.bodyBytes);
      var resBodyMap = jsonDecode(body);

      if (res.statusCode != 200) {
        resBodyMap = resBodyMap as Map<String, dynamic>;
        return Left(AppFailure(resBodyMap['detail'] ?? 'Có lỗi xảy ra'));
      }

      // Kiểm tra xem trường 'message' có tồn tại không
      if (resBodyMap is Map<String, dynamic> &&
          resBodyMap.containsKey('message')) {
        return Right(resBodyMap['message'] ==
            true); // Trả về true nếu yêu thích thành công
      } else {
        return Left(AppFailure("Phản hồi không chứa thông tin cần thiết"));
      }
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, List<SongModel>>> getFavSongs({
    required String token,
  }) async {
    try {
      final res = await http.get(
        Uri.parse('${ServerConstant.serverURL}/songs/list/favorites'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      final body = utf8.decode(res.bodyBytes);
      var resBodyMap = jsonDecode(body);

      if (res.statusCode != 200) {
        resBodyMap = resBodyMap as Map<String, dynamic>;
        return Left(AppFailure(resBodyMap['detail'] ?? 'Có lỗi xảy ra'));
      }

      // Nếu resBodyMap là danh sách, tiếp tục xử lý
      if (resBodyMap is List) {
        List<SongModel> songs = [];
        for (final map in resBodyMap) {
          // Kiểm tra và thêm bài hát vào danh sách
          if (map is Map<String, dynamic>) {
            songs.add(SongModel.fromMap(map));
          }
        }
        return Right(songs);
      } else {
        return Left(AppFailure("Dữ liệu trả về không phải là danh sách"));
      }
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, List<SongModel>>> searchSongs({
    required String query,
    required String token,
  }) async {
    try {
      final res = await http.get(
        Uri.parse(
            '${ServerConstant.serverURL}/songs/search?q=$query'), // Thêm tham số query vào URL
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      if (res.statusCode != 200) {
        return Left(AppFailure('Không thể tìm kiếm bài hát'));
      }

      final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
      final songs = data.map((e) => SongModel.fromMap(e)).toList();
      return Right(songs);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, List<SongModel>>> searchSongs11({
    required String query,
    required String token,
  }) async {
    try {
      final res = await http.get(
        Uri.parse(
            '${ServerConstant.serverURL}/auth/artist/listartists?q=$query'), // Thêm tham số query vào URL
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      if (res.statusCode != 200) {
        return Left(AppFailure('Không thể tìm kiếm bài hát'));
      }

      final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
      final songs = data.map((e) => SongModel.fromMap(e)).toList();
      return Right(songs);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, AlbumModel>> createAlbum({
    required File thumbnail,
    required String name,
    required bool isPublic,
    required String token,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ServerConstant.serverURL}/albums/create'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('thumbnail', thumbnail.path),
      );

      request.fields.addAll({
        'name': name,
        'is_public': isPublic.toString(),
      });

      request.headers.addAll({
        'x-auth-token': token,
        'Content-Type': 'multipart/form-data; charset=UTF-8',
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 201) {
        final errorBody = utf8.decode(response.bodyBytes);
        return Left(AppFailure(errorBody));
      }

      final responseBody = utf8.decode(response.bodyBytes);
      return Right(AlbumModel.fromMap(jsonDecode(responseBody)));
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, List<AlbumModel>>> getAlbums({
    required String token,
  }) async {
    try {
      final res = await http.get(
        Uri.parse('${ServerConstant.serverURL}/albums'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      final body = utf8.decode(res.bodyBytes);

      if (res.statusCode != 200) {
        final errorBody = jsonDecode(body);
        return Left(AppFailure(errorBody['detail'] ?? 'Có lỗi xảy ra'));
      }

      final List<dynamic> albumsJson = jsonDecode(body);
      final albums = albumsJson.map((e) => AlbumModel.fromMap(e)).toList();
      return Right(albums);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, List<SongModel>>> getAlbumSongs({
    required String albumId,
    required String token,
  }) async {
    try {
      final res = await http.get(
        Uri.parse('${ServerConstant.serverURL}/albums/$albumId/songs'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      final body = utf8.decode(res.bodyBytes);

      if (res.statusCode != 200) {
        final errorBody = jsonDecode(body);
        return Left(AppFailure(errorBody['detail'] ?? 'Có lỗi xảy ra'));
      }

      final List<dynamic> songsJson = jsonDecode(body);
      final songs = songsJson.map((e) => SongModel.fromMap(e)).toList();
      return Right(songs);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, String>> addSongToAlbum({
    required String albumId,
    required String songId,
    required String token,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${ServerConstant.serverURL}/albums/$albumId/add-song'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'song_id': songId,
        }),
      );

      final body = utf8.decode(res.bodyBytes);

      if (res.statusCode != 200) {
        final errorBody = jsonDecode(body);
        if (res.statusCode == 403) {
          return Left(
              AppFailure('Bạn không có quyền thêm bài hát vào album này'));
        }
        return Left(AppFailure(errorBody['detail'] ?? 'Có lỗi xảy ra'));
      }

      return Right('Thêm bài hát vào album thành công');
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, String>> deleteAlbum({
    required String albumId,
    required String token,
  }) async {
    try {
      final res = await http.delete(
        Uri.parse('${ServerConstant.serverURL}/albums/$albumId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      final body = utf8.decode(res.bodyBytes);

      if (res.statusCode != 200) {
        final errorBody = jsonDecode(body);
        return Left(AppFailure(errorBody['detail'] ?? 'Có lỗi xảy ra'));
      }

      return Right('Đã xóa album thành công');
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, String>> updateAlbum({
    required String albumId,
    String? name,
    String? description,
    bool? isPublic,
    File? thumbnail,
    required String token,
  }) async {
    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ServerConstant.serverURL}/albums/$albumId'),
      );

      if (thumbnail != null) {
        request.files.add(
          await http.MultipartFile.fromPath('thumbnail', thumbnail.path),
        );
      }

      final fields = <String, String>{};
      if (name != null) fields['name'] = name;
      if (description != null) fields['description'] = description;
      if (isPublic != null) fields['is_public'] = isPublic.toString();

      request.fields.addAll(fields);
      request.headers.addAll({
        'x-auth-token': token,
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        final errorBody = utf8.decode(response.bodyBytes);
        return Left(AppFailure(errorBody));
      }

      return Right('Cập nhật album thành công');
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, String>> uploadSongToAlbum({
    required String albumId,
    required File selectedAudio,
    required File selectedThumbnail,
    required String songName,
    required String artist,
    required String hexCode,
    File? artistImage,
    required String token,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ServerConstant.serverURL}/albums/$albumId/upload-song'),
      );

      request.files.addAll([
        await http.MultipartFile.fromPath('song', selectedAudio.path),
        await http.MultipartFile.fromPath('thumbnail', selectedThumbnail.path),
      ]);

      if (artistImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('artist_image', artistImage.path),
        );
      }

      request.fields.addAll({
        'song_name': songName,
        'artist': artist,
        'hex_code': hexCode,
      });

      request.headers.addAll({
        'x-auth-token': token,
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        final errorBody = utf8.decode(response.bodyBytes);
        return Left(AppFailure(errorBody));
      }

      return Right('Thêm bài hát vào album thành công');
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, List<SongModel>>> getUserSongs({
    required String token,
  }) async {
    try {
      // print('Token being used: $token');

      final res = await http.get(
        Uri.parse('${ServerConstant.serverURL}/song/user/songs'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      // print('Response status: ${res.statusCode}');
      // print('Response body: ${res.body}');

      final body = utf8.decode(res.bodyBytes);

      if (res.statusCode == 200) {
        final resBodyMap = jsonDecode(body);
        if (resBodyMap is List) {
          List<SongModel> songs = [];
          for (final map in resBodyMap) {
            songs.add(SongModel.fromMap(map));
          }
          return Right(songs);
        }
      }
      return Left(AppFailure('Không thể lấy danh sách bài hát'));
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, String>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ServerConstant.serverURL}/auth/change-password2'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );
      print("Token: $token");

      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 201) {
        return Left(AppFailure(resBodyMap['detail']));
      }

      return Right(resBodyMap['detail']); // Trả về thông báo thành công
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, List<UserModel>>> getAllUser({
    required String token,
  }) async {
    try {
      final res = await http.get(
        Uri.parse('${ServerConstant.serverURL}/auth/list'),
        headers: {
          'Content-Type':
              'application/json; charset=UTF-8', // Đảm bảo server biết mã hóa UTF-8
          'x-auth-token':
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM1ZDQyYWJjLTYxZTUtNDA4Yi04MzdiLWZkOGRhOGQzNDQ4ZCJ9.imUWlMDFj0F8TGvW2YCGGeGiptZFjT3PS3MyZtpk0FU',
        },
      );

      // Sử dụng utf8.decode để giải mã body
      final body = utf8.decode(res.bodyBytes);

      // In ra body để kiểm tra định dạng dữ liệu trả về
      // print('Response body: $body');

      // Xử lý mã trạng thái
      if (res.statusCode != 200) {
        final resBodyMap = jsonDecode(body);

        // Kiểm tra nếu resBodyMap là List
        if (resBodyMap is List) {
          List<UserModel> songs = [];
          for (final map in resBodyMap) {
            // print('Song map: $map');
            songs.add(UserModel.fromMap(map));
          }
          return Right(songs);
        } else {
          return Left(AppFailure("Dữ liệu trả về không phải là danh sách"));
        }
      } else {
        // Xử lý trường hợp không phải là 200
        final resBodyMap = jsonDecode(body);

        // Kiểm tra nếu resBodyMap là Map
        if (resBodyMap is Map<String, dynamic>) {
          // Có thể có các trường thông báo lỗi khác nhau
          String errorMessage = resBodyMap['detail'] ?? 'Có lỗi xảy ra';
          return Left(AppFailure(errorMessage));
        } else {
          return Left(
              AppFailure("Có lỗi xảy ra với mã trạng thái: ${res.statusCode}"));
        }
      }
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, String>> deleteSong({
    required String songId,
    required String token,
  }) async {
    try {
      final res = await http.delete(
        Uri.parse('${ServerConstant.serverURL}/song/$songId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      final body = utf8.decode(res.bodyBytes);

      if (res.statusCode != 200) {
        final errorBody = jsonDecode(body);
        return Left(AppFailure(errorBody['detail'] ?? 'Có lỗi xảy ra'));
      }

      return Right('Đã xóa bài hát thành công');
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, SongModel>> updateSong({
    required String songId,
    String? songName,
    String? artistName,
    String? hexCode,
    File? thumbnail,
    required String token,
  }) async {
    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ServerConstant.serverURL}/song/$songId'),
      );

      if (thumbnail != null) {
        request.files.add(
          await http.MultipartFile.fromPath('thumbnail', thumbnail.path),
        );
      }

      final fields = <String, String>{};
      if (songName != null) fields['song_name'] = songName;
      if (artistName != null) fields['artist_name'] = artistName;
      if (hexCode != null) fields['hex_code'] = hexCode;

      request.fields.addAll(fields);
      request.headers.addAll({
        'x-auth-token': token,
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
        return Left(AppFailure(errorBody['detail'] ?? 'Có lỗi xảy ra'));
      }

      final songData = jsonDecode(utf8.decode(response.bodyBytes));
      return Right(SongModel.fromMap(songData));
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, Map<String, dynamic>>> checkArtistExists({
    required String artistName,
    required String token,
  }) async {
    try {
      final res = await http.get(
        Uri.parse(
            '${ServerConstant.serverURL}/artist/check/${Uri.encodeComponent(artistName)}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      if (res.statusCode != 200) {
        return Left(AppFailure('Không thể kiểm tra nghệ sĩ'));
      }

      final data = jsonDecode(utf8.decode(res.bodyBytes));
      return Right({
        'exists': data['exists'],
        'imageUrl': data['imageUrl'],
      });
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, String>> trainModel({
    required Uint8List audioData,
    required String lrcPath,
    required String audioFileName, // Thêm tham số này
  }) async {
    try {
      // In ra dữ liệu truyền vào
      print("Audio Data Length: ${audioData.length}");
      print("LRC Path: $lrcPath");
      print("Audio File Name: $audioFileName"); // In ra tên file âm thanh

      // Đọc nội dung tệp LRC
      String lrcContent = await File(lrcPath).readAsString();
      print("LRC Content: $lrcContent");

      // Tạo tệp tạm cho nội dung LRC
      String tempLrcPath = '${lrcPath}.tmp';
      await File(tempLrcPath).writeAsString(lrcContent);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ServerConstant.serverURL}/train/'),
      );

      // Thêm tệp âm thanh từ dữ liệu Uint8List, sử dụng audioFileName
      request.files.add(http.MultipartFile.fromBytes('audio', audioData,
          filename: audioFileName // Sử dụng tên file truyền vào
          ));

      // Thêm tệp LRC
      request.files.add(await http.MultipartFile.fromPath('lrc', tempLrcPath));

      var response = await request.send();

      // Xóa tệp tạm sau khi gửi
      await File(tempLrcPath).delete();

      if (response.statusCode == 200) {
        print("Model trained successfully!");
        return Right("Model trained successfully!");
      } else {
        print("Failed to train model. Status Code: ${response.statusCode}");
        return Left(AppFailure("Failed to train model."));
      }
    } catch (e) {
      print("Error: $e");
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, List<GenreModel>>> getGenres() async {
    try {
      final res = await http.get(
        Uri.parse('${ServerConstant.serverURL}/songs/genres'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (res.statusCode != 200) {
        return Left(AppFailure('Không thể lấy thể loại'));
      }

      final List<dynamic> genresJson = jsonDecode(utf8.decode(res.bodyBytes));
      final genres = genresJson.map((e) => GenreModel.fromJson(e)).toList();
      return Right(genres);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getAllSongsHash() => r'a06f06bef1b9213d7a6fb1458e5a4d32f0c45f7e';

/// See also [getAllSongs].
@ProviderFor(getAllSongs)
final getAllSongsProvider = AutoDisposeFutureProvider<List<SongModel>>.internal(
  getAllSongs,
  name: r'getAllSongsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$getAllSongsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetAllSongsRef = AutoDisposeFutureProviderRef<List<SongModel>>;
String _$getFavSongsHash() => r'a87018e84ac4917a7a2b793d0931a0667503c6bb';

/// See also [getFavSongs].
@ProviderFor(getFavSongs)
final getFavSongsProvider = AutoDisposeFutureProvider<List<SongModel>>.internal(
  getFavSongs,
  name: r'getFavSongsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$getFavSongsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetFavSongsRef = AutoDisposeFutureProviderRef<List<SongModel>>;
String _$getAlbumsHash() => r'a65176a155e45797f127c7120c4e754be4bef328';

/// See also [getAlbums].
@ProviderFor(getAlbums)
final getAlbumsProvider = AutoDisposeFutureProvider<List<AlbumModel>>.internal(
  getAlbums,
  name: r'getAlbumsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$getAlbumsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetAlbumsRef = AutoDisposeFutureProviderRef<List<AlbumModel>>;
String _$getAlbumSongsHash() => r'2c3284b8deadf37a105fb682e79412401f1d70db';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [getAlbumSongs].
@ProviderFor(getAlbumSongs)
const getAlbumSongsProvider = GetAlbumSongsFamily();

/// See also [getAlbumSongs].
class GetAlbumSongsFamily extends Family<AsyncValue<List<SongModel>>> {
  /// See also [getAlbumSongs].
  const GetAlbumSongsFamily();

  /// See also [getAlbumSongs].
  GetAlbumSongsProvider call(
    String albumId,
  ) {
    return GetAlbumSongsProvider(
      albumId,
    );
  }

  @override
  GetAlbumSongsProvider getProviderOverride(
    covariant GetAlbumSongsProvider provider,
  ) {
    return call(
      provider.albumId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'getAlbumSongsProvider';
}

/// See also [getAlbumSongs].
class GetAlbumSongsProvider extends AutoDisposeFutureProvider<List<SongModel>> {
  /// See also [getAlbumSongs].
  GetAlbumSongsProvider(
    String albumId,
  ) : this._internal(
          (ref) => getAlbumSongs(
            ref as GetAlbumSongsRef,
            albumId,
          ),
          from: getAlbumSongsProvider,
          name: r'getAlbumSongsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$getAlbumSongsHash,
          dependencies: GetAlbumSongsFamily._dependencies,
          allTransitiveDependencies:
              GetAlbumSongsFamily._allTransitiveDependencies,
          albumId: albumId,
        );

  GetAlbumSongsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.albumId,
  }) : super.internal();

  final String albumId;

  @override
  Override overrideWith(
    FutureOr<List<SongModel>> Function(GetAlbumSongsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetAlbumSongsProvider._internal(
        (ref) => create(ref as GetAlbumSongsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        albumId: albumId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SongModel>> createElement() {
    return _GetAlbumSongsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetAlbumSongsProvider && other.albumId == albumId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, albumId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GetAlbumSongsRef on AutoDisposeFutureProviderRef<List<SongModel>> {
  /// The parameter `albumId` of this provider.
  String get albumId;
}

class _GetAlbumSongsProviderElement
    extends AutoDisposeFutureProviderElement<List<SongModel>>
    with GetAlbumSongsRef {
  _GetAlbumSongsProviderElement(super.provider);

  @override
  String get albumId => (origin as GetAlbumSongsProvider).albumId;
}

String _$getAllAlbumsHash() => r'3ae006be6811975c664376d39e5d2c9e631deb31';

/// See also [getAllAlbums].
@ProviderFor(getAllAlbums)
final getAllAlbumsProvider =
    AutoDisposeFutureProvider<List<AlbumModel>>.internal(
  getAllAlbums,
  name: r'getAllAlbumsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$getAllAlbumsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetAllAlbumsRef = AutoDisposeFutureProviderRef<List<AlbumModel>>;
String _$getAllUserHash() => r'6be5f2d47351286bd0e2f338c576527266efc608';

/// See also [getAllUser].
@ProviderFor(getAllUser)
final getAllUserProvider = AutoDisposeFutureProvider<List<UserModel>>.internal(
  getAllUser,
  name: r'getAllUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$getAllUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetAllUserRef = AutoDisposeFutureProviderRef<List<UserModel>>;
String _$homeViewModelHash() => r'22f9c9661d26322a1ae22c8fc097b6a00320e9f9';

/// See also [HomeViewModel].
@ProviderFor(HomeViewModel)
final homeViewModelProvider =
    AutoDisposeNotifierProvider<HomeViewModel, AsyncValue?>.internal(
  HomeViewModel.new,
  name: r'homeViewModelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$homeViewModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HomeViewModel = AutoDisposeNotifier<AsyncValue?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

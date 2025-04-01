// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$commentRepositoryHash() => r'6838988df1dc1b1fcd256dbe1c60e134dfb9e686';

/// See also [commentRepository].
@ProviderFor(commentRepository)
final commentRepositoryProvider = Provider<CommentRepository>.internal(
  commentRepository,
  name: r'commentRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$commentRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CommentRepositoryRef = ProviderRef<CommentRepository>;
String _$commentNotifierHash() => r'8d447b699e1af38d0164a52f009c638c50eb3cf7';

/// See also [CommentNotifier].
@ProviderFor(CommentNotifier)
final commentNotifierProvider = AutoDisposeNotifierProvider<CommentNotifier,
    AsyncValue<List<CommentModel>>>.internal(
  CommentNotifier.new,
  name: r'commentNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$commentNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CommentNotifier = AutoDisposeNotifier<AsyncValue<List<CommentModel>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

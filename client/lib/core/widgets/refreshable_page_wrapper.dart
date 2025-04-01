import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/core/theme/app_pallete.dart';

class RefreshablePageWrapper extends ConsumerWidget {
  final Widget child;
  final List<Future<void> Function()> onRefreshCallbacks;

  const RefreshablePageWrapper({
    Key? key,
    required this.child,
    required this.onRefreshCallbacks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: Pallete.gradient2,
      backgroundColor: Pallete.backgroundColor,
      onRefresh: () async {
        // Thực hiện tất cả các callback refresh
        await Future.wait(
          onRefreshCallbacks.map((callback) => callback()).toList(),
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: child,
      ),
    );
  }
}

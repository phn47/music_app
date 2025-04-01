// ignore_for_file: unused_local_variable, unnecessary_null_comparison

import 'package:client/core/utils.dart';
import 'package:client/core/widgets/page_navigation.dart';
import 'package:client/features/auth/view/pages/change_password_page_2.dart';
import 'package:client/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/features/auth/view/pages/login_page.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/home/view/pages/liked_tracks_page.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:fpdart/fpdart.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserNotifierProvider);
    final favSongs = ref.watch(getFavSongsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Hồ sơ',
            style: TextStyle(
                color: Pallete.whiteColor, fontWeight: FontWeight.bold)),
        backgroundColor: Pallete.backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/account.png'),
                  backgroundColor: Pallete.greyColor,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  currentUser?.name ?? 'Tên Người Dùng',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Pallete.whiteColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: Pallete.greyColor),
              ListTile(
                leading: const Icon(Icons.email, color: Pallete.whiteColor),
                title: const Text('Email',
                    style: TextStyle(color: Pallete.whiteColor)),
                subtitle: Text(
                  currentUser?.email ?? 'user@example.com',
                  style: const TextStyle(color: Pallete.greyColor),
                ),
              ),
              ListTile(
                leading:
                    const Icon(Icons.music_note, color: Pallete.whiteColor),
                title: const Text('Bài hát ưa thích',
                    style: TextStyle(color: Pallete.whiteColor)),
                subtitle: favSongs.when(
                  data: (songs) => Text('${songs.length} bài hát',
                      style: const TextStyle(color: Pallete.greyColor)),
                  loading: () => const Text('Đang tải...',
                      style: TextStyle(color: Pallete.greyColor)),
                  error: (_, __) => const Text('Không thể tải dữ liệu',
                      style: TextStyle(color: Pallete.greyColor)),
                ),
                onTap: () {
                  PageNavigation.navigateToChild(
                      context, const LikedTracksPage());
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_reset_outlined,
                    color: Pallete.whiteColor),
                title: const Text('Thay đổi mật khẩu',
                    style: TextStyle(color: Pallete.whiteColor)),
                onTap: () {
                  PageNavigation.navigateToChild(
                      context, const ChangePasswordPage2());
                },
              ),
              const Divider(color: Pallete.greyColor),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Đăng xuất',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40),
                                  child: const Text(
                                    'Bạn có chắc bạn muốn đăng\nxuất không?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                const Divider(color: Colors.grey, height: 1),
                                IntrinsicHeight(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'Huỷ',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const VerticalDivider(
                                        color: Colors.grey,
                                        thickness: 1,
                                        width: 1,
                                      ),
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () async {
                                            final result = await ref
                                                .read(authViewModelProvider
                                                    .notifier)
                                                .logout();
                                            if (Right != null) {
                                              if (context.mounted) {
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const LoginPage(),
                                                  ),
                                                  (route) => false,
                                                );
                                              }
                                            } else {
                                              if (context.mounted) {
                                                showSnackBar(context,
                                                    'Đăng xuất không thành công!');
                                              }
                                            }
                                          },
                                          child: const Text(
                                            'Đăng xuất',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Pallete.gradient2,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                  ),
                  child: const Text('Đăng xuất',
                      style:
                          TextStyle(fontSize: 18, color: Pallete.whiteColor)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

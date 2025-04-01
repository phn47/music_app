// ignore_for_file: unused_local_variable

import 'package:client/features/auth/repositories/auth_remote_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final currentNameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: currentNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên tài khoản',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập tài khoản hiện tại' : null,
              ),
              TextFormField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu hiện tại',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập mật khẩu hiện tại' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu mới',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập mật khẩu mới' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    // final token = ''; // Lấy token từ nơi bạn lưu trữ
                    final result = await ref
                        .read(authRemoteRepositoryProvider)
                        .changePassword(
                          name: currentNameController.text,
                          currentPassword: currentPasswordController.text,
                          newPassword: newPasswordController.text,
                          // token: token,
                        );

                    // result.fold(
                    //   (failure) => showSnackBar(context, failure.message),
                    //   (successMessage) => showSnackBar(context, successMessage),
                    // );
                  }
                },
                child: const Text('Đổi mật khẩu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

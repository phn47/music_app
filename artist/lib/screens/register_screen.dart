import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final SharedPreferences prefs;
  const RegisterScreen({Key? key, required this.prefs}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final AuthService authService;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    authService = Provider.of<AuthService>(context, listen: false);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    try {
      final response = await authService.signup(
        emailController.text,
        passwordController.text,
        nameController.text,
      );

      if (mounted) {
        _handleRegisterSuccess(response);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _handleRegisterSuccess(Map<String, dynamic> response) async {
    try {
      // Hiển thị thông báo đăng ký thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký thành công! Vui lòng đăng nhập'),
          backgroundColor: Colors.green,
        ),
      );

      // Đợi một chút để người dùng đọc thông báo
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // Chuyển về màn hình đăng nhập
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('Lỗi khi xử lý đăng ký: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _signup,
              child: const Text('signup'),
            ),
          ],
        ),
      ),
    );
  }
}

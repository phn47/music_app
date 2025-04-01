import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/core/widgets/page_navigation.dart';
import 'package:client/features/auth/view/pages/login_page.dart';
import 'package:client/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:client/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref
        .watch(authViewModelProvider.select((val) => val?.isLoading == true));

    ref.listen(
      authViewModelProvider,
      (_, next) {
        next?.when(
          data: (data) {
            showSnackBar(
              context,
              'Tạo tài khoản thành công! Vui lòng đăng nhập.',
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
            );
          },
          error: (error, st) {
            showSnackBar(context, error.toString());
          },
          loading: () {},
        );
      },
    );

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/avt.png',
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                    const Text(
                      'Đăng Ký',
                      style: TextStyle(
                        color: Color.fromRGBO(251, 109, 169, 1),
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (isLoading)
                      const Loader()
                    else
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            CustomField(
                              hintText: '',
                              controller: nameController,
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                hintText: 'Tên',
                                hintStyle: TextStyle(
                                    color: Color.fromRGBO(167, 167, 167, 1)),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 15),
                            CustomField(
                              hintText: '',
                              controller: emailController,
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                hintText: 'Email',
                                hintStyle: TextStyle(
                                    color: Color.fromRGBO(167, 167, 167, 1)),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 15),
                            CustomField(
                              hintText: '',
                              controller: passwordController,
                              isObscureText: true,
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                hintText: 'Mật khẩu',
                                hintStyle: TextStyle(
                                    color: Color.fromRGBO(167, 167, 167, 1)),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            AuthGradientButton(
                              buttonText: 'Đăng Ký',
                              onTap: () async {
                                if (formKey.currentState!.validate()) {
                                  await ref
                                      .read(authViewModelProvider.notifier)
                                      .signUpUser(
                                        name: nameController.text,
                                        email: emailController.text,
                                        password: passwordController.text,
                                      );
                                } else {
                                  showSnackBar(
                                      context, 'Vui Lòng Nhập Đầy Đủ!');
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                PageNavigation.navigateWithSlide(
                                    context, const LoginPage());
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: 'Đã có tài khoản? ',
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 51, 51, 51),
                                    fontSize: 16.0,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: 'Đăng Nhập',
                                      style: TextStyle(
                                        color: Pallete.gradient2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

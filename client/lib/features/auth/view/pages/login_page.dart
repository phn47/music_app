import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/core/widgets/page_navigation.dart';
import 'package:client/features/auth/view/pages/change_password_page.dart';
import 'package:client/features/auth/view/pages/signup_page.dart';
import 'package:client/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:client/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:client/features/home/view/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
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
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
              (_) => false,
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
                      'Đăng Nhập',
                      style: TextStyle(
                        color: Color.fromRGBO(251, 109, 169, 1),
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        fontFamily: '',
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
                              controller: emailController,
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                hintText: 'Email',
                                hintStyle: TextStyle(
                                    color: Color.fromRGBO(167, 167, 167, 1)),
                                border: OutlineInputBorder(),
                              ),
                              hintText: '',
                            ),
                            const SizedBox(height: 15),
                            CustomField(
                              controller: passwordController,
                              isObscureText: true,
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                hintText: 'Mật khẩu',
                                hintStyle: TextStyle(
                                    color: Color.fromRGBO(167, 167, 167, 1)),
                                border: OutlineInputBorder(),
                              ),
                              hintText: '',
                            ),
                            const SizedBox(height: 20),
                            // AuthGradientButton(
                            //   buttonText: 'Đăng Nhập',
                            //   onTap: () async {
                            //     if (formKey.currentState!.validate()) {
                            //       await ref
                            //           .read(authViewModelProvider.notifier)
                            //           .loginUser(
                            //             email: emailController.text,
                            //             password: passwordController.text,
                            //           );
                            //     } else {
                            //       showSnackBar(context, 'Vui Lòng Nhập Lại!');
                            //     }
                            //   },
                            // ),
                            AuthGradientButton(
                              buttonText: 'Đăng nhập',
                              onTap: () async {
                                if (formKey.currentState!.validate()) {
                                  // Kiểm tra điều kiện email và password cho AdminPage
                                  if (emailController.text == 'admin' &&
                                      passwordController.text == 'admin') {
                                    // Chuyển hướng đến AdminPage
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const HomePage(),
                                      ),
                                    );
                                  } else {
                                    // Nếu không phải là admin, gọi hàm loginUser thông thường
                                    await ref
                                        .read(authViewModelProvider.notifier)
                                        .loginUser(
                                          email: emailController.text,
                                          password: passwordController.text,
                                        );
                                  }
                                } else {
                                  // showSnackBar(context, 'Missing fields!');
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                PageNavigation.navigateWithSlide(
                                    context, const SignupPage());
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: 'Bạn không có tài khoản? ',
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 51, 51, 51),
                                    fontSize: 16.0,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: 'Đăng ký',
                                      style: TextStyle(
                                        color: Pallete.gradient2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // GestureDetector(
                            //   onTap: () {
                            //     // Điều hướng đến trang đổi mật khẩu
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (context) =>
                            //             const ChangePasswordPage(),
                            //       ),
                            //     );
                            //   },
                            //   child: RichText(
                            //     text: TextSpan(
                            //       text: 'Quên mật khẩu?',
                            //       style:
                            //           Theme.of(context).textTheme.titleMedium,
                            //       children: const [
                            //         TextSpan(
                            //           text: ' Đổi mật khẩu',
                            //           style: TextStyle(
                            //             color: Pallete.gradient2,
                            //             fontWeight: FontWeight.bold,
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
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

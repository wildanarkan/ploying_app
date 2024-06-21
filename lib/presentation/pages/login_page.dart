import 'package:d_method/d_method.dart';
import 'package:ploying_app/common/app_color.dart';
import 'package:ploying_app/common/app_info.dart';
import 'package:ploying_app/common/app_route.dart';
import 'package:ploying_app/data/source/user_source.dart';
import 'package:ploying_app/presentation/widgets/app_button.dart';
import 'package:d_session/d_session.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool checkPassword = false;
  final _formKey = GlobalKey<FormState>();

  login(String email, String password, BuildContext context) {
    UserSource.login(email, password).then((result) {
      if (result == null) {
        AppInfo.failed(context, 'Gagal Login!');
      } else {
        AppInfo.success(context, 'Berhasil Login!');
        DSession.setUser(result.toJson());
        Navigator.pushNamed(context, AppRoute.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final edtEmail = TextEditingController();
    final edtPassword = TextEditingController();
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          buildHeader(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: edtEmail,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "your email...",
                      filled: true,
                      fillColor: Colors.white,
                      label: Text('Email'),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: edtPassword,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: "your password...",
                      fillColor: Colors.white,
                      label: const Text('Password'),
                      filled: true,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            checkPassword = !checkPassword;
                          });
                        },
                        child: const Icon(Icons.remove_red_eye_rounded),
                      ),
                    ),
                    obscureText: !checkPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AppButton.primary('LOGIN', () {
                    if (_formKey.currentState!.validate()) {
                      DMethod.log(edtEmail.text + edtPassword.text);
                      login(edtEmail.text, edtPassword.text, context);
                    }
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  AspectRatio buildHeader() {
    return AspectRatio(
      aspectRatio: 0.8,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            bottom: 80,
            child: Image.asset(
              'assets/login_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            top: 200,
            bottom: 80,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColor.scaffold,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 30,
            right: 30,
            bottom: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 120,
                  width: 120,
                ),
                const SizedBox(width: 20),
                RichText(
                  text: TextSpan(
                    text: 'Monitoring\n',
                    style: TextStyle(
                      color: AppColor.defaultText,
                      fontSize: 30,
                      height: 1.4,
                    ),
                    children: const [
                      TextSpan(text: 'with '),
                      TextSpan(
                        text: 'ploying ',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

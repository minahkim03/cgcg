import 'package:flutter/cupertino.dart';
import 'profile_upload_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('회원가입'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoTextField(
              controller: _emailController,
              placeholder: '이메일',
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            CupertinoTextField(
              controller: _passwordController,
              placeholder: '비밀번호',
              obscureText: true,
            ),
            SizedBox(height: 16),
            CupertinoTextField(
              controller: _nicknameController,
              placeholder: '닉네임',
            ),
            SizedBox(height: 20),
            CupertinoButton(
              color: CupertinoColors.activeBlue,
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => ProfileUploadScreen(
                    email: _emailController.text,
                    password: _passwordController.text,
                    nickname: _nicknameController.text,
                  )),
                );
              },
              child: Text('다음'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart'; 
import '../home_page.dart';
import '../user_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Dio _dio = Dio();

  Future<void> _login() async {
    try {
      final response = await _dio.post(
        'http://localhost:8080/login',
        data: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        final String accessToken = response.data['accessToken'];
        final String memberId = response.data['memberId'];
        final String nickname = response.data['nickname'];
        final String profileImage = response.data['profileImage'];

        if (accessToken.isNotEmpty) {
          await UserPreferences.saveUserData(accessToken, memberId, nickname, profileImage);
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(builder: (context) => HomePage()),
          );
        } else {
          _showDialog('로그인 실패', 'accessToken이 없습니다.');
        }
      } else {
        _showDialog('로그인 실패', response.statusMessage ?? '알 수 없는 오류');
      }
    } catch (e) {
      print(e);
      _showDialog('오류 발생', '로그인 중 오류가 발생했습니다.');
    }
  }

  void _showDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('로그인'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoTextField(
                controller: _emailController,
                placeholder: '이메일',
              ),
              SizedBox(height: 16),
              CupertinoTextField(
                controller: _passwordController,
                placeholder: '비밀번호',
                obscureText: true,
              ),
              SizedBox(height: 20),
              CupertinoButton(
                color: CupertinoColors.activeBlue,
                onPressed: _login,
                child: Text('로그인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

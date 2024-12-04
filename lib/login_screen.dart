import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; 
import 'home_page.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Dio _dio = Dio(); // Dio 인스턴스 생성

  Future<void> _login() async {
    try {
      final response = await _dio.post(
        'http://localhost:8080/login', // 로그인 요청 URL
        data: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        // 로그인 성공 시 쿠키에 access_token이 포함될 것으로 가정
        final String accessToken = response.headers.value('set-cookie') ?? '';

        // 로그인 성공 후 HomeScreen으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(accessToken: accessToken)),
        );
      } else {
        // 로그인 실패
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패')),
        );
      }
    } catch (e) {
      // 요청 실패 시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 중 오류 발생')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: '이메일'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('로그인'),
            ),
          ],
        ),
      ),
    );
  }
}

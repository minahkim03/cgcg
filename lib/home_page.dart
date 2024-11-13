import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Dio 라이브러리 사용

class HomePage extends StatefulWidget {
  final String accessToken;

  HomePage({required this.accessToken});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _nickname;
  String? _profileImageUrl;
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _accessToken = widget.accessToken;
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await Dio().get(
        'http://localhost:8080/profile', // 프로필 정보 요청
        options: Options(
          headers: {
            'Authorization': 'Bearer $_accessToken', // 토큰을 Authorization 헤더로 보냄
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _nickname = response.data['nickname'];
          _profileImageUrl = response.data['profileImageUrl'];
        });
      } 
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('홈')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_profileImageUrl != null)
              CircleAvatar(
                backgroundImage: NetworkImage(_profileImageUrl!),
                radius: 50,
              ),
            SizedBox(height: 20),
            if (_nickname != null)
              Text(
                '닉네임: $_nickname',
                style: TextStyle(fontSize: 18),
              ),
            SizedBox(height: 20),
            Text(
              'Access Token: $_accessToken',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

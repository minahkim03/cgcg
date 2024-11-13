import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'api_service.dart';

class ProfileUploadScreen extends StatefulWidget {
  final String email;
  final String password;
  final String nickname;

  ProfileUploadScreen({
    required this.email,
    required this.password,
    required this.nickname,
  });

  @override
  _ProfileUploadScreenState createState() => _ProfileUploadScreenState();
}

class _ProfileUploadScreenState extends State<ProfileUploadScreen> {
  final _picker = ImagePicker();
  File? _profileImage;
  final Dio _dio = Dio();
  late final ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(_dio);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadAndRegister() async {
    if (_profileImage == null) return;

    try {
      // 1. 프로필 사진 업로드
      String profileImageUrl = await _apiService.uploadProfileImage(_profileImage!);

      // 2. 회원가입 데이터 전송
      final userData = {
        "email": widget.email,
        "password": widget.password,
        "nickname": widget.nickname,
        "profileImage": profileImageUrl,
      };

      await _apiService.registerUser(userData);
      print("회원가입 완료!");
    } catch (e) {
      print("에러 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 사진 업로드'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                child: _profileImage == null
                    ? Icon(Icons.camera_alt, size: 50)
                    : ClipOval(
                        child: Image.file(
                          _profileImage!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadAndRegister,
              child: Text('회원가입 완료'),
            ),
          ],
        ),
      ),
    );
  }
}

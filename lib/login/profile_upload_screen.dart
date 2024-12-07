import 'package:cgcg/login/login_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../api_service/api_service.dart';

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
      String profileImageUrl = await _apiService.uploadProfileImage(_profileImage!);

      final userData = {
        "email": widget.email,
        "password": widget.password,
        "nickname": widget.nickname,
        "profileImage": profileImageUrl,
      };

      await _apiService.registerUser(userData);
      _showDialog('회원가입 완료!', '회원가입이 성공적으로 완료되었습니다.');
      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(builder: (context) => LoginHome()),
        (route) => false,
      );
    } catch (e) {
      _showDialog('에러 발생', '회원가입 중 오류가 발생했습니다: $e');
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
        middle: Text('프로필 사진 업로드'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: ClipOval(
                child: Container(
                  width: 100,
                  height: 100,
                  color: CupertinoColors.systemGrey2,
                  child: _profileImage == null
                      ? Icon(CupertinoIcons.camera, size: 50)
                      : Image.file(
                          _profileImage!,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            SizedBox(height: 20),
            CupertinoButton(
              color: CupertinoColors.activeBlue,
              onPressed: _uploadAndRegister,
              child: Text('회원가입 완료'),
            ),
          ],
        ),
      ),
    );
  }
}

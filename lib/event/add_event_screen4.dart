import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../api_service/api_service.dart';
import '../home_page.dart';
import '../user_preferences.dart';

class AddEventScreen4 extends StatefulWidget {
  final String eventName;
  final DateTime eventDate;
  final List selectedMembers;

  AddEventScreen4({
    required this.eventName,
    required this.eventDate,
    required this.selectedMembers,
  });

  @override
  AddEventScreen4State createState() => AddEventScreen4State();
}

class AddEventScreen4State extends State<AddEventScreen4> {
  final Dio _dio = Dio();
  final _picker = ImagePicker();
  File? _image;
  late final ApiService _apiService;
  String? memberId;
  String? accessToken;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(_dio);
    _loadUserData();
  }

  Future _loadUserData() async {
    final userData = await UserPreferences.loadUserData();
    setState(() {
      memberId = userData['memberId'];
      accessToken = userData['accessToken'];
    });
  }

  Future _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      } else {
        print("이미지 없음");
      }
    } catch (e) {
      print("이미지 선택 중 오류 발생: $e");
    }
  }

  Future _createEvent() async {
    if (_image == null) return;
    try {
      String imageUrl = await _apiService.uploadProfileImage(_image!);
      final eventData = {
        "title": widget.eventName,
        "date": widget.eventDate.toIso8601String(),
        "members": widget.selectedMembers,
        "image": imageUrl,
      };
      await _dio.post(
        'http://localhost:8080/event/new?id=$memberId',
        data: eventData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(builder: (context) => HomePage()),
        (route) => false,
      );
    } catch (e) {
      print('이벤트 생성 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('새로운 이벤트 생성'),
      ),
      child: Center( 
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '대표 이미지를 선택해주세요.',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 200, 
                  height: 200, 
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.systemGrey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _image != null
                      ? Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        )
                      : Center(child: Text('이미지 선택하기')),
                ),
              ),
              SizedBox(height: 20),
              CupertinoButton(
                color: CupertinoColors.activeBlue,
                child: Text('완료'),
                onPressed: _createEvent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

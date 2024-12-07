import 'dart:io';
import 'package:cgcg/api_service/api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../user_preferences.dart';

class ChatScreen extends StatefulWidget {
  final int? eventId;
  final String? eventTitle;

  ChatScreen({required this.eventId, required this.eventTitle});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Dio _dio = Dio();
  late WebSocketChannel _channel;
  List<dynamic> messages = [];
  final TextEditingController _messageController = TextEditingController();
  String? accessToken;
  String? memberId;
  String? nickname;
  final ImagePicker _picker = ImagePicker();
  File? _image;
  late final ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(_dio);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await UserPreferences.loadUserData();
    if (mounted) {
      setState(() {
        accessToken = userData['accessToken'];
        memberId = userData['memberId'];
        nickname = userData['nickname'];
      });
    }
    if (accessToken != null) {
      _createChatRoom();
    }
  }

  Future<void> _createChatRoom() async {
    try {
      final response = await _dio.post(
        'http://localhost:8080/chat/room?event=${widget.eventId}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      String roomId = response.data;
      _connectToWebSocket(roomId);
      _fetchMessages(roomId);
    } catch (e) {
      print('채팅방 생성 중 오류 발생: $e');
    }
  }

  void _connectToWebSocket(String roomId) {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8080/ws'),
    );

    _channel.stream.listen((data) {
      setState(() {
        messages.add(data);
      });
    });
  }

  Future<void> _fetchMessages(String roomId) async {
    try {
      final response = await _dio.get(
        'http://localhost:8080/chat/messages?id=$roomId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      setState(() {
        messages = response.data['messages'];
      });
    } catch (e) {
      print('메시지 로드 중 오류 발생: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      String imageUrl = await _apiService.uploadProfileImage(_image!);
      _sendMessageWithImage(imageUrl);
    }
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _channel.sink.add({
        'senderId': memberId,
        'nickname': nickname,
        'message': _messageController.text,
        'file': '',
        'time': DateTime.now().toString(),
      });
      _messageController.clear();
    }
  }

  void _sendMessageWithImage(String imageUrl) {
    _channel.sink.add({
      'senderId': memberId,
      'nickname': nickname,
      'message': '',
      'file': imageUrl,
      'time': DateTime.now().toString(),
    });
  }

  @override
  void dispose() {
    _channel.sink.close(status.normalClosure);
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        middle: Text(widget.eventTitle!),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[index];
                bool isMine = message['senderId'] == memberId;
                return _buildMessageItem(message, isMine);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(dynamic message, bool isMine) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMine) ...[
            ClipOval(
              child: Container(
                width: 30,
                height: 30,
                child: Image.network(
                  message['profileImage'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: isMine ? CupertinoColors.activeBlue : CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (message['message'].isNotEmpty)
                      Text(
                        message['message'],
                        style: TextStyle(color: isMine ? Colors.white : Colors.black),
                      ),
                    if (message['file'].isNotEmpty) 
                      _buildFilePreview(message['file'], isMine),
                  ],
                ),
              ),
              Text(
                message['time'],
                style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilePreview(String fileUrl, bool isMine) {
    if (fileUrl.endsWith('.jpg') || fileUrl.endsWith('.jpeg') || fileUrl.endsWith('.png')) {
      return Container(
        margin: EdgeInsets.only(top: 4),
        child: Image.network(
          fileUrl,
          fit: BoxFit.cover,
          width: 200, 
          height: 200, 
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          print('파일 링크 클릭됨: $fileUrl');
        },
        child: Text(
          '파일: $fileUrl',
          style: TextStyle(color: isMine ? Colors.white : Colors.blue),
        ),
      );
    }
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: _messageController,
              placeholder: '메시지를 입력하세요...',
            ),
          ),
          SizedBox(width: 8),
          CupertinoButton(
            child: Icon(CupertinoIcons.photo),
            onPressed: _pickImage,
          ),
          CupertinoButton(
            child: Text('전송'),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

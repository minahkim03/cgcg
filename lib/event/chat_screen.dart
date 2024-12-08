import 'dart:io';
import 'package:cgcg/api_service/api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
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
  List<dynamic> messages = [];
  final TextEditingController _messageController = TextEditingController();
  String? accessToken;
  String? memberId;
  String? nickname;
  final ImagePicker _picker = ImagePicker();
  File? _image;
  late final ApiService _apiService;
  String? roomId;
  late StompClient stompClient;

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
      stompClient = StompClient( 
        config: StompConfig.sockJS(
          url: "http://localhost:8080/ws", 
          stompConnectHeaders: {
            'Authorization': 'Bearer $accessToken'
          },
          onConnect: onConnectCallback
        )
      );
      stompClient.activate();
    }
  }

  void onConnectCallback(StompFrame connectFrame) {
    print('connected');
    stompClient.subscribe(
      destination: '/room/chat/$roomId', 
      callback: (StompFrame frame) {
        final messageData = {
          'senderId': memberId,
          'nickname': nickname,
          'message': frame.body,
          'file': '', 
        };
        setState(() {
          messages.add(messageData);
        });
      },
    );
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
      setState(() {
        roomId = response.data;
      });
      _fetchMessages(roomId!);
    } catch (e) {
      print('채팅방 생성 중 오류 발생: $e');
    }
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
    if (stompClient.connected && _messageController.text.isNotEmpty) {
      stompClient.send(
        destination: '/message/chat/$roomId',
        body: _messageController.text,
      );
      _messageController.clear();
    } else {
      print("STOMP 클라이언트가 연결되지 않았습니다.");
    }
  }

  void _sendMessageWithImage(String imageUrl) {
    if (_messageController.text.isNotEmpty) {
      stompClient.send(
        destination: '/message/chat/$roomId',
        body: imageUrl,
      );
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    stompClient.deactivate(); 
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
                bool isMine = message['senderId'].toString() == memberId;
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

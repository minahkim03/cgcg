import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import '../user_preferences.dart';
import './add_event_screen4.dart';

class AddEventScreen3 extends StatefulWidget {
  final String eventName;
  final DateTime eventDate;

  AddEventScreen3({required this.eventName, required this.eventDate});

  @override
  _AddEventScreen3State createState() => _AddEventScreen3State();
}

class _AddEventScreen3State extends State<AddEventScreen3> {
  final Dio _dio = Dio();
  List<dynamic> friends = [];
  List<bool> selectedFriends = [];
  String? memberId;
  String? accessToken;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await UserPreferences.loadUserData();
    setState(() {
      memberId = userData['memberId'];
      accessToken = userData['accessToken'];
    });
    if (accessToken != null && memberId != null) {
      _fetchFriends();
    } else {
      print('Access Token or Member ID is null');
    }
  }

  Future<void> _fetchFriends() async {
    try {
      final response = await _dio.get('http://localhost:8080/friend?id=$memberId',options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),);
        
      setState(() {
        friends = response.data['friends'];
        selectedFriends = List<bool>.filled(friends.length, false);
      });
    } catch (e) {
      print('친구 목록 로드 중 오류 발생: $e');
    }
  }

  List<int> _inviteFriends() {
    List<int> invitedFriends = [];
    for (int i = 0; i < selectedFriends.length; i++) {
      if (selectedFriends[i]) {
        invitedFriends.add(friends[i]['id']);
      }
    }
    return invitedFriends;
  }

  void _navigateToNextPage() {
    List<int> friends =_inviteFriends();
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => AddEventScreen4(
          eventName: widget.eventName,
          eventDate: widget.eventDate,
          selectedMembers: friends,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('새로운 이벤트 생성'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '초대할 친구를 선택해주세요.',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  return FriendCard(
                    profileImage: friends[index]['profileImage'],
                    nickname: friends[index]['nickname'],
                    id: friends[index]['id'],
                    isSelected: selectedFriends[index],
                    onSelected: (bool value) {
                      setState(() {
                        selectedFriends[index] = value;
                      });
                    },
                  );
                },
              ),
            ),
            CupertinoButton(
              color: CupertinoColors.activeBlue,
              child: Text('다음으로'),
              onPressed:() {
                _navigateToNextPage();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FriendCard extends StatelessWidget {
  final String profileImage;
  final String nickname;
  final int id;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  FriendCard({
    required this.profileImage,
    required this.nickname,
    required this.isSelected,
    required this.onSelected,
    required this.id
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.systemGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipOval(
            child: Container(
              width: 50,
              height: 50,
              child: Image.network(
                profileImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              nickname,
              style: TextStyle(fontSize: 18),
            ),
          ),
          CupertinoSwitch(
            value: isSelected,
            onChanged: onSelected,
          ),
        ],
      ),
    );
  }
}

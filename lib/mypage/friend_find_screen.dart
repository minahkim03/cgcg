import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import '../user_preferences.dart';
import '../event/add_event_screen1.dart';
import '../home_page.dart';
import '../invitation/invitations_screen.dart';

class FriendFindScreen extends StatefulWidget {
  @override
  _FriendFindScreenState createState() => _FriendFindScreenState();
}

class _FriendFindScreenState extends State<FriendFindScreen> {
  final Dio _dio = Dio();
  final TextEditingController _codeController = TextEditingController();
  String? profileImage;
  String? nickname;
  String? accessToken;
  int? friendId;
  bool _isFriendAdded = false;
  String? memberId;

  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await UserPreferences.loadUserData();
    setState(() {
      accessToken = userData['accessToken'];
      memberId = userData['memberId'];
    });
  }

  void _searchFriend() async {
    final code = _codeController.text;
    if (code.isNotEmpty) {
      try {
        final response = await _dio.get(
          'http://localhost:8080/friend/find?code=$code',
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );
        setState(() {
          profileImage = response.data['profileImage'];
          nickname = response.data['nickname'];
          friendId = response.data['id'];
        });
      } catch (e) {
        print('친구 검색 중 오류 발생: $e');
      }
    }
  }

  void _addFriend() async {
    try {
      await _dio.patch(
        'http://localhost:8080/friend/add?id=$memberId&friend=$friendId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      setState(() {
        _isFriendAdded = true;
      });
    } catch (e) {
      print('친구 추가 중 오류 발생: $e');
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index; 
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildCurrentPage() {
      switch (_selectedIndex) {
        case 0:
          return AddEventScreen1();
        case 1:
          return HomePage();
        case 2:
          return InvitationsScreen();
        default:
          return FriendFindContent(
            profileImage: profileImage,
            nickname: nickname,
            friendId: friendId,
            memberId: memberId,
            isFriendAdded: _isFriendAdded,
            addFriend: _addFriend,
            codeController: _codeController,
            searchFriend: _searchFriend,
          );
      }
    }

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.add),
            label: '이벤트 추가',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.mail),
            label: '초대 확인',
          ),
        ],
        onTap: _onTabTapped, 
      ),
      tabBuilder: (context, index) {
        return _buildCurrentPage(); 
      },
    );
  }
}

class FriendFindContent extends StatelessWidget {
  final String? profileImage;
  final String? nickname;
  final String? memberId;
  final int? friendId;
  final bool isFriendAdded;
  final Function() addFriend;
  final Function() searchFriend;
  final TextEditingController codeController;

  FriendFindContent({
    required this.profileImage,
    required this.nickname,
    required this.memberId,
    required this.friendId,
    required this.addFriend,
    required this.isFriendAdded,
    required this.codeController,
    required this.searchFriend,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('친구 찾기'),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: codeController,
                    placeholder: '친구 코드 입력',
                  ),
                ),
                SizedBox(width: 8),
                CupertinoButton(
                  color: CupertinoColors.activeBlue,
                  child: Text('검색'),
                  onPressed: searchFriend,
                ),
              ],
            ),
            SizedBox(height: 20),
            if (profileImage != null && nickname != null) ...[
              Center(
                child: ClipOval(
                  child: Container(
                    width: 100,
                    height: 100,
                    child: Image.network(
                      profileImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  nickname!,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: CupertinoButton(
                  color: isFriendAdded ? CupertinoColors.systemGrey : CupertinoColors.activeGreen,
                  child: Text(isFriendAdded ? '친구' : '친구 추가하기'),
                  onPressed: isFriendAdded ? null : addFriend,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

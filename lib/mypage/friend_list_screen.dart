import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import '../user_preferences.dart';
import '../event/add_event_screen1.dart';
import '../home_page.dart';
import '../invitation/invitations_screen.dart';

class FriendListScreen extends StatefulWidget {
  @override
  _FriendListScreenState createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  final Dio _dio = Dio();
  List<dynamic> friends = [];
  String? memberId;
  String? accessToken;
  int? _selectedIndex; 

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
      });
    } catch (e) {
      print('친구 목록 로드 중 오류 발생: $e');
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
          return FriendListContent(
            friends:friends
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

class FriendListContent extends StatelessWidget {
  final List<dynamic> friends;
  FriendListContent ({
    required this.friends,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('친구 목록'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  return FriendCard(
                    profileImage: friends[index]['profileImage'],
                    nickname: friends[index]['nickname']
                  );
                },
              ),
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

  FriendCard({
    required this.profileImage,
    required this.nickname
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
        ],
      ),
    );
  }
}

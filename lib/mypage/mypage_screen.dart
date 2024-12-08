import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import '../user_preferences.dart';
import '../home_page.dart'; 
import '../event/add_event_screen1.dart'; 
import '../invitation/invitations_screen.dart'; 
import './friend_find_screen.dart';
import './friend_list_screen.dart';

class MyPageScreen extends StatefulWidget {
  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final Dio _dio = Dio();
  String? profileImage;
  String? nickname;
  String? memberId;
  String? code;
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
      profileImage = userData['profileImage'];
      memberId = userData['memberId'];
      nickname = userData['nickname'];
      accessToken = userData['accessToken'];
    });
    if(accessToken!=null) {
      _fetchCode();
    }
  }

  Future<void> _fetchCode() async {
    if (memberId != null) {
      try {
        final response = await _dio.get('http://localhost:8080/code?id=$memberId', 
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),);
        setState(() {
          code = response.data;
        });
      } catch (e) {
        print('친구 코드 로드 중 오류 발생: $e');
      }
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
          return MyPageContent(
            profileImage: profileImage,
            nickname: nickname,
            code: code,
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

class MyPageContent extends StatelessWidget {
  final String? profileImage;
  final String? nickname;
  final String? code;

  MyPageContent({
    this.profileImage,
    this.nickname,
    this.code,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('마이페이지'),
      ),
      child: Padding(
      padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Container(
                width: 100,
                height: 100,
                color: CupertinoColors.systemGrey2,
                child: profileImage != null
                    ? Image.network(
                        profileImage!,
                        fit: BoxFit.cover,
                      )
                    : Icon(CupertinoIcons.person, size: 50),
              ),
            ),
            SizedBox(height: 16),
            Text(
              nickname ?? '닉네임 없음',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '친구코드: ${code ?? '로딩 중...'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => FriendListScreen()),
                    );
                  },
                  child: Text('친구 목록'),
                ),
                CupertinoButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => FriendFindScreen()),
                    );
                  },
                  child: Text('친구 찾기'),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}

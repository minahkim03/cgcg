import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import 'user_preferences.dart';
import 'mypage/mypage_screen.dart';
import 'event/add_event_screen1.dart';
import 'invitation/invitations_screen.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Dio _dio = Dio();
  List<dynamic> events = [];
  String? profileImage;
  String? memberId;
  String? accessToken;

  int _selectedIndex = 1; 

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await UserPreferences.loadUserData();
    if(mounted){
      setState(() {
        profileImage = userData['profileImage'];
        memberId = userData['memberId'];
        accessToken = userData['accessToken'];
      });
    }
    if(accessToken!=null){
       _fetchEvents();
    }
  }

  Future<void> _fetchEvents() async {
    if (memberId != null) {
      try {
        final response = await _dio.get(
        'http://localhost:8080/main?id=$memberId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
        if (mounted) {
          setState(() {
            events = response.data['events'];
          });
        }
      } catch (e) {
        print('이벤트 로드 중 오류 발생: $e');
      }
    }
  }

  void _onTabTapped(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildCurrentPage() {
      switch (_selectedIndex) {
        case 0:
          return AddEventScreen1();
        case 1:
          return HomePageContent(
            profileImage: profileImage,
            memberId : memberId,
            events : events
          );
        case 2:
          return InvitationsScreen();
        default:
          return HomePageContent(
            profileImage: profileImage,
            memberId : memberId,
            events : events
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

class HomePageContent extends StatelessWidget {
  final String? profileImage;
  final String? memberId;
  final List<dynamic> events;

  HomePageContent({
    this.profileImage,
    this.memberId,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: profileImage != null
            ? GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => MyPageScreen())
                  );
                },
                child: ClipOval(
                  child: Container(
                    width: 40,
                    height: 40,
                    child: Image.network(
                      profileImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            : Container(),
        middle: Text('메인 화면'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  final String image = event['image'];
                  final String date = event['date'];
                  final String title = event['title'];
                  final int id = event['id'];
                  final int participantNumber = event['participantNumber'];
                  final String participantName = event['participantName'];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => EventScreen())
                      );
                      print(id);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(image),
                              fit: BoxFit.cover,
                            ),
                          ),
                          height: 100,
                        ),
                        Text(
                          title,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          date,
                          style: TextStyle(color: CupertinoColors.systemGrey),
                        ),
                        Text(
                          participantNumber != 1 ? 
                          '$participantName님 외 ${participantNumber - 1}명' : '$participantName님',
                          style: TextStyle(color: CupertinoColors.systemGrey),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
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


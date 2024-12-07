import 'package:flutter/cupertino.dart';
import '../user_preferences.dart';
import '../event/add_event_screen1.dart';
import '../home_page.dart';
import '../invitation/invitations_screen.dart';
import './chat_screen.dart';

class ParticipantsScreen extends StatefulWidget {
  final List<dynamic> members;
  final int? eventId;
  final String? eventTitle;
  ParticipantsScreen({required this.members, required this.eventId, required this.eventTitle});
  @override
  _ParticipantsScreenState createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends State<ParticipantsScreen> {
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
      accessToken = userData['accessToken'];
    });
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
          return ParticipantsScreenContent(
            friends:widget.members,
            eventId: widget.eventId,
            eventTitle: widget.eventTitle,
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

class ParticipantsScreenContent extends StatelessWidget {
  final List<dynamic> friends;
  final int? eventId;
  final String? eventTitle;

  ParticipantsScreenContent ({
    required this.friends,
    required this.eventId,
    required this. eventTitle
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('참여 인원'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CupertinoButton(
              color: CupertinoColors.activeBlue,
              child: Text('채팅하기'),
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => ChatScreen(eventId: eventId, eventTitle: eventTitle,)),
                );
              },
            ),
            SizedBox(height: 16),
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

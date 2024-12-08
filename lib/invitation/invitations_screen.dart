import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import '../user_preferences.dart';
import '../home_page.dart';
import '../event/add_event_screen1.dart';

class InvitationsScreen extends StatefulWidget {
  @override
  _InvitationsScreenState createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  final Dio _dio = Dio();
  List<dynamic> invitations = [];
  String? memberId;
  int _selectedIndex = 2;
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
    if (accessToken != null) {
      _fetchInvitations();
    }
  }

  Future<void> _fetchInvitations() async {
    if (memberId != null) {
      try {
        final response = await _dio.get(
          'http://localhost:8080/invitations?id=$memberId',
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );
        setState(() {
          invitations = response.data['invitations'];
        });
      } catch (e) {
        print('초대 로드 중 오류 발생: $e');
      }
    }
  }

  void _acceptInvitation(int invitationId) async {
    try {
      await _dio.patch('http://localhost:8080/invitations?id=$invitationId&accept=true', options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),);
      setState(() {
        invitations.removeWhere((inv) => inv['id'] == invitationId);
      });
    } catch (e) {
      print('초대 수락 중 오류 발생: $e');
    }
  }

  void _declineInvitation(int invitationId) async {
    try {
      await _dio.patch('http://localhost:8080/invitations?id=$invitationId&accept=false', options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),);
      setState(() {
        invitations.removeWhere((inv) => inv['id'] == invitationId);
      });
    } catch (e) {
      print('초대 거절 중 오류 발생: $e');
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
          return InvitationsContent(
            invitations: invitations,
            onAccept: _acceptInvitation, 
            onDecline: _declineInvitation,
          );
        default:
          return InvitationsContent(
            invitations: invitations,
            onAccept: _acceptInvitation, 
            onDecline: _declineInvitation,
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

class InvitationsContent extends StatelessWidget {
  final List<dynamic> invitations;
  final Function(int) onAccept; 
  final Function(int) onDecline; 

  InvitationsContent({
    required this.invitations,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.center,
          child: Text(
            '초대',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: invitations.length,
            itemBuilder: (context, index) {
              final invitation = invitations[index];
              return InvitationCard(
                invitation: Invitation(
                  nickname: invitation['nickname'],
                  title: invitation['title'],
                  date: invitation['date'],
                  id: invitation['id'],
                  profileImage: invitation['profileImage'],
                ),
                onAccept: onAccept,
                onDecline: onDecline,
              );
            },
          ),
        ),
      ],
    );
  }
}

class InvitationCard extends StatelessWidget {
  final Invitation invitation;
  final Function(int) onAccept;
  final Function(int) onDecline;

  InvitationCard({
    required this.invitation,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.2),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipOval(
              child: Container(
                width: 70, 
                height: 70,
                child: Image.network(
                  invitation.profileImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${invitation.nickname}님이 초대를 보냈어요!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    invitation.title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    invitation.date,
                    style: TextStyle(color: CupertinoColors.systemGrey),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end, 
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), 
                        color: CupertinoColors.activeGreen,
                        child: Text('수락', style: TextStyle(fontSize: 16)),
                        onPressed: () {
                          onAccept(invitation.id);
                        },
                      ),
                      SizedBox(width: 8), 
                      CupertinoButton(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), 
                        color: CupertinoColors.destructiveRed,
                        child: Text('거절', style: TextStyle(fontSize: 16)),
                        onPressed: () {
                          onDecline(invitation.id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Invitation {
  final String nickname;
  final String title;
  final String date;
  final int id;
  final String profileImage;

  Invitation({
    required this.nickname,
    required this.title,
    required this.date,
    required this.id,
    required this.profileImage,
  });
}
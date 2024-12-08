import 'dart:ffi';
import 'dart:io';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import '../user_preferences.dart';
import '../event/add_event_screen1.dart';
import '../home_page.dart';
import '../invitation/invitations_screen.dart';
import './participants_screen.dart';

class EventScreen extends StatefulWidget {
  final int eventId;
  EventScreen({required this.eventId});
  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final Dio _dio = Dio();
  String? title;
  String? date;
  List<dynamic> places = [];
  List<dynamic> members = [];
  String? accessToken;
  int? _selectedIndex; 
  double latitude=0;
  double longitude=0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await UserPreferences.loadUserData();
    if(mounted){
      setState(() {
        accessToken = userData['accessToken'];
      });
    }
    if(accessToken!=null){
       _fetchEventData();
    }
  }

  Future<void> _fetchEventData() async {
    try {
      final response = await _dio.get('http://localhost:8080/event?id=${widget.eventId}',
      options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ));
      setState(() {
        title = response.data['title'];
        date = response.data['date'];
        places = response.data['places'];
        members = response.data['members'];
        final firstPlace = places[0] as Map<String, dynamic>;
        latitude = (firstPlace['latitude'] as num).toDouble();
        longitude = (firstPlace['longitude'] as num).toDouble();
      });
    } catch (e) {
      print('이벤트 데이터 로드 중 오류 발생: $e');
    }
  }
  Set<NMarker> _createMarkers(List<dynamic> places) {
    return places.map((place) {
      return NMarker(
        id: place['id'].toString(), 
        position: NLatLng(
          place['latitude'], 
          place['longitude'],
        ),
      );
    }).toSet();
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
          return HomePage();
        case 2:
          return InvitationsScreen();
        default:
          return EventScreenContent(
            members: members,
            places: places,
            title: title,
            date: date,
            eventId: widget.eventId,
            createMarkers : _createMarkers,
            latitude : latitude,
            longitude : longitude
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

class EventScreenContent extends StatelessWidget {
  final String? title;
  final String? date;
  final List<dynamic> members;
  final List<dynamic> places;
  final int? eventId;
  final Function(List<dynamic>) createMarkers;
  final double latitude;
  final double longitude;

  EventScreenContent({
    this.title,
    this.date,
    this.eventId,
    required this.latitude,
    required this.longitude,
    required this.members,
    required this.places,
    required this.createMarkers
  });

  @override
  Widget build(BuildContext context) {
    final NLatLng initialPosition = NLatLng(36.579183, 128.482823);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('이벤트'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: NaverMap(
                options: NaverMapViewOptions(
                  locationButtonEnable: true,
                  initialCameraPosition: NCameraPosition(target: initialPosition, zoom: 15)
                ),
                onMapReady: (controller) {
                  Set<NMarker> markers = createMarkers(places);
                  controller.addOverlayAll(markers);
                  for (var marker in markers) {
                    final place = places.firstWhere((place) => place['id'].toString() == marker.info.id, orElse: () => null);
                    if (place != null) {
                      print("creating marker");
                      print(marker.info);
                      final infoWindow = NInfoWindow.onMarker(
                        id: marker.info.id,
                        text: place['name'],
                      );
                      marker.openInfoWindow(infoWindow);
                    }
                  }
                },
              ),
            ),
            if (title != null) ...[
              Text(
                title!,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                date!,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
            ],
            SizedBox(height: 20),
            Column(
              children: List.generate(places.length, (index) {
                var place = places[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${index + 1}. ${place['time']} - ${place['name']}'),
                    ],
                  ),
                );
              }),
            ),
            SizedBox(height: 20),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('참여인원'),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(CupertinoIcons.right_chevron),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => ParticipantsScreen(members: members, eventId:eventId, eventTitle: title,)),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: List.generate(members.length, (index) {
                if (index >= 3) return Container();
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ClipOval(
                    child: Container(
                      width: 40,
                      height: 40,
                      child: Image.network(
                        members[index]['profileImage'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }),
            ),
            if (members.length > 3)
              Text('...') 
          ],
        ),
      ),
    );
  }
}

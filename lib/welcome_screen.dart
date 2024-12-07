import 'package:cgcg/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'user_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? profileImage;
  String? nickname;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await UserPreferences.loadUserData();
    setState(() {
      profileImage = userData['profileImage'];
      nickname = userData['nickname'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('환영합니다'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                child: ClipOval(
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
              ),
              SizedBox(height: 20),
              Text(
                '어서오세요, $nickname 님!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              CupertinoButton(
                color: CupertinoColors.activeBlue,
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => HomePage())
                  );
                },
                child: Text('시작하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

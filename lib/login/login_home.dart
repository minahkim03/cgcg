import 'package:flutter/cupertino.dart';
import 'register_screen.dart';
import 'login_screen.dart';

class LoginHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('홈'),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton(
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              color: CupertinoColors.activeBlue,
              child: Text('회원가입'),
            ),
            SizedBox(height: 20), // 버튼 사이 간격
            CupertinoButton(
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => LoginScreen()),
                );
              },
              color: CupertinoColors.activeBlue,
              child: Text('로그인'),
            ),
          ],
        ),
      ),
    );
  }
}

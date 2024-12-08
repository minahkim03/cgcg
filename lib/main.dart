import 'package:cgcg/welcome_screen.dart';
import 'package:flutter/cupertino.dart';
import 'login/login_home.dart';
import 'user_preferences.dart';
import 'home_page.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await NaverMapSdk.instance.initialize(clientId: 'ny3wv784lx');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'ㅊㄱㅊㄱ',
      home: FutureBuilder(
        future: UserPreferences.clearUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CupertinoActivityIndicator());
          } else {
            final userData = snapshot.data;
            //final accessToken = userData?['accessToken'] ;
            final accessToken = "";

            if (accessToken != null && accessToken.isNotEmpty) {
              return WelcomeScreen();
            } else {
              return LoginHome();
            }
          }
        },
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import './add_event_screen2.dart';

class AddEventScreen1 extends StatefulWidget {
  @override
  _AddEventScreen1State createState() => _AddEventScreen1State();
}

class _AddEventScreen1State extends State<AddEventScreen1> {
  final TextEditingController _eventNameController = TextEditingController();

  void _navigateToNextPage() {
    final eventName = _eventNameController.text;
    if (eventName.isNotEmpty) {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => AddEventScreen2(eventName: eventName),
        ),
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('경고'),
          content: Text('이벤트 이름을 입력해주세요.'),
          actions: [
            CupertinoDialogAction(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('새로운 이벤트 생성'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '이벤트 이름을 정해주세요.',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            CupertinoTextField(
              controller: _eventNameController,
              placeholder: '이벤트 이름',
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              clearButtonMode: OverlayVisibilityMode.editing,
            ),
            SizedBox(height: 20),
            CupertinoButton(
              color: CupertinoColors.activeBlue,
              child: Text('다음으로'),
              onPressed: _navigateToNextPage,
            ),
          ],
        ),
      ),
    );
  }
}

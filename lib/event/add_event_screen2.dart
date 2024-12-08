import 'package:flutter/cupertino.dart';
import 'add_event_screen3.dart';

class AddEventScreen2 extends StatefulWidget {
  final String eventName;

  AddEventScreen2({required this.eventName});

  @override
  _AddEventScreen2State createState() => _AddEventScreen2State();
}

class _AddEventScreen2State extends State<AddEventScreen2> {
  DateTime selectedDate = DateTime.now();

  void _navigateToNextPage() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => AddEventScreen3(
          eventName: widget.eventName,
          eventDate: selectedDate,
        ),
      ),
    );
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
              '이벤트의 날짜를 정해주세요.',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            CupertinoButton(
              child: Text(
                '날짜 선택하기: ${selectedDate.toLocal()}'.split(' ')[0],
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) => Container(
                    height: 250,
                    child: CupertinoDatePicker(
                      initialDateTime: selectedDate,
                      onDateTimeChanged: (DateTime newDate) {
                        setState(() {
                          selectedDate = newDate;
                        });
                      },
                      minimumYear: DateTime.now().year,
                      maximumYear: DateTime.now().year + 5,
                      mode: CupertinoDatePickerMode.date,
                    ),
                  ),
                );
              },
              color: CupertinoColors.systemGrey5,
            ),
            SizedBox(height: 20),
            SizedBox(height: 20),
            Center(
              child: CupertinoButton(
                color: CupertinoColors.activeBlue,
                child: Text('다음으로'),
                onPressed: () {
                  _navigateToNextPage();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

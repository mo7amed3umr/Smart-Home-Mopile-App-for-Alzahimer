import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './BackgroundCollectingTask.dart';

class FriendReminder extends StatelessWidget {
  static const route = '/FriendReminder';

  @override
  Widget build(BuildContext context) {
    BackgroundCollectingTask task =
        Provider.of<BackgroundCollectingTask>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: Text(
              'This is your Friend ${task.sample}',
              style: TextStyle(fontSize: 20),
            ),
            margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
          ),
          Card(
            child: Image.asset('assets/images/abdallah_elsayed.jpg'),
            margin: EdgeInsets.all(30),
          ),
          Container(
            child: Text(
              'Memories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
          )
        ],
      ),
    );
  }
}

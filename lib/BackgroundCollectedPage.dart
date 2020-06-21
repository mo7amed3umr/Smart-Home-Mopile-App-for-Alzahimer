import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './BackgroundCollectingTask.dart';

class BackgroundCollectedPage extends StatelessWidget {
  static const route = '/BackgroundCollectedPage';

  @override
  Widget build(BuildContext context) {
    BackgroundCollectingTask task =
        Provider.of<BackgroundCollectingTask>(context);
    print(task.sample);

    print('in BackgroundCollectedPage');
    return Scaffold(
      appBar: AppBar(
        title: Text('Temperature & Humidity'),
      ),
      body: Center(
        child:Text(
          task.sample,
          style: TextStyle(
            fontSize: 18
          ),
        )
      )
    );
  }
}

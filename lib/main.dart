import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial_example/BackgroundCollectedPage.dart';
import 'package:flutter_bluetooth_serial_example/BackgroundCollectingTask.dart';
import 'package:flutter_bluetooth_serial_example/DiscoveryPage.dart';
import 'package:flutter_bluetooth_serial_example/FriendReminder.dart';
import 'package:flutter_bluetooth_serial_example/SelectBondedDevicePage.dart';
import 'package:flutter_bluetooth_serial_example/reminder/medicine_reminder.dart';
import 'package:flutter_bluetooth_serial_example/reminder/src/global_bloc.dart';
import 'package:flutter_bluetooth_serial_example/reminder/src/ui/homepage/homepage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import './BluetoothPage.dart';
import 'helper/local_notications_helper.dart';
import 'package:flutter_bluetooth_serial_example/reminder/medicine_reminder.dart';

final notifications = FlutterLocalNotificationsPlugin();

void main() => runApp(TimelessApp());

class TimelessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BackgroundCollectingTask>(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          routes: {
            '/': (context) => TimelessPage(),
            BluetoothPage.route: (context) => BluetoothPage(),
            BackgroundCollectedPage.route: (context) =>
                BackgroundCollectedPage(),
            DiscoveryPage.route: (context) => DiscoveryPage(),
            ConnectTask.route: (context) => ConnectTask(),
            SelectBondedDevicePage.route: (context) => SelectBondedDevicePage(
                  checkAvailability: false,
                ),
            MedicineReminder.route: (context) => MedicineReminder(),
            FriendReminder.route: (context) => FriendReminder()
          },
        ),
        builder: (context) => BackgroundCollectingTask());
  }
}

class TimelessPage extends StatefulWidget {
  @override
  _TimelessPageState createState() => _TimelessPageState();
}

class _TimelessPageState extends State<TimelessPage> {
  @override
  void initState() {
    super.initState();

    final settingsAndroid = AndroidInitializationSettings('ic_launcher');
    final settingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) =>
            onSelectNotification(payload));

    notifications.initialize(
        InitializationSettings(settingsAndroid, settingsIOS),
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    if (payload != 'Blue') {
      await Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => Provider<GlobalBloc>.value(
                  value: globalBloc,
                  child: HomePage(),
                )),
      );
    } else {
      await Navigator.pushNamed(context, FriendReminder.route);
    }
//    await Navigator.pushNamed(context, BackgroundCollectedPage.route);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Peace of Mind App'),
      ),
      drawer: Drawer(
          elevation: 20.0,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text('Mohamed Omer'),
                accountEmail: Text('madaamari96@gmail.com'),
                decoration: BoxDecoration(color: Colors.blueAccent),
                currentAccountPicture: new Container(
                    width: 190.0,
                    height: 190.0,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.fill,
                            image:
                                AssetImage('assets/images/mohamed_omer.jpg')))),
              ),
              ListTile(
                leading: Icon(Icons.perm_identity),
                title: Text('Your Profile'),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.people),
                title: Text('Your Relatives'),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.bluetooth),
                title: Text('Connect to Bluetooth'),
                onTap: () {
                  Navigator.pushNamed(context, BluetoothPage.route);
                },
              ),
              ListTile(
                leading: Icon(Icons.alarm),
                title: Text('Medicine Reminder'),
                onTap: () {
                  Navigator.pushNamed(context, MedicineReminder.route);
                },
              ),
            ],
          )),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/background.jpeg'),
                fit: BoxFit.fill)),
      ),
    );
  }
}

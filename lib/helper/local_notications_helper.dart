import 'package:flutter/cupertino.dart';
import 'package:flutter_bluetooth_serial_example/BackgroundCollectedPage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meta/meta.dart';

NotificationDetails get Sound {
  final androidChannelSpecifics = AndroidNotificationDetails(
    'channel-id',
    'channel-name',
    'channel-description',
    importance: Importance.Max,
    priority: Priority.Max,
    playSound: true,
  );
  final iOSChannelSpecifics = IOSNotificationDetails(presentSound: false);

  return NotificationDetails(androidChannelSpecifics, iOSChannelSpecifics);
}

Future showSoundNotification(
  FlutterLocalNotificationsPlugin notifications, {
  @required String title,
  @required String body,
  int id = 0,
}) =>
    _showNotification(notifications,
        title: title, body: body, id: id, type: Sound);

Future _showNotification(
  FlutterLocalNotificationsPlugin notifications, {
  @required String title,
  @required String body,
  @required NotificationDetails type,
  int id = 0,
}) =>
    notifications.show(id, title, body, type,payload: 'Blue');


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'helper/local_notications_helper.dart';
import 'main.dart';


class BackgroundCollectingTask with ChangeNotifier {
  BluetoothConnection connection;
  List<int> _buffer = List<int>();
  List<String> samples = [];
  String sample='';

  bool inProgress=false;

  BackgroundCollectingTask();

  void fromConnection() {
    connection.input.listen((data) {
      _buffer += data;
      print('printing data ');
      print(_buffer);
      try {
        //error may happen in decoding
        sample = utf8.decode(_buffer);
        //beginning of new data
        if (sample.contains('#')) {
          sample = sample.substring(sample.indexOf('#'), sample.length);
          _buffer.removeRange(0, _buffer.indexOf('#'.codeUnitAt(0)) + 1);
        }
        //end of new data
        if (sample.contains('\$')) {
          sample = utf8.decode(_buffer);
          sample = sample.substring(0, sample.length - 1);
          showSoundNotification(notifications,
              title: sample, body: 'Your Friend', id: 30);
          print(sample);
          _buffer.removeRange(0, _buffer.indexOf('\$'.codeUnitAt(0)) + 1);
          print(_buffer);
        }
        print('call notifylisner');
        notifyListeners();
      } catch (e) {
        print(e);
      }
    }).onDone(() {
      print('onDone');
      inProgress = false;
      connection =null;
      notifyListeners();
    });
  }

  Future<void> connect(BluetoothDevice server) async {
    this.connection = await BluetoothConnection.toAddress(server.address);
    notifyListeners();
   fromConnection();
  }

  void dispose() {
    connection.dispose();
    print('in dispose');
    notifyListeners();
  }

  Future<void> start() async {
    inProgress = true;
    _buffer.clear();
    samples.clear();
    notifyListeners();
    connection.output.add(ascii.encode('#start\$'));
    await connection.output.allSent; //Sending to 'start' to ardiuno
    _buffer.clear();
    print('in start');
  }

  Future<void> cancel() async {
    inProgress = false;
    connection.output.add(ascii.encode('#stop\$'));
    await connection.finish();
    connection=null;
    notifyListeners();
  }

  Future<void> pause() async {
    inProgress = false;
    connection.output.add(ascii.encode('stop'));
    await connection.output.allSent;
    notifyListeners();
  }

  Future<void> reasume() async {
    inProgress = true;
    connection.output.add(ascii.encode('start'));
    await connection.output.allSent;
    notifyListeners();
  }
}

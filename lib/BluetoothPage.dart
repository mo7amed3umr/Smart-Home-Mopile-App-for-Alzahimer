import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import './DiscoveryPage.dart';
import './SelectBondedDevicePage.dart';
import './BackgroundCollectingTask.dart';
import './BackgroundCollectedPage.dart';

class BluetoothPage extends StatefulWidget {
  static const route = '/MainPage';

  @override
  _BluetoothPage createState() => new _BluetoothPage();
}

class _BluetoothPage extends State<BluetoothPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  Timer _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

  BackgroundCollectingTask _collectingTask;
  bool _autoAcceptPairingRequests = false;
@override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _collectingTask = Provider.of<BackgroundCollectingTask>(context);
  }
  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if (await FlutterBluetoothSerial.instance.isEnabled) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Bluetooth Serial'),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            Divider(),
            ListTile(title: const Text('General')),
            SwitchListTile(
              title: const Text('Enable Bluetooth'),
              value: _bluetoothState.isEnabled,
              onChanged: (bool value) {
                // Do the request and update with the true value then
                future() async {
                  // async lambda seems to not working
                  if (value)
                    await FlutterBluetoothSerial.instance.requestEnable();
                  else {
                    await FlutterBluetoothSerial.instance.requestDisable();
                    _collectingTask.connection =null;
                  }
                }

                future().then((_) {
                  setState(() {});
                });
              },
            ),
            ListTile(
              title: const Text('Bluetooth status'),
              subtitle: Text(_bluetoothState.toString()),
              trailing: RaisedButton(
                child: const Text('Settings'),
                onPressed: () {
                  FlutterBluetoothSerial.instance.openSettings();
                },
              ),
            ),
            ListTile(
              title: const Text('Local adapter address'),
              subtitle: Text(_address),
            ),
            ListTile(
              title: const Text('Local adapter name'),
              subtitle: Text(_name),
              onLongPress: null,
            ),
            ListTile(
                title: _discoverableTimeoutSecondsLeft == 0
                    ? const Text("Discoverable")
                    : Text(
                        "Discoverable for ${_discoverableTimeoutSecondsLeft}s"),
                subtitle: const Text("PsychoX-Luna"),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Checkbox(
                    value: _discoverableTimeoutSecondsLeft != 0,
                    onChanged: null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () async {
                      print('Discoverable requested');
                      final int timeout = await FlutterBluetoothSerial.instance
                          .requestDiscoverable(60);
                      if (timeout < 0) {
                        print('Discoverable mode denied');
                      } else {
                        print(
                            'Discoverable mode acquired for $timeout seconds');
                      }
                      setState(() {
                        _discoverableTimeoutTimer?.cancel();
                        _discoverableTimeoutSecondsLeft = timeout;
                        _discoverableTimeoutTimer =
                            Timer.periodic(Duration(seconds: 1), (Timer timer) {
                          setState(() {
                            if (_discoverableTimeoutSecondsLeft < 0) {
                              FlutterBluetoothSerial.instance.isDiscoverable
                                  .then((isDiscoverable) {
                                if (isDiscoverable) {
                                  print(
                                      "Discoverable after timeout... might be infinity timeout :F");
                                  _discoverableTimeoutSecondsLeft += 1;
                                }
                              });
                              timer.cancel();
                              _discoverableTimeoutSecondsLeft = 0;
                            } else {
                              _discoverableTimeoutSecondsLeft -= 1;
                            }
                          });
                        });
                      });
                    },
                  )
                ])),
            Divider(),
            ListTile(title: const Text('Devices discovery and connection')),
            SwitchListTile(
              title: const Text('Auto-try specific pin when pairing'),
              subtitle: const Text('Pin 1234'),
              value: _autoAcceptPairingRequests,
              onChanged: (bool value) {
                setState(() {
                  _autoAcceptPairingRequests = value;
                });
                if (value) {
                  FlutterBluetoothSerial.instance.setPairingRequestHandler(
                      (BluetoothPairingRequest request) {
                    print("Trying to auto-pair with Pin 1234");
                    if (request.pairingVariant == PairingVariant.Pin) {
                      return Future.value("1234");
                    }
                    return null;
                  });
                } else {
                  FlutterBluetoothSerial.instance
                      .setPairingRequestHandler(null);
                }
              },
            ),
            ListTile(
              title: RaisedButton(
                  child: const Text('Explore discovered devices'),
                  onPressed: () async {
                    final BluetoothDevice selectedDevice =
                        await Navigator.pushNamed<BluetoothDevice>(context, DiscoveryPage.route);

                    if (selectedDevice != null) {
                      print('Discovery -> selected ' + selectedDevice.address);
                    } else {
                      print('Discovery -> no device selected');
                    }
                  }),
            ),
            Divider(),
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: RaisedButton(
                child:(_collectingTask.connection==null)? Text('Connect'):Text('View Data Sent'),
                color: Colors.orangeAccent,
                onPressed: () {
                  Navigator.pushNamed(context, ConnectTask.route);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ConnectTask extends StatelessWidget {
  static const route = '/ConnectTask';

  @override
  Widget build(BuildContext context) {
    final BackgroundCollectingTask _collectingTask =
        Provider.of<BackgroundCollectingTask>(context);
    print('in ConnectTask');
    print(_collectingTask.connection);
    print(_collectingTask.inProgress ?? 'is null');
    return Scaffold(
      appBar: AppBar(
        title: Text('Collect Page'),
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: RaisedButton(
              child: ((_collectingTask.connection != null &&
                      _collectingTask.inProgress)
                  ? const Text('Disconnect and stop background collecting')
                  : const Text('Connect to start background collecting')),
              onPressed: () async {
                if (_collectingTask.connection != null &&
                    _collectingTask.inProgress) {
                  await _collectingTask.cancel();
                } else {
                  final BluetoothDevice selectedDevice =
                      await Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                    return SelectBondedDevicePage(checkAvailability: false);
                  }));
                  if (selectedDevice != null) {
                    await _startBackgroundTask(
                        context, selectedDevice, _collectingTask);
                  }
                }
              },
            ),
          ),
          ListTile(
              title: RaisedButton(
            child: const Text('View background collected data'),
            onPressed: (_collectingTask.connection != null)
                ? () {
                    Navigator.pushNamed(context, BackgroundCollectedPage.route);
                  }
                : null,
          )),
        ],
      ),
    );
  }

  Future<void> _startBackgroundTask(BuildContext context,
      BluetoothDevice server, BackgroundCollectingTask _collectingTask) async {
    try {
      await _collectingTask.connect(server);
      await _collectingTask.start();
    } catch (ex) {
      if (_collectingTask != null) {
        _collectingTask.cancel();
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error occured while connecting'),
            content: Text("${ex.toString()}"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}

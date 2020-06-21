import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial_example/reminder/src/global_bloc.dart';
import 'package:flutter_bluetooth_serial_example/reminder/src/ui/homepage/homepage.dart';

import 'package:provider/provider.dart';
GlobalBloc globalBloc;
class MedicineReminder extends StatefulWidget {
  static const String route = '/MedicineReminder';

  @override
  _MedicineReminderState createState() => _MedicineReminderState();
}

class _MedicineReminderState extends State<MedicineReminder> {

  void initState() {
    globalBloc = GlobalBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<GlobalBloc>.value(value: globalBloc,child:HomePage() ,);
  }
}

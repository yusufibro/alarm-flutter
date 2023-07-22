import 'package:alarm/home.dart';
import 'package:alarm/notification_service.dart';
import 'package:flutter/material.dart';

import 'alarm_analog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocalNotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AlarmAnalogPage(),
    );
  }
}


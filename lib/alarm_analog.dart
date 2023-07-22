import 'dart:async';
import 'dart:typed_data';

import 'package:analog_clock_picker/analog_clock_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

import 'notification_service.dart';

class AlarmAnalogPage extends StatefulWidget {
  const AlarmAnalogPage({super.key});

  @override
  State<AlarmAnalogPage> createState() => _AlarmAnalogPageState();
}

class _AlarmAnalogPageState extends State<AlarmAnalogPage> {
  AnalogClockController analogClockController = AnalogClockController();
  // TimeOfDay _time = TimeOfDay(hour: 7, minute: 15);
  TimeOfDay _time = TimeOfDay.now();
  DateTime now = DateTime.now();
  bool isON = true;
  bool isOFF = false;
  String text = 'START';
  List alarm = [];
  DateTime? formateDate;
  late Timer _timer;
  final player = AudioPlayer();
  late final NotificationService notificationService;

  void check(dynamic data) {
    String _timeString = "${DateTime.now().hour}:${DateTime.now().minute}";
    final now = new DateTime.now();
    DateTime dt = DateTime(now.year, now.month, now.day, TimeOfDay.now().hour,
        TimeOfDay.now().minute);
    final format = DateFormat.jm();

    if (format.format(dt) == data) {
      print('yes doit ');
      _timer.cancel();
    }
  }

  void _selectTime() async {
    TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (newTime != null) {
      setState(() {
        _time = newTime;
      });
      print(newTime.format(context)); //output 10:51 PM
      print(newTime.hour); //output 10:51 PM
      print(newTime.minute); //output 10:51 PM
      DateTime parsedTime =
          DateTime(now.year, now.month, now.day, _time.hour, _time.minute);
      final format = DateFormat.jm();
      print('format ' + format.format(parsedTime).toString());
      alarm.add({
        "time": format.format(parsedTime),
        "isOn": false,
      });
    } else {
      print("Time is not selected");
    }
  }

  void wakeUp() async {
    String audioasset = 'assets/audio/alarm_clock.mp3';
    ByteData bytes = await rootBundle.load(audioasset);
    Uint8List audiobytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    await player.playBytes(audiobytes);
    Future.delayed(Duration(seconds: 2), () async {
      await player.stop();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    LocalNotificationService.initialize();
    notificationService = NotificationService();
    notificationService.initializePlatformNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.alarm),
        onPressed: () {
        _selectTime();
      }),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            ListAlarm(),
          ],
        ),
      ),
    );
  }

  Expanded ListAlarm() {
    return Expanded(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: alarm.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () async {
                print('index' + alarm.toString());
              },
              child: Container(
                height: 70,
                margin: const EdgeInsets.only(bottom: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.deepPurple[400],
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        alarm[index]['time'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Visibility(
                        visible: true,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              alarm[index]['isOn'] = !alarm[index]['isOn'];
                            });
                            if (alarm[index]['isOn'] == false) {
                              print('off');
                              _timer.cancel();
                            } else {
                              print('on');
                              _timer = AlarmComponents(index);
                            }
                          },
                          child: alarm[index]['isOn'] == false
                              ? Text(text)
                              : Text('STOP'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  Timer AlarmComponents(int index) {
    return Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        final now = new DateTime.now();
        DateTime dt = DateTime(now.year, now.month, now.day,
            TimeOfDay.now().hour, TimeOfDay.now().minute);
        final format = DateFormat.jm();

        if (format.format(dt) == alarm[index]['time']) {
          print('yes doit ');
          wakeUp();
          notificationService.showLocalNotification(
            id: 0,
            title: "Time's up",
            body: "Get back to productive activities",
          );
          setState(() {
            alarm[index]['isOn'] = !alarm[index]['isOn'];
          });

          _timer.cancel();
        }
      },
    );
  }
}

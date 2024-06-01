import 'package:firebase_database/firebase_database.dart';

Future<void> sendCommandToESP32() async {
  DatabaseReference connectionRef =
      FirebaseDatabase.instance.ref().child('connectionStatus');

  DataSnapshot snapshot = await connectionRef.get();
  if (snapshot.exists && snapshot.value != null) {
    final status = (snapshot.value as Map)['status'];
    if (status == 'connected') {
      DatabaseReference ref = FirebaseDatabase.instance.ref().child('esp32');
      await ref.set({
        'setString': "It's Working",
        'LED_STATUS': "OFF",
        'ManualInput': "false",
        'SetHour': DateTime.now().hour,
      });
    } else {
      print('ESP32 is not connected. Cannot send command.');
    }
  } else {
    print('No connection status found.');
  }
}

Future<void> deleteSchedule(String key) async {
  DatabaseReference ref =
      FirebaseDatabase.instance.reference().child('schedules').child(key);
  await ref.remove();
}

Future<void> updateScheduleStatus(String key, bool isActive) async {
  DatabaseReference ref =
      FirebaseDatabase.instance.reference().child('schedules').child(key);
  await ref.update({'isActive': isActive});
}

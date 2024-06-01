import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pet_feeder/backend/popup_schedule.dart';
import 'package:pet_feeder/backend/schedule_service.dart';
import 'package:pet_feeder/utils/custom_switch.dart';

class HomeContentContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HomeContentWrapper();
  }
}

class HomeContentWrapper extends StatefulWidget {
  @override
  _HomeContentWrapperState createState() => _HomeContentWrapperState();
}

class _HomeContentWrapperState extends State<HomeContentWrapper> {
  List<Map<String, dynamic>> schedules = [];
  Set<String> selectedScheduleKeys = {};

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  void _loadSchedules() {
    DatabaseReference ref =
        FirebaseDatabase.instance.reference().child('schedules');
    ref.onValue.listen((event) {
      final List<Map<String, dynamic>> newSchedules = [];
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> schedulesMap =
            event.snapshot.value as Map<dynamic, dynamic>;
        schedulesMap.forEach((key, value) {
          newSchedules.add({
            'key': key,
            'time': value['time'],
            'repeat': value['repeat'],
            'portions': value['portions'],
            'isActive': value['isActive'] ?? false,
          });
        });
      }
      setState(() {
        schedules = newSchedules;
      });
    });
  }

  void _deleteSchedules() {
    for (String key in selectedScheduleKeys) {
      deleteSchedule(key);
    }
    setState(() {
      selectedScheduleKeys.clear();
    });
  }

  void _toggleSwitch(String key, bool value) {
    updateScheduleStatus(key, value).then((_) {
      setState(() {
        schedules = schedules.map((schedule) {
          if (schedule['key'] == key) {
            return {
              ...schedule,
              'isActive': value,
            };
          }
          return schedule;
        }).toList();
      });
    });
  }

  void _onLongPress(String key) {
    setState(() {
      if (selectedScheduleKeys.contains(key)) {
        selectedScheduleKeys.remove(key);
      } else {
        selectedScheduleKeys.add(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return HomeContent(
      schedules: schedules,
      onLongPress: _onLongPress,
      selectedScheduleKeys: selectedScheduleKeys,
      deleteSchedules: _deleteSchedules,
      toggleSwitch: _toggleSwitch,
    );
  }
}

class HomeContent extends StatelessWidget {
  final List<Map<String, dynamic>> schedules;
  final void Function(String) onLongPress;
  final Set<String> selectedScheduleKeys;
  final VoidCallback deleteSchedules;
  final void Function(String, bool) toggleSwitch;

  const HomeContent({
    super.key,
    required this.schedules,
    required this.onLongPress,
    required this.selectedScheduleKeys,
    required this.deleteSchedules,
    required this.toggleSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          color: const Color.fromARGB(255, 17, 191, 229),
          height: 400,
          width: double.infinity,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Smart Pet Feeder',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 70),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color.fromARGB(255, 17, 191, 229),
                      ),
                    ),
                    child: IconButton(
                      iconSize: 50.0,
                      icon: Image.asset('assets/add_icon.png'),
                      onPressed: () => addSchedule(context),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color.fromARGB(255, 17, 191, 229),
                        width: 5,
                      ),
                    ),
                    child: IconButton(
                      iconSize: 60.0,
                      icon: Image.asset('assets/bowl_icon.png'),
                      onPressed: () {
                        sendCommandToESP32();
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color.fromARGB(255, 17, 191, 229),
                      ),
                    ),
                    child: IconButton(
                      iconSize: 50.0,
                      icon: Image.asset('assets/delete_icon.png'),
                      onPressed: selectedScheduleKeys.isNotEmpty
                          ? deleteSchedules
                          : null,
                      color: selectedScheduleKeys.isNotEmpty
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 50),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final schedule = schedules[index];
              String daysText = schedule['repeat'];
              if (daysText.split(', ').length == 7) {
                daysText = 'Daily';
              }
              bool isSelected = selectedScheduleKeys.contains(schedule['key']);
              return GestureDetector(
                onLongPress: () => onLongPress(schedule['key']),
                onTap: () {
                  onLongPress(schedule['key']);
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? Colors.red
                            : const Color.fromARGB(255, 17, 191, 229),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              schedule['time'],
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              daysText,
                              style: const TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                            Text(
                              'Feed: ${schedule['portions']} Portion${schedule['portions'] > 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                        CustomSwitch(
                          value: schedule['isActive'],
                          onChanged: (value) {
                            toggleSwitch(schedule['key'], value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

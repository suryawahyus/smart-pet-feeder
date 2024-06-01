import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

void addSchedule(BuildContext context) {
  TextEditingController timeController = TextEditingController();
  List<String> selectedDays = [];
  int portions = 1;
  String selectedTime = "Select Time";
  String selectedDaysText = "Select Days";

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Row(
                    children: <Widget>[
                      Text(
                        selectedTime,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        iconSize: 30.0,
                        icon: Image.asset(
                          'assets/clock_icon.png',
                          width: 30.0,
                          height: 30.0,
                        ),
                        onPressed: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (pickedTime != null) {
                            timeController.text = pickedTime.format(context);
                            setState(() {
                              selectedTime = pickedTime.format(context);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Row(
                    children: <Widget>[
                      Text(
                        selectedDaysText,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () async {
                          await _selectDays(context, selectedDays,
                              (String newSelectedDaysText) {
                            setState(() {
                              selectedDaysText = newSelectedDaysText;
                            });
                          });
                        },
                        iconSize: 30.0,
                        icon: Image.asset(
                          'assets/calender_icon.png',
                          width: 30.0,
                          height: 30.0,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      const Text(
                        "Portions",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        iconSize: 30.0,
                        icon: Image.asset(
                          'assets/min_icon_mini.png',
                          width: 30.0,
                          height: 30.0,
                        ),
                        onPressed: () {
                          if (portions > 1) {
                            setState(() {
                              portions--;
                            });
                          }
                        },
                      ),
                      Text('$portions'),
                      IconButton(
                        iconSize: 30.0,
                        icon: Image.asset(
                          'assets/add_icon_mini.png',
                          width: 30.0,
                          height: 30.0,
                        ),
                        onPressed: () {
                          setState(() {
                            portions++;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Image.asset(
                        'assets/cancel_icon.png',
                        width: 50.0,
                        height: 50.0,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        DatabaseReference ref = FirebaseDatabase.instance
                            .reference()
                            .child('schedules')
                            .push();
                        ref.set({
                          'time': timeController.text,
                          'repeat': selectedDays.join(', '),
                          'portions': portions,
                        }).then((_) {
                          Navigator.pop(context);
                        });
                      },
                      icon: Image.asset(
                        'assets/save_icon.png',
                        width: 50.0,
                        height: 50.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<void> _selectDays(BuildContext context, List<String> selectedDays,
    Function(String) updateSelectedDaysText) async {
  final List<String> days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];
  final List<bool> checked = List<bool>.filled(days.length, false);

  // Mark already selected days
  for (int i = 0; i < days.length; i++) {
    if (selectedDays.contains(days[i])) {
      checked[i] = true;
    }
  }

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter dialogSetState) {
          return AlertDialog(
            title: const Text('Select Days'),
            content: SingleChildScrollView(
              child: ListBody(
                children: List<Widget>.generate(days.length, (int index) {
                  return CheckboxListTile(
                    value: checked[index],
                    title: Text(days[index]),
                    onChanged: (bool? value) {
                      dialogSetState(() {
                        checked[index] = value ?? false;
                      });
                    },
                  );
                }),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  selectedDays.clear();
                  for (int i = 0; i < days.length; i++) {
                    if (checked[i]) {
                      selectedDays.add(days[i]);
                    }
                  }
                  String newSelectedDaysText =
                      selectedDays.length == days.length
                          ? "Daily"
                          : selectedDays.join(', ');

                  updateSelectedDaysText(newSelectedDaysText);

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    },
  );
}

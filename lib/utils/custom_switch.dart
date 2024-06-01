import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  const CustomSwitch(
      {Key? key,
      required value,
      required Null Function(dynamic value) onChanged})
      : super(key: key);

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  bool isSwitchOn = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSwitchOn = !isSwitchOn;
        });
      },
      child: Container(
        width: 60,
        height: 35,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSwitchOn ? Colors.blue : Colors.grey.shade300,
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: AnimatedAlign(
            alignment:
                isSwitchOn ? Alignment.centerRight : Alignment.centerLeft,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

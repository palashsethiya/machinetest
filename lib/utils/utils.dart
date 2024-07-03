import 'package:flutter/material.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

class Utils {
  static showAlertDialog(BuildContext context, String title, String desc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(desc),
          actions: [
            TextButton(
              child: const Text("Okay"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  static isCheckDeviceRooted(BuildContext context) {
    FlutterJailbreakDetection.jailbroken.then((isRooted) => {
          if (isRooted) {Utils.showAlertDialog(context, 'Warning', 'This device is rooted or JailBrake')}
        });
  }
}

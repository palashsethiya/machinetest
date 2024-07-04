import 'package:flutter/material.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
    FlutterJailbreakDetection.jailbroken
        .then((isRooted) => {Utils.showAlertDialog(context, 'Warning', 'This device is ${isRooted ? "" : "not"} rooted or JailBrake')});
  }

  static showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.deepPurple.withOpacity(0.4),
        textColor: Colors.black,
        fontSize: 16.0);
  }
}

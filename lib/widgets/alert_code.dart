import 'dart:math';
import 'package:email_sender/email_sender.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:testtapp/responsive.dart';
import 'package:testtapp/screens/Admin_screen.dart';
import 'package:testtapp/widgets/textfield_design.dart';

late String ValiCode;
late String ValiEnter;

class AlertCode extends StatefulWidget {
  static const String screenRoute = 'alert_code';
  const AlertCode({Key? key});

  @override
  State<AlertCode> createState() => _AlertCodeState();
}

Future<void> generateRandomCode() async {
  Random random = Random();
  String code = '';

  for (int i = 0; i < 4; i++) {
    code += random.nextInt(10).toString();
  }
  ValiCode = code;
  //initialize EmailSender class
  //initialize send method to response variable
}

Future<void> _sendEmail(BuildContext context) async {
  EmailSender emailsender = EmailSender();
  try {
    var response = await emailsender.sendMessage(
        "eventataau@gmail.com", "eevents", "MessageFromEEVENTS", ValiCode);
    if (response["message"] == "emailSendSuccess") {
      print(response);
    } else {
      print("something Failed");
      //for understanding the error
      print(response);
    }
  } catch (e) {
    print(e.toString());
  }
}

class _AlertCodeState extends State<AlertCode> {
  @override
  void initState() {
    super.initState();
    generateRandomCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _sendEmail(context);
            _showAlert(context);
          },
          child: Text('Show Alert'),
        ),
      ),
    );
  }

  void _showAlert(BuildContext context) {
    Alert(
      context: context,
      type: AlertType.error,
      title: "Authentication Required",
      desc: "Please enter your credentials:",
      content: Column(
        children: <Widget>[
          CustomTextField(
              hintText: 'ادخل الرمز',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                ValiEnter = value;
              },
              obscureText: false)
        ],
      ),
      buttons: [
        DialogButton(
          child: Text(
            "Submit",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            if (ValiCode == ValiEnter)
              // Handle authentication logic here
              Navigator.pushNamed(context, AdminScreen.screenRoute);
          },
          width: 120,
        )
      ],
    ).show();
  }
}

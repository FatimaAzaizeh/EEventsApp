import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:testtapp/constants.dart';

class NotFillErrorAlert extends StatefulWidget {
  const NotFillErrorAlert({Key? key}) : super(key: key);

  @override
  _NotFillErrorAlertState createState() => _NotFillErrorAlertState();
}

class _NotFillErrorAlertState extends State<NotFillErrorAlert> {
  bool _alertShown = false;

  @override
  Widget build(BuildContext context) {
    if (!_alertShown) {
      _showErrorAlert();
      _alertShown = true; // Set flag to true after showing the alert
    }
    return Container(); // You can return an empty container or any other widget here
  }

  Future<void> _showErrorAlert() async {
    await QuickAlert.show(
      context: context,
      title: '',
      width: 400,
      customAsset: 'assets/images/error.gif',
      widget: Column(
        children: [
          Text(
            'خطأ',
            style: StyleTextAdmin(
              25,
              Colors.black,
            ), // Custom style for title
          ),
          SizedBox(height: 10),
          Text(
            'الرجاء إدخال كل البيانات المطلوبة',
            style: StyleTextAdmin(
              14,
              AdminButton,
            ), // Custom style for text
          ),
          SizedBox(height: 10),
        ],
      ),
      type: QuickAlertType.error,
      confirmBtnText: 'حسناً',
      confirmBtnTextStyle: StyleTextAdmin(16, Colors.white),
      backgroundColor: Colors.white,
      confirmBtnColor: AdminButton.withOpacity(0.8),
    );
  }
}

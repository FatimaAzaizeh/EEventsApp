import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; //firebase
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/Admin/widgets_admin/TexFieldDesign.dart';

final _firestore = FirebaseFirestore.instance;

class AddAdmin extends StatefulWidget {
  static const String screenRoute = 'Add_Admin';
  const AddAdmin({Key? key}) : super(key: key);

  @override
  _AddAdminState createState() => _AddAdminState();
}

class _AddAdminState extends State<AddAdmin> {
  final ControllerEmail = TextEditingController();
  final ControllerPassword = TextEditingController();
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;
  bool showSpinner = false;

  @override
  @override
  Widget build(BuildContext context) {
    return Column(//mainAxisAlignment: MainAxisAlignment.center,
        children: [
      TextFieldDesign(
        Text: 'إدخال البريد الإلكتروني',
        icon: Icons.account_circle,
        ControllerTextField: ControllerEmail,
        onChanged: (value) {
          email = value;
        },
        obscureTextField: false,
      ),
      TextFieldDesign(
        Text: 'إدخال كلمة المرور',
        icon: Icons.password,
        ControllerTextField: ControllerPassword,
        onChanged: (value) {
          password = value;
        },
        obscureTextField: true,
      ),
      SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: const ButtonStyle(
              animationDuration: Durations.long3,
              backgroundColor: MaterialStatePropertyAll(AdminColor)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('إنشاء حساب مسؤول جديد',
                style: StyleTextAdmin(17, Colors.white)),
          ),
          onPressed: () async {
            setState(() {
              showSpinner = true;
            });

            try {
              final newUser = await _auth.createUserWithEmailAndPassword(
                  email: email, password: password);

              _firestore.collection('adminUser').add({
                'Email': email,
              });
              print('تم اضافة الادمن');
              setState(() {
                showSpinner = false;
                ControllerEmail.clear();
                ControllerPassword.clear();
                QuickAlert.show(
                    context: context,
                    customAsset: 'assets/images/Completionanimation.gif',
                    width: 300,
                    title: 'تم إضافة $email',
                    type: QuickAlertType.success,
                    confirmBtnText: 'إغلاق');
              });
            } catch (e) {
              print(e);
            }
          },
        ),
      ),
    ]);
  }
}

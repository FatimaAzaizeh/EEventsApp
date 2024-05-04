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
    return Padding(
      padding: const EdgeInsets.all(80.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: kColor1.withOpacity(0.3),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(200.0),
          child: Center(
            child: Column(//mainAxisAlignment: MainAxisAlignment.center,
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
                      backgroundColor: MaterialStatePropertyAll(kColor1)),
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
                      final newUser =
                          await _auth.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );

                      if (newUser.user != null) {
                        String? uid = newUser
                            .user!.uid; // Access the UID from the created user

                        _firestore.collection('user_types').add({
                          'id': uid,
                          'name': 'Admin',
                        });
                      }

                      print('تم اضافة الادمن');
                      setState(() {
                        showSpinner = false;
                        ControllerEmail.clear();
                        ControllerPassword.clear();
                        QuickAlert.show(
                            context: context,
                            customAsset:
                                'assets/images/Completionanimation.gif',
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
            ]),
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
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
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      decoration: BoxDecoration(
          borderRadius: BorderRadiusDirectional.circular(5),
          color: ColorPurple_70,
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(96, 96, 96,
                  0.5), // Adjusted to use `Color.fromRGBO` instead of `Color.fromARGB`
              spreadRadius: 7,
              blurRadius: 6,
              offset: Offset(3, 3), // Changes position of the shadow
            ),
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: Text(
                  'المسؤولون',
                  style: StyleTextAdmin(22, AdminButton),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.add,
                  size: 34,
                ),
              ),
            ],
          ),
        ),
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
                backgroundColor: MaterialStatePropertyAll(AdminButton)),
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
                  email: email,
                  password: password,
                );

                if (newUser.user != null) {
                  String? uid =
                      newUser.user!.uid; // Access the UID from the created user

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
      ]),
    );
  }
}

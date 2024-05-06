import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/User.dart';
import 'package:testtapp/screens/Admin/widgets_admin/TexFieldDesign.dart';

class AlertAddAdmin extends StatefulWidget {
  AlertAddAdmin({Key? key}) : super(key: key);

  @override
  State<AlertAddAdmin> createState() => _AlertAddAdminState();
}

Uint8List? fileBytes;

class _AlertAddAdminState extends State<AlertAddAdmin> {
  final _firestore = FirebaseFirestore.instance;
  bool showSpinner = false;
  final ControllerEmail = TextEditingController();
  final ControllerName = TextEditingController();
  final ControllerPassword = TextEditingController();
  String fileName = "لم يتم اختيار صورة ";
  final _auth = FirebaseAuth.instance;
  late String imageUrl;
  late String email;

  late String password;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('إنشاء حساب مسؤول جديد',
              style: StyleTextAdmin(22, Colors.black)),
          Row(
            children: [
              TextButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();
                  if (result != null) {
                    setState(() async {
                      showSpinner = true;
                      try {
                        fileBytes = result.files.first.bytes;
                        fileName = result.files.first.name;
                      } catch (error) {
                        print('Error uploading file: $error');
                        // Handle error
                      } finally {
                        setState(() {
                          showSpinner = false;
                        });
                      }
                    });
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Tooltip(
                      message: 'إضافة صورة', // Tooltip message
                      child: Icon(
                        Icons.add,
                        size: 34,
                        color: ColorPurple_100,
                      ),
                    ),
                    SizedBox(
                        width:
                            8), // Adjust spacing between icon and text as needed
                    Text(
                      fileName,
                      style: StyleTextAdmin(18,
                          fileBytes != null ? ColorPurple_100 : Colors.grey),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFieldDesign(
            Text: 'إدخال الإسم',
            icon: Icons.info_rounded,
            ControllerTextField: ControllerName,
            onChanged: (value) {
              email = value;
            },
            obscureTextField: false,
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
                  backgroundColor: MaterialStatePropertyAll(Colors.black)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('إنشاء حساب  ',
                    style: StyleTextAdmin(17, Colors.white)),
              ),
              onPressed: () async {
                setState(() {
                  showSpinner = true; //ما ببين في مشكلة
                });

                try {
                  final newUser = await _auth.createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  // Upload file to Firebase Storage
                  final TaskSnapshot uploadTask = await FirebaseStorage.instance
                      .ref('uploads/$fileName')
                      .putData(fileBytes!);

                  // Get download URL of the uploaded file
                  imageUrl = await uploadTask.ref.getDownloadURL();

                  // Add the download URL to Firestore
                  if (newUser.user != null) {
                    String? uid = newUser
                        .user!.uid; // Access the UID from the created user
                    UserDataBase newuser = UserDataBase(
                      id: uid,
                      email: ControllerEmail.text,
                      name: ControllerName.text,
                      user_type_id: '1',
                      phone: '',
                      address: '',
                      isActive: true,
                      imageUrl: imageUrl,
                    );
                    await newuser.saveToDatabase();
                  }

                  setState(() {
                    showSpinner = false;
                    ControllerEmail.clear();
                    ControllerPassword.clear();
                    fileBytes = null;
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
        ],
      ),
    );
  }
}

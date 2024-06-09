import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:testtapp/Alert/error.dart';
import 'package:testtapp/Alert/success.dart';
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

  Future<void> uploadFile() async {
    setState(() {
      showSpinner = true; // Show spinner before uploading file
    });

    try {
      // Upload file to Firebase Storage
      final TaskSnapshot uploadTask = await FirebaseStorage.instance
          .ref('uploads/$fileName')
          .putData(fileBytes!);

      // Get download URL of the uploaded file
      imageUrl = await uploadTask.ref.getDownloadURL();
    } catch (error) {
      print('Error uploading file: $error');
      // Handle error
    } finally {
      setState(() {
        showSpinner = false; // Hide spinner after upload completes
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      shadowColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'إنشاء حساب مسؤول جديد',
            style: StyleTextAdmin(22, AdminButton),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();
                  if (result != null) {
                    setState(() {
                      fileBytes = result.files.first.bytes;
                      fileName = result.files.first.name;
                    });
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Tooltip(
                      message: 'إضافة صورة',
                      child: Icon(
                        Icons.add,
                        size: 34,
                        color: ColorPurple_100,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      fileName,
                      style: StyleTextAdmin(
                        18,
                        fileBytes != null ? ColorPurple_100 : Colors.grey,
                      ),
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
            enabled: true,
          ),
          TextFieldDesign(
            Text: 'إدخال البريد الإلكتروني',
            icon: Icons.account_circle,
            ControllerTextField: ControllerEmail,
            onChanged: (value) {
              email = value;
            },
            obscureTextField: false,
            enabled: true,
          ),
          TextFieldDesign(
            Text: 'إدخال كلمة المرور',
            icon: Icons.password,
            ControllerTextField: ControllerPassword,
            onChanged: (value) {
              password = value;
            },
            obscureTextField: true,
            enabled: true,
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                if (ControllerName.text.isEmpty ||
                    ControllerEmail.text.isEmpty ||
                    ControllerPassword.text.isEmpty ||
                    fileBytes == null) {
                  // Show an alert if any required field is empty
                  ErrorAlert(
                      context, 'خطأ', 'الرجاء إدخال كل البيانات المطلوبة');
                } else {
                  await uploadFile(); // Upload file before creating user
                  setState(() {
                    showSpinner = true; // Show spinner while creating user
                  });

                  try {
                    final newUser = await _auth.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );

                    if (newUser.user != null) {
                      String? uid = newUser.user!.uid;
                      UserDataBase newuser = UserDataBase(
                        UID: uid,
                        email: ControllerEmail.text,
                        name: ControllerName.text,
                        user_type_id: FirebaseFirestore.instance
                            .collection('user_types')
                            .doc('1'),
                        phone: '',
                        address: '',
                        isActive: true,
                        imageUrl: imageUrl,
                      );
                      await newuser.saveToDatabase();
                    }

                    // Close only the current dialog
                    Navigator.of(context).pop();

                    // Show QuickAlert dialog after user creation
                    SuccessAlert(context, 'تم إضافة $email');
                  } catch (e) {
                    print(e);
                  } finally {
                    setState(() {
                      showSpinner = false; // Hide spinner after user creation
                    });
                  }
                }
              },
              style: const ButtonStyle(
                animationDuration: Durations.long3,
                backgroundColor: MaterialStatePropertyAll(ColorPink_100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'إنشاء حساب  ',
                  style: StyleTextAdmin(17, Colors.white),
                ),
              ),
            ),
          ),
          if (showSpinner)
            CircularProgressIndicator(), // Show spinner when uploading file or creating user
        ],
      ),
    );
  }
}

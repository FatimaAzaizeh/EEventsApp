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
import 'package:testtapp/models/Classification.dart';
import 'package:testtapp/models/User.dart';
import 'package:testtapp/screens/Admin/widgets_admin/TexFieldDesign.dart';

class AddClassification extends StatefulWidget {
  AddClassification({Key? key}) : super(key: key);

  @override
  State<AddClassification> createState() => _AddClassificationState();
}

class _AddClassificationState extends State<AddClassification> {
  bool showSpinner = false;
  final ControllerId = TextEditingController();
  final ControllerName = TextEditingController();

  late String Name;
  late String Id;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'إنشاء تصنيف جديد',
        style: StyleTextAdmin(22, Colors.black),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFieldDesign(
            Text: 'إدخال الإسم',
            icon: Icons.info_rounded,
            ControllerTextField: ControllerName,
            onChanged: (value) {
              Name = value;
            },
            obscureTextField: false,
            enabled: true,
          ),
          TextFieldDesign(
            Text: 'إدخال رقم التصنيف',
            icon: Icons.account_circle,
            ControllerTextField: ControllerId,
            onChanged: (value) {
              Id = value;
            },
            obscureTextField: false,
            enabled: true,
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                if (ControllerName.text.isEmpty || ControllerId.text.isEmpty) {
                  // Show an alert if any required field is empty
                  QuickAlert.show(
                    context: context,
                    title: 'خطأ',
                    text: 'الرجاء إدخال كل البيانات المطلوبة',
                    type: QuickAlertType.error,
                    confirmBtnText: 'حسناً',
                  );
                } else {
                  setState(() {
                    showSpinner = true; // Show spinner while creating user
                  });
                  try {
                    Classification newClass = new Classification(
                      id: ControllerId.text,
                      description: ControllerName.text,
                    );
                    newClass.addDocumentWithCustomId();
                  } catch (e) {
                    print(e);
                  } finally {
                    setState(() {
                      showSpinner = false; // Hide spinner after user creation
                    });
                    // Close only the current dialog
                    Navigator.of(context).pop();
                    // Show QuickAlert dialog after user creation
                    QuickAlert.show(
                      context: context,
                      customAsset: 'assets/images/Completionanimation.gif',
                      width: 300,
                      title: ' تم إضافة تصنيف جديد $Name',
                      type: QuickAlertType.success,
                      confirmBtnText: 'إغلاق',
                    );
                  }
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'إنشاء تصنيف  ',
                  style: StyleTextAdmin(17, Colors.white),
                ),
              ),
            ),
          ),
          if (showSpinner)
            CircularProgressIndicator(), // Show spinner when creating user
        ],
      ),
    );
  }
}

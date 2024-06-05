import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/Admin/widgets_admin/AlertAddAdmin.dart';
import 'package:testtapp/screens/Admin/widgets_admin/AllAdminView.dart';
import 'package:testtapp/screens/Admin/widgets_admin/TexFieldDesign.dart';

final _firestore = FirebaseFirestore.instance;

class AddAdmin extends StatefulWidget {
  static const String screenRoute = 'Add_Admin';
  const AddAdmin({Key? key}) : super(key: key);

  @override
  _AddAdminState createState() => _AddAdminState();
}

class _AddAdminState extends State<AddAdmin> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      decoration: BoxDecoration(
        border: Border.all(
            color: const Color.fromARGB(165, 255, 255, 255).withOpacity(0.3),
            width: 3),
        borderRadius: BorderRadius.circular(20),
        color: const Color.fromARGB(6, 255, 255, 255).withOpacity(0.22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: Text(
                    'المسؤولين',
                    style: StyleTextAdmin(22, AdminButton),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        showDialog(
                          barrierColor: Colors.grey.withOpacity(0.45),
                          context: context,
                          builder: (context) =>
                              AlertAddAdmin(), // Call AlertAddAdmin within showDialog
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Adjust spacing between icon and text as needed
                          Icon(
                            Icons.add,
                            size: 34,
                            color: ColorPurple_100,
                          ),

                          Text(
                            'إضافة مسؤول',
                            style: StyleTextAdmin(18, AdminButton),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          AllAdminView()
        ],
      ),
    );
  }
}

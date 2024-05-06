import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/Admin/widgets_admin/AlertAddAdmin.dart';
import 'package:testtapp/screens/Admin/widgets_admin/AllAdmin.dart';
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
        borderRadius: BorderRadiusDirectional.circular(5),
        color: Colors.white,
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

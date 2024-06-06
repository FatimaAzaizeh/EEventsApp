import 'dart:math';
import 'package:emailjs/emailjs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/Vendor.dart';
import 'package:toggle_list/toggle_list.dart';

const Color appColor = Colors.black;
const Color iconColor = Colors.black;

class ListReq extends StatefulWidget {
  static const String screenRoute = 'ListReq';

  @override
  State<ListReq> createState() => _ListReqState();
}

class _ListReqState extends State<ListReq> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilderList(),
    );
  }

  // Send accept email to vendor
  static Future<void> sendEmail(String email) async {
    try {
      await EmailJS.send(
        'service_rjv9jb8',
        'template_auv3se8',
        {
          'user_email': email,
        },
        const Options(
          publicKey: 'TpYQwF1u4eoGTKps4',
          privateKey: '3gCIuEMMsyXcrE9MZAUDz',
        ),
      );
      print('SUCCESS! Email sent to $email');
    } catch (error) {
      if (error is EmailJSResponseStatus) {
        print('ERROR... ${error.status}: ${error.text}');
      }
      print(error.toString());
    }
  }

  StreamBuilder<QuerySnapshot<Object?>> StreamBuilderList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('vendor').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        List<DocumentSnapshot> documents = snapshot.data!.docs;

        // Filter documents based on vendor_status_id
        DocumentReference vendorStatusRef =
            FirebaseFirestore.instance.collection('vendor_status').doc('1');

        List<DocumentSnapshot> filteredDocuments = documents.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return data['vendor_status_id'] == vendorStatusRef;
        }).toList();

        if (filteredDocuments.isEmpty) {
          return Center(
            child: Text(
              'لا يوجد طلبات جديدة',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          );
        }

        return Container(
          color: Color.fromARGB(0, 255, 255, 255),
          height: double.maxFinite,
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Center(
              child: ToggleList(
                divider: const SizedBox(height: 10),
                toggleAnimationDuration: const Duration(milliseconds: 400),
                scrollPosition: AutoScrollPosition.begin,
                trailing: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.expand_more),
                ),
                children: filteredDocuments.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return buildToggleListItem(data);
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  void deleteDocument(String id) {
    FirebaseFirestore.instance
        .collection("vendor")
        .where("id", isEqualTo: id)
        .limit(1)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        querySnapshot.docs.first.reference.delete().then(
              (_) => print("Document deleted"),
              onError: (e) => print("Error deleting document: $e"),
            );
      } else {
        print("No document found with id: $id");
      }
    }).catchError((e) => print("Error getting documents: $e"));
  }

  void deleteAccount(String userId) {
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null && user.uid == userId) {
        user.delete().then((_) {
          print("User account deleted");
        }).catchError((e) {
          print("Error deleting user account: $e");
        });
      } else {
        print("User not found with ID: $userId");
      }
    });
  }

  ToggleListItem buildToggleListItem(Map<String, dynamic> data) {
    String logo = data['logo_url'].toString();
    DocumentReference vendorStatusRef =
        FirebaseFirestore.instance.collection('vendor_status').doc('2');

    return ToggleListItem(
      leading: Padding(
        padding: EdgeInsets.all(10),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 20,
          backgroundImage: NetworkImage(logo),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          data['business_name'],
          style: StyleTextAdmin(22, AdminButton),
        ),
      ),
      content: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
              color: const Color.fromARGB(165, 255, 255, 255).withOpacity(0.4),
              width: 3),
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(6, 255, 255, 255).withOpacity(0.22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['bio'],
              style: StyleTextAdmin(18, AdminButton),
            ),
            const SizedBox(height: 8),
            Text(
              data['instagram_url'],
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Divider(
              color: Colors.white,
              height: 2,
              thickness: 2,
            ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceAround,
              buttonHeight: 32.0,
              buttonMinWidth: 90.0,
              children: [
                Tooltip(
                  waitDuration: Duration(milliseconds: 600),
                  message: 'قبول إنشاء الحساب ',
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        Vendor.updateStatusIdInFirestore(
                            vendorStatusRef, data['UID'].toString());
                        //   sendEmail(data['email']);
                      });
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: ColorPurple_100,
                        ),
                        const SizedBox(height: 2.0),
                        Text('موافقة'),
                      ],
                    ),
                  ),
                ),
                Tooltip(
                  waitDuration: Duration(milliseconds: 600),
                  message: 'رفض إنشاء الحساب ',
                  child: TextButton(
                    onPressed: () {
                      deleteDocument(data['UID']);
                      deleteAccount(data['UID']);
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.cancel_sharp,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 2.0),
                        Text('رفض'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      headerDecoration: BoxDecoration(
        border: Border.all(
            color: const Color.fromARGB(165, 255, 255, 255).withOpacity(0.3),
            width: 3),
        borderRadius: BorderRadius.circular(20),
        color: const Color.fromARGB(6, 255, 255, 255).withOpacity(0.22),
      ),
      expandedHeaderDecoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(20),
          // color: const Color.fromARGB(6, 255, 255, 255).withOpacity(0.22),
          ),
    );
  }
}

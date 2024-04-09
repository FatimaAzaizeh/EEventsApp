import 'dart:js';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/Admin/widgets_admin/DesignFun.dart';

import 'package:toggle_list/toggle_list.dart';

const Color appColor = Colors.white;
const Color iconColor = Colors.black;

class ListReq extends StatelessWidget {
  static const String screenRoute = 'ListReq';
  List<String> imageUrls = [
    'https://images.squarespace-cdn.com/content/v1/60f1a490a90ed8713c41c36c/1629223610791-LCBJG5451DRKX4WOB4SP/37-design-powers-url-structure.jpeg',
    'https://images.squarespace-cdn.com/content/v1/60f1a490a90ed8713c41c36c/1629223610791-LCBJG5451DRKX4WOB4SP/37-design-powers-url-structure.jpeg',
    'https://images.squarespace-cdn.com/content/v1/60f1a490a90ed8713c41c36c/1629223610791-LCBJG5451DRKX4WOB4SP/37-design-powers-url-structure.jpeg',
    'https://images.squarespace-cdn.com/content/v1/60f1a490a90ed8713c41c36c/1629223610791-LCBJG5451DRKX4WOB4SP/37-design-powers-url-structure.jpeg',
    'https://images.squarespace-cdn.com/content/v1/60f1a490a90ed8713c41c36c/1629223610791-LCBJG5451DRKX4WOB4SP/37-design-powers-url-structure.jpeg', // Add more image URLs as needed
  ];

  @override
  Widget build(BuildContext context) {
    return FunDesign(
      titleAppBar: 'طلبات إنشاء حساب الشركاء',
      child: StreamBuilderList(),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> StreamBuilderList() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('PartnerRequests').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        List<DocumentSnapshot> documents = snapshot.data!.docs;

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
                children: documents.map((doc) {
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

  ToggleListItem buildToggleListItem(Map<String, dynamic> data) {
    return ToggleListItem(
      leading: const Padding(
        padding: EdgeInsets.all(10),
        child: Icon(
          Icons.account_circle,
          color: Color.fromARGB(169, 14, 13, 13),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          data['companyOwnerName'],
          style: StyleTextAdmin(18, Colors.black),
        ),
      ),
      divider: const Divider(
        color: Colors.white,
        height: 4,
        thickness: 2,
      ),
      content: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(20)),
          color: appColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['accountName'],
              style: StyleTextAdmin(14, Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              data['information'],
              style: StyleTextAdmin(14, Colors.black),
            ),
            const SizedBox(height: 8),
            const Divider(
              color: Colors.white,
              height: 2,
              thickness: 2,
            ),
            //"Scrolling image display."
            Container(
              height: 200,
              child: ListView.builder(
                controller: TrackingScrollController(),
                scrollDirection: Axis.horizontal, // Scroll horizontally
                itemCount: imageUrls.length,

                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                      imageUrls[index],
                    ),
                  );
                },
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceAround,
              buttonHeight: 32.0,
              buttonMinWidth: 90.0,
              children: [
                Tooltip(
                  waitDuration: Duration(milliseconds: 600),
                  message: 'قبول إنشاء الحساب ', // Tooltip message
                  child: TextButton(
                    onPressed: () {
                      // Implement accept logic
                    },
                    child: const Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: iconColor,
                        ), // Icon to display
                        Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                        Text('موافقة'),
                      ],
                    ),
                  ),
                ),
                Tooltip(
                  waitDuration: Duration(milliseconds: 600),
                  message: 'رفض إنشاء الحساب ', // Tooltip message
                  child: TextButton(
                    onPressed: () {
                      // Implement accept logic
                    },
                    child: const Column(
                      children: [
                        Icon(
                          Icons.cancel_sharp,
                          color: iconColor,
                        ), // Icon to display
                        Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
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
      headerDecoration: const BoxDecoration(
        color: appColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      expandedHeaderDecoration: const BoxDecoration(
        color: appColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}

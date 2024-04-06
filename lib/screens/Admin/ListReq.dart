import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toggle_list/toggle_list.dart';

const Color appColor = Color.fromARGB(179, 205, 220, 236);

class ListReq extends StatelessWidget {
  static const String screenRoute = 'ListReq';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(0, 252, 252, 252),
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        title: Text(
          'طلبات إنشاء حساب الشركاء',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
      ),
      body: StreamBuilderList(),
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

        return Padding(
          padding: const EdgeInsets.all(8.0),
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
        );
      },
    );
  }

  ToggleListItem buildToggleListItem(Map<String, dynamic> data) {
    return ToggleListItem(
      leading: const Padding(
        padding: EdgeInsets.all(10),
        child: Icon(Icons.account_circle),
      ),
      title: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          data['companyOwnerName'],
          style: TextStyle(fontSize: 18),
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
          color: appColor.withOpacity(0.15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['accountName'],
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              data['information'],
              style: TextStyle(fontSize: 14),
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
                TextButton(
                  onPressed: () {
                    // Implement accept logic
                  },
                  child: const Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                      Text('قبول'),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Implement reject logic
                  },
                  child: const Column(
                    children: [
                      Icon(
                        Icons.cancel_sharp,
                        color: Color.fromARGB(255, 250, 92, 81),
                      ),
                      Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                      Text('رفض'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      headerDecoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      expandedHeaderDecoration: const BoxDecoration(
        color: appColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}

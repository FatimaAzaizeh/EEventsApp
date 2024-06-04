import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/User.dart';

class AllAdminView extends StatefulWidget {
  const AllAdminView({Key? key}) : super(key: key);

  @override
  State<AllAdminView> createState() => _AllAdminViewState();
}

class _AllAdminViewState extends State<AllAdminView> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: getUsersWithValidUserType(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final validUsers = snapshot.data?.docs ?? [];

        return Container(
          child: SingleChildScrollView(
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: validUsers.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = validUsers[index];
                return Container(
                  width: 400,
                  // color: ColorPurple_20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          radius: 35,
                          backgroundImage: NetworkImage(
                            document['Image_url'],
                          ),
                        ),
                        title: Text(
                          document['name'],
                          style:
                              StyleTextAdmin(14, Colors.black.withOpacity(0.7)),
                        ),
                        subtitle: Text(
                          document['email'],
                          style: StyleTextAdmin(12, Colors.grey),
                        ),
                      ),
                      Divider(),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Stream<QuerySnapshot> getUsersWithValidUserType() {
    // Assuming user_type is a variable defined elsewhere, let's replace it here
    String user_type =
        'admin'; // Change 'admin' to the actual user type you're filtering for

    // Filter the snapshots to only include documents where the user type is valid
    return FirebaseFirestore.instance
        .collection('users')
        .where(
          'user_type_id',
          isEqualTo:
              FirebaseFirestore.instance.collection('user_types').doc('1'),
        )
        .snapshots();
  }
}

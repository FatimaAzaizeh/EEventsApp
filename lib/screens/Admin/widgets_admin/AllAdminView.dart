import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testtapp/constants.dart';

class AllAdminView extends StatelessWidget {
  const AllAdminView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        return SingleChildScrollView(
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              // Check user_type for each document
              if (document['user_type_id'] == '1') {
                return Container(
                  width: 400,
                  //  padding: EdgeInsets.all(10),
                  color: ColorPurple_20,
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
              } else {
                // Return an empty container if user_type is not 1
                return Container();
              }
            },
          ),
        );
      },
    );
  }
}

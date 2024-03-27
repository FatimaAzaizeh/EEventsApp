import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:testtapp/screens/Add_Admin.dart';
import 'package:testtapp/widgets_admin/AdminProfile.dart';
import 'package:testtapp/widgets_admin/mainSectionAdmin.dart';

late User signedInUser;

class AdminScreen extends StatefulWidget {
  static const String screenRoute = 'Admin_screen';
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _auth = FirebaseAuth.instance;
  late String EmailAdmin;
// Create a PageController to manage the pages in the PageView

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        setState(() {
          signedInUser = user;
          EmailAdmin = signedInUser.email!;
          print(signedInUser.email);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(74, 225, 224, 225),
      child: Row(
        children: [
          Positioned(child: SideMenuAdmin(AdminEmail: EmailAdmin)),
          // AdminProfile(),
          mainSectionAdmin(),
        ],
      ),
    );
  }
}

//The SideMenu
class SideMenuAdmin extends StatefulWidget {
  final String AdminEmail;

  SideMenuAdmin({
    super.key,
    required this.AdminEmail,
  });

  @override
  State<SideMenuAdmin> createState() => _SideMenuAdminState();
}

class _SideMenuAdminState extends State<SideMenuAdmin> {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Drawer(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            height: double.maxFinite,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 7),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Color.fromARGB(255, 194, 230, 226),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
                  child: Text(
                    '${widget.AdminEmail}',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                //add New Admin
                buildListTile('أضافة مسؤول جديد', Icons.add, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddAdmin()),
                  );
                }),
                // Approve Orders
                Container(
                  child: buildListTile(
                      'تسجيل الخروج',
                      Icons.logout,
                      //  logout function

                      () {}),
                ),
                // Add Category
                buildListTile('الأعدادات', Icons.account_circle, () {}),
                //Manage Offers
                buildListTile('الأعدادات', Icons.account_circle, () {}),
                //Stakeholder Management
                buildListTile('الأعدادات', Icons.account_circle, () {}),
                //Chat
                buildListTile('الأعدادات', Icons.account_circle, () {}),
                //Account Management
                buildListTile('الأعدادات', Icons.account_circle, () {}),
                //FeedBack
                buildListTile('الأعدادات', Icons.account_circle, () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }

//build the side section Button
  Widget buildListTile(String title, IconData icon, Function onPress) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListTile(
        leading: Icon(
          icon,
          size: 30,
          color: Colors.blue,
        ),
        title: Text(
          title,
          style: TextStyle(
              fontFamily: 'ElMessiri',
              fontSize: 24,
              fontWeight: FontWeight.bold),
        ),
        onTap: () {
          setState(() {
            onPress(); // Navigate to the home page
          });
        },
      ),
    );
  }
}

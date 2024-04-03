import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:testtapp/screens/Add_Admin.dart';
import 'package:testtapp/screens/Event_screen.dart';
import 'package:testtapp/widgets_admin/NewEvent.dart';
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

  Widget _currentMainSection =
      mainSectionAdmin(); // Initially set to mainSectionAdmin

  @override
  void initState() {
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

  void _changeMainSection(Widget newSection) {
    setState(() {
      _currentMainSection = newSection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromARGB(74, 225, 224, 225),
        child: Row(
          children: [
            SideMenuAdmin(
              AdminEmail: EmailAdmin,
              changeMainSection: _changeMainSection,
            ),
            MainSectionContainer(child: _currentMainSection),
          ],
        ),
      ),
    );
  }
}

class MainSectionContainer extends StatelessWidget {
  final Widget child;

  const MainSectionContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 14,
      child: Container(
        child: child,
      ),
    );
  }
}

class SideMenuAdmin extends StatefulWidget {
  final String AdminEmail;
  final Function(Widget) changeMainSection;

  SideMenuAdmin({
    Key? key,
    required this.AdminEmail,
    required this.changeMainSection,
  }) : super(key: key);

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
          padding: const EdgeInsets.all(15.0),
          child: Container(
            height: double.maxFinite,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment
                  .spaceAround, // Distributes space evenly between the children
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 7),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Color.fromARGB(255, 194, 230, 226),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 50),
                  child: Text(
                    '${widget.AdminEmail}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                buildListTile(
                  'أضافة مسؤول جديد',
                  Icons.person_add_alt,
                  () {
                    widget.changeMainSection(AddAdmin());
                  },
                ),
                buildListTile(' طلبات إنشاء حسابات الشركاء',
                    Icons.add_business_outlined, () {}),
                buildListTile('تسجيل حدث أو مناسبة جديدة', Icons.post_add, () {
                  widget.changeMainSection(AddEvent());
                }),
                buildListTile(
                    'الخدمات الخاصة بالمناسبات', Icons.room_service_outlined,
                    () {
                  widget.changeMainSection(EventScreen());
                }),
                buildListTile('إدارة حسابات الشركاء',
                    Icons.account_circle_outlined, () {}),
                buildListTile('إدارة الطلبات', Icons.add_task, () {}),
                buildListTile('تسجيل الخروج', Icons.logout, () {
                  _auth.signOut();
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildListTile(String title, IconData icon, Function onPress) {
    return Padding(
      padding: const EdgeInsets.all(10),
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          setState(() {
            onPress();
          });
        },
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/Event_screen.dart';
import 'package:testtapp/screens/Admin/widgets_admin/Add_Admin.dart';
import 'package:testtapp/screens/Admin/widgets_admin/NewEvent.dart';
import 'package:testtapp/screens/Admin/widgets_admin/mainSectionAdmin.dart';

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
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage(
              'assets/images/image2.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
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
      flex: 3,
      child: Drawer(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        child: Column(
          mainAxisAlignment: MainAxisAlignment
              .spaceAround, // Distributes space evenly between the children
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 7),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/images/bunnyy.png'),
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
            buildListTile('الخدمات الخاصة بالمناسبات',
                Icons.room_service_outlined, () {}),
            buildListTile(
                'إدارة حسابات الشركاء', Icons.account_circle_outlined, () {}),
            buildListTile('إدارة الطلبات', Icons.add_task, () {}),
            buildListTile('تسجيل الخروج', Icons.logout, () {
              _auth.signOut();
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget buildListTile(String title, IconData icon, Function onPress) {
    return ListTile(
      leading: Icon(
        icon,
        size: 30,
        color: Color.fromARGB(255, 14, 1, 1),
      ),
      title: Text(
        title,
        style: TextStyle(
            fontFamily: 'ElMessiri',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(222, 21, 21, 21)),
      ),
      onTap: () {
        setState(() {
          onPress();
        });
      },
      hoverColor: Color.fromARGB(126, 222, 58, 165),
    );
  }
}
//tooltip: 'إنشاء حساب مسؤول جديد', import.
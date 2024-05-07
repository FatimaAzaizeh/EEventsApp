import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/Admin/ListReq.dart';
import 'package:testtapp/screens/Admin/widgets_admin/AllAdmin.dart';
import 'package:testtapp/screens/Admin/widgets_admin/Side_menu.dart';
import 'package:testtapp/screens/Admin/widgets_admin/VendorAccount.dart';
import 'package:testtapp/screens/Admin/widgets_admin/Add_Admin.dart';
import 'package:testtapp/screens/Admin/widgets_admin/NewEvent.dart';
import 'package:testtapp/screens/Admin/widgets_admin/mainSectionAdmin.dart';
import 'package:testtapp/widgets/VendorPanelScreen.dart';

final _auth = FirebaseAuth.instance;

final TextEditingController ControllerSearch = TextEditingController();

class AdminScreen extends StatefulWidget {
  static const String screenRoute = 'Admin_screen';
  const AdminScreen({Key? key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  Widget _currentMainSection = mainSectionAdmin();

  void _changeMainSection(Widget newSection) {
    setState(() {
      _currentMainSection = newSection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBack,
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: SideMenuAdmin(
              changeMainSection: _changeMainSection,
            ),
          ),
          MainSectionContainer(
            titleAppBarText: 'nothing',
            child: _currentMainSection,
          ),
        ],
      ),
    );
  }
}

class MainSectionContainer extends StatelessWidget {
  final Widget child;
  final String titleAppBarText;
  const MainSectionContainer({
    Key? key,
    required this.child,
    required this.titleAppBarText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 14,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: child,
        ),
      ),
    );
  }
}

class SideMenuAdmin extends StatefulWidget {
  final Function(Widget) changeMainSection;

  const SideMenuAdmin({
    Key? key,
    required this.changeMainSection,
  }) : super(key: key);

  @override
  State<SideMenuAdmin> createState() => _SideMenuAdminState();
}

class _SideMenuAdminState extends State<SideMenuAdmin> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Container(
        decoration: BoxDecoration(
          color: kColorBack,
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(0, 96, 96, 96).withOpacity(0.5),
              spreadRadius: 8,
              blurRadius: 7,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: Drawer(
          backgroundColor: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.15,
                alignment: Alignment.topCenter,
                padding: EdgeInsets.fromLTRB(15, 30, 15, 0),
                width: double.maxFinite,
                child: Image(
                  image: AssetImage('assets/images/Logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 40,
                      backgroundImage: NetworkImage(
                          'https://firebasestorage.googleapis.com/v0/b/eeventsapp-183f1.appspot.com/o/profile.png?alt=media&token=b1db5f64-430e-4aac-81f2-1beb47c316c6'),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'name',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        'email',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              Divider(),
              BuildListTile(
                title: 'أضافة مسؤول جديد',
                icon: Icons.person_add_alt,
                onPress: () {
                  widget.changeMainSection(AddAdmin());
                },
                index: 1,
              ),
              SizedBox(height: 20), // Add SizedBox here for spacing
              BuildListTile(
                title: 'طلبات إنشاء حسابات الشركاء ',
                icon: Icons.add_business_outlined,
                onPress: () {
                  widget.changeMainSection(ListReq());
                },
                index: 2,
              ),
              SizedBox(height: 20), // Add SizedBox here for spacing
              BuildListTile(
                title: 'تسجيل حدث أو مناسبة جديدة',
                icon: Icons.post_add,
                onPress: () {
                  widget.changeMainSection(AddEvent());
                },
                index: 3,
              ),
              SizedBox(height: 20), // Add SizedBox here for spacing
              BuildListTile(
                title: 'الخدمات الخاصة بالمناسبات',
                icon: Icons.room_service_outlined,
                onPress: () {
                  widget.changeMainSection(AddEvent());
                },
                index: 4,
              ),
              SizedBox(height: 20), // Add SizedBox here for spacing
              BuildListTile(
                title: 'إدارة حسابات الشركاء',
                icon: Icons.account_circle_outlined,
                onPress: () {
                  setState(() {});
                  widget.changeMainSection(VendorList());
                },
                index: 5,
              ),
              SizedBox(height: 20), // Add SizedBox here for spacing
              BuildListTile(
                title: 'إدارة الأصناف والخدمات ',
                icon: Icons.add_task,
                onPress: () {
                  widget.changeMainSection(AllAdmin());
                },
                index: 6,
              ),
              SizedBox(height: 20), // Add SizedBox here for spacing
              BuildListTile(
                title: 'تسجيل الخروج',
                icon: Icons.logout,
                onPress: () {
                  _auth.signOut();
                  Navigator.pop(context);
                  widget.changeMainSection(VendorList());
                },
                index: 7,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

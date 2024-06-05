import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/Admin/ListReq.dart';
import 'package:testtapp/screens/Admin/widgets_admin/Add_Service.dart';

import 'package:testtapp/screens/Admin/widgets_admin/EventClassification.dart';
import 'package:testtapp/screens/Admin/widgets_admin/SignAV.dart';
import 'package:testtapp/screens/Admin/widgets_admin/VendorAccount.dart';
import 'package:testtapp/screens/Admin/widgets_admin/Add_Admin.dart';
import 'package:testtapp/screens/Admin/widgets_admin/NewEvent.dart';
import 'package:testtapp/screens/Vendor/AllOrders.dart';
import 'package:testtapp/screens/Vendor/StoreStatus.dart';
import 'package:testtapp/screens/Vendor/VendorItem.dart';
import 'package:testtapp/screens/Vendor/VendorProfile.dart';
import 'package:testtapp/screens/Vendor/WorkHour.dart';
import 'package:testtapp/screens/Vendor/dashboard.dart';

final _auth = FirebaseAuth.instance;
String userName = "name";
String userEmail = "email";
String userImage = "";
final TextEditingController ControllerSearch = TextEditingController();

class VendorHome extends StatefulWidget {
  static const String screenRoute = 'VendorHome';
  const VendorHome({Key? key});

  @override
  State<VendorHome> createState() => _VendorHomeState();
}

Future<void> getCurrentUserInfo() async {
  String uid = _auth.currentUser!.uid;

  DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('UID', isEqualTo: uid)
      .get()
      .then((querySnapshot) => querySnapshot.docs.first);

  if (userSnapshot.exists) {
    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

    userName = userData['name'] ?? '';
    userEmail = userData['email'] ?? '';
    userImage = userData['Image_url'] ?? '';
  }
}

class _VendorHomeState extends State<VendorHome> {
  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    await getCurrentUserInfo();
    setState(() {
      userName;
      userEmail;
      userImage;
    });
  }

  final DocumentReference vendorId =
      FirebaseFirestore.instance.collection('item').doc('vendor_id');
  Widget _currentMainSection = Dashboard(); // Default main section

  void _changeMainSection(Widget newSection) {
    setState(() {
      _currentMainSection = newSection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: SideMenuAdmin(
              changeMainSection: _changeMainSection,
            ),
          ),
          MainSectionContainer(
            child: _currentMainSection,
          ),
        ],
      ),
    );
  }
}

class MainSectionContainer extends StatelessWidget {
  final Widget child;

  const MainSectionContainer({
    Key? key,
    required this.child,
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
  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF6F2EF), // Light background color
          boxShadow: [
            BoxShadow(
              color: Color(0x1D616060).withOpacity(0.5),
              spreadRadius: 8,
              blurRadius: 7,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: Drawer(
          backgroundColor: Color(0xFFF6F2EF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    image: DecorationImage(
                      image: AssetImage('assets/images/logo2.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              buildListTile(
                'الصفحه الرئسيه',
                Icons.dashboard,
                () {
                  widget.changeMainSection(Dashboard());
                },
                1,
              ),
              Divider(),
              buildListTile(
                'اضافة المنتجات / الخدمات',
                Icons.sell,
                () {
                  widget.changeMainSection(VendorItem());
                },
                2,
              ),
              Divider(),
              buildListTile(
                'الطلبات',
                Icons.online_prediction_rounded,
                () {
                  widget.changeMainSection(VendorOrders(
                    currentUserUID: _auth.currentUser!.uid.toString(),
                  ));
                },
                3,
              ),
              Divider(),
              buildListTile(
                'تعديل معلومات الحساب',
                Icons.manage_accounts,
                () {
                  setState(() {
                    widget.changeMainSection(ProfileVendor());
                  });
                },
                4,
              ),
              Divider(),
              buildListTile(
                'ساعات العمل',
                Icons.timelapse,
                () {
                  widget.changeMainSection(OpeningHoursPage());
                },
                5,
              ),
              Divider(),
              buildListTile(
                'تسجيل خروج',
                Icons.logout,
                () {
                  _auth.signOut();
                  Navigator.pop(context);
                  Navigator.pushNamed(context, SignIn.screenRoute);
                },
                6,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListTile(
      String title, IconData icon, Function() onPress, int index) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      leading: Icon(
        icon,
        size: 28,
        color: _selectedIndex == index ? Colors.white : Colors.black,
        shadows: [BoxShadow(color: Colors.black, offset: Offset(0, 2))],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          color: _selectedIndex == index ? Colors.white : Colors.black,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedIndex = index;
          onPress();
        });
      },
      selected: _selectedIndex == index,
      selectedTileColor: Color.fromARGB(255, 243, 222, 216),
      hoverColor: Colors.grey[200],
    );
  }
}

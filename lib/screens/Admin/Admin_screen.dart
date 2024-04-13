import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/Admin/ListReq.dart';
import 'package:testtapp/screens/Admin/widgets_admin/TexFieldDesign.dart';
import 'package:testtapp/screens/Admin/widgets_admin/VendorAccount.dart';
import 'package:testtapp/screens/Admin/widgets_admin/Add_Admin.dart';
import 'package:testtapp/screens/Admin/widgets_admin/NewEvent.dart';
import 'package:testtapp/screens/Admin/widgets_admin/mainSectionAdmin.dart';
import 'package:testtapp/screens/MyStepperPage.dart';

//Main Color Kcolor1
final TextEditingController ControllerSearch = TextEditingController();
final List<Color> gradientColors = [kColor0, kColor1, kColor2, kColor3];

class AdminScreen extends StatefulWidget {
  static const String screenRoute = 'Admin_screen';
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  Widget _currentMainSection =
      mainSectionAdmin(); // Initially set to mainSectionAdmin

  @override
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
          SideMenuAdmin(
            changeMainSection: _changeMainSection,
          ),
          MainSectionContainer(
              titleAppBarText: 'nothing', child: _currentMainSection),
        ],
      ),
    );
  }
}

class MainSectionContainer extends StatelessWidget {
  final Widget child;
  final String titleAppBarText;
  const MainSectionContainer(
      {Key? key, required this.child, required this.titleAppBarText})
      : super(key: key);
//"the part of the page that will be changed"
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 14,
      child: child,
    );
  }
}

//Menu
class SideMenuAdmin extends StatefulWidget {
  final Function(Widget) changeMainSection;

  SideMenuAdmin({
    Key? key,
    required this.changeMainSection,
  }) : super(key: key);

  @override
  State<SideMenuAdmin> createState() => _SideMenuAdminState();
}

class _SideMenuAdminState extends State<SideMenuAdmin> {
  final _auth = FirebaseAuth.instance;
  int notificationCount = 3;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Container(
        decoration: BoxDecoration(
          //borderRadius: BorderRadius.circular(40),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors, // Replace kColorX with your defined colors
          ),
        ),
        child: Drawer(
          // Set the background color of the Drawer to transparent
          backgroundColor: Color.fromARGB(0, 255, 255, 255),
          child: Column(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Distributes space evenly between the children
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.only(top: 0),
                  width: double.maxFinite,
                  child: CircleAvatar(
                    radius: 85,
                    backgroundColor: Color.fromARGB(0, 255, 255, 255),
                    backgroundImage: AssetImage('assets/images/logo.png'),
                    child: Text(
                        //'${widget.AdminEmail}',
                        ' إيفِنْتْس',
                        style: StyleTextAdmin(20, AdminColor)),
                  ),
                ),
                buildListTile('أضافة مسؤول جديد', Icons.person_add_alt, () {
                  widget.changeMainSection(AddAdmin());
                }, 0, 1),
                buildListTile(
                    'طلبات إنشاء حسابات الشركاء ', Icons.add_business_outlined,
                    () {
                  widget.changeMainSection(ListReq());
                }, notificationCount, 2),
                buildListTile('تسجيل حدث أو مناسبة جديدة', Icons.post_add, () {
                  widget.changeMainSection(AddEvent());
                }, 0, 3),
                buildListTile('الخدمات الخاصة بالمناسبات',
                    Icons.room_service_outlined, () {}, 0, 4),
                buildListTile(
                    'إدارة حسابات الشركاء', Icons.account_circle_outlined, () {
                  widget.changeMainSection(VendorList());
                }, 0, 5),
                buildListTile('إدارة الأصناف والخدمات ', Icons.add_task, () {
                  widget.changeMainSection(MyStepperPage());
                }, 0, 6),
                buildListTile('تسجيل الخروج', Icons.logout, () {
                  _auth.signOut();
                  Navigator.pop(context);
                }, 0, 7),
              ]),
        ),
      ),
    );
  }

  int _selectedIndex =
      -1; // Track the selected index, -1 means none is selected

  Widget buildListTile(
    String title,
    IconData icon,
    Function() onPress,
    int? notificationCount,
    int index,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        size: 24,
        color: _getTileColor(index),
      ),
      title: Text(
        title,
        style: StyleTextAdmin(17, _getTileColor(index)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: _buildNotificationBadge(notificationCount ?? 0),

      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        onPress();
      },
      selected: _selectedIndex == index,

      selectedTileColor: Colors.white,
      // Adjust selected tile color
    );
  }

  Color _getTileColor(int index) {
    if (_selectedIndex == index) {
      return AdminColor; // Use kColor1 when tile is selected
    } else {
      return Colors.white; // Use white color otherwise
    }
  }

  Widget _buildNotificationBadge(int count) {
    if (count > 0) {
      return Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromARGB(176, 0, 0, 0),
        ),
        child: Text(
          count.toString() + '+',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      );
    } else {
      return SizedBox
          .shrink(); // Return an empty SizedBox if count is 0 or less
    }
  }
}

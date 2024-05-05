import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/Admin/ListReq.dart';
import 'package:testtapp/screens/Admin/widgets_admin/VendorAccount.dart';
import 'package:testtapp/screens/Admin/widgets_admin/Add_Admin.dart';
import 'package:testtapp/screens/Admin/widgets_admin/NewEvent.dart';
import 'package:testtapp/screens/Admin/widgets_admin/mainSectionAdmin.dart';
import 'package:testtapp/widgets/VendorPanelScreen.dart';

final _auth = FirebaseAuth.instance;

//Main Color Kcolor1
//kColor1.withOpacity(0.2);
Color BackgroundAdminPage = Colors.white.withOpacity(0.6);
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
    return Container(
      child: Scaffold(
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
                titleAppBarText: 'nothing', child: _currentMainSection),
          ],
        ),
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
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Scaffold(
            backgroundColor: const Color.fromARGB(0, 255, 255, 255),
            body: child),
      ),
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
  int notificationCount = 3;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 15),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.9),
                kColor2,
              ],
            ),
            // color: Color.fromARGB(255, 243, 197, 191),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(0, 96, 96, 96).withOpacity(0.5),
                spreadRadius: 8,
                blurRadius: 7,
                offset: Offset(3, 3), // changes position of shadow
              ),
            ],
            //color: kColor2,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Drawer(
            // Set the background color of the Drawer to transparent
            backgroundColor: const Color.fromARGB(0, 255, 255, 255),

            child: Column(children: [
              Container(
                height: MediaQuery.sizeOf(context).height * 0.3,
                //color: Colors.white,
                alignment: Alignment.topCenter,
                padding: EdgeInsets.fromLTRB(15, 30, 15, 50),
                width: double.maxFinite,
                child: Image(
                  image: AssetImage('assets/images/logo9.png'),
                  fit: BoxFit.cover,
                ),
              ),
              Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                buildListTile('أضافة مسؤول جديد', Icons.person_add_alt, () {
                  widget.changeMainSection(AddAdmin());
                }, 0, 1),
                SizedBox(
                  height: 20,
                ),
                buildListTile(
                    'طلبات إنشاء حسابات الشركاء ', Icons.add_business_outlined,
                    () {
                  widget.changeMainSection(ListReq());
                }, notificationCount, 2),
                SizedBox(
                  height: 20,
                ),
                buildListTile('تسجيل حدث أو مناسبة جديدة', Icons.post_add, () {
                  widget.changeMainSection(AddEvent());
                }, 0, 3),
                SizedBox(
                  height: 20,
                ),
                buildListTile(
                    'الخدمات الخاصة بالمناسبات', Icons.room_service_outlined,
                    () {
                  widget.changeMainSection(VendorPanelScreen());
                }, 0, 4),
                SizedBox(
                  height: 20,
                ),
                buildListTile(
                    'إدارة حسابات الشركاء', Icons.account_circle_outlined, () {
                  widget.changeMainSection(VendorList());
                }, 0, 5),
                SizedBox(
                  height: 20,
                ),
                buildListTile(
                    'إدارة الأصناف والخدمات ', Icons.add_task, () {}, 0, 6),
                SizedBox(
                  height: 20,
                ),
                /*buildListTile('تسجيل الخروج', Icons.logout, () {
                    _auth.signOut();
                    Navigator.pop(context);
                  }, 0, 7),*/
              ])
            ]),
          ),
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
      contentPadding: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        // Set shape with rounded corners
        borderRadius: BorderRadius.circular(10),
      ),
      leading: Icon(
        icon, size: 28, color: _getTileColor(index),
        shadows: [Shadow(color: _getTileColor(index), offset: Offset(0, 2))],
        //_getTileColor(index),
      ),
      title: Text(
        title,
        style: StyleTextAdmin(18, _getTileColor(index)),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),

      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        onPress();
      },
      selected: _selectedIndex == index,

      selectedTileColor: kColorBack,
      hoverColor: const Color.fromARGB(255, 104, 102, 102),
      // Adjust selected tile color
    );
  }

  Color _getTileColor(int index) {
    if (_selectedIndex == index) {
      return Colors.black; // Use kColor1 when tile is selected
    } else {
      return Color.fromARGB(255, 68, 67, 67); // Use white color otherwise
    }
  }
}

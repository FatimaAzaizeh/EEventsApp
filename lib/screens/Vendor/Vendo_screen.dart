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

class VendorScreen extends StatefulWidget {
  static const String screenRoute = 'Vendo_screen';
  const VendorScreen({super.key});

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
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
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/images/Adm.png',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.1),
        body: Row(
          children: [
            SideMenuAdmin(
              changeMainSection: _changeMainSection,
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
      flex: 16,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Scaffold(
            appBar: AppBar(
              title: Text(
                'مرحبا',
                style: StyleTextAdmin(16, Colors.white),
              ),
              toolbarHeight: MediaQuery.sizeOf(context).height * 0.05,
              backgroundColor: Colors.white.withOpacity(0.6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              actions: <Widget>[
                Row(children: [
                  Container(
                    width: 300,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          hintText: 'بحث',
                          hintStyle: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              color: Colors.black),
                          suffixIcon: Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                    ),
                    tooltip: 'Show Snackbar',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('This is a snackbar')));
                    },
                  ),
                  IconButton(
                      onPressed: () {
                        _auth.signOut();
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.logout,
                        color: Colors.white,
                      )),
                ])
              ],
            ),
            backgroundColor: const Color.fromARGB(0, 255, 255, 255),
            body: Container(
                width: double.maxFinite,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: child,
                ))),
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
            borderRadius: BorderRadius.circular(10),
          ),
          child: Drawer(
            // Set the background color of the Drawer to transparent
            backgroundColor: Colors.white,

            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 50),
              child: Column(children: [
                Container(
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.fromLTRB(15, 30, 15, 50),
                  width: 200,
                  child: Image(image: AssetImage('assets/images/name.png')),
                ),
                Column(children: [
                  buildListTile('أضافة مسؤول جديد', Icons.person_add_alt, () {
                    widget.changeMainSection(AddAdmin());
                  }, 0, 1),
                  buildListTile('طلبات إنشاء حسابات الشركاء ',
                      Icons.add_business_outlined, () {
                    widget.changeMainSection(ListReq());
                  }, notificationCount, 2),
                  buildListTile(
                      'تسجيل حدث أو مناسبة جديدة', Icons.post_add, () {}, 0, 3),
                  buildListTile(
                      'الخدمات الخاصة بالمناسبات', Icons.room_service_outlined,
                      () {
                    widget.changeMainSection(VendorPanelScreen());
                  }, 0, 4),
                  buildListTile(
                      'إدارة حسابات الشركاء', Icons.account_circle_outlined,
                      () {
                    widget.changeMainSection(VendorList());
                  }, 0, 5),
                  buildListTile(
                      'إدارة الأصناف والخدمات ', Icons.add_task, () {}, 0, 6),
                  /*buildListTile('تسجيل الخروج', Icons.logout, () {
                      _auth.signOut();
                      Navigator.pop(context);
                    }, 0, 7),*/
                ])
              ]),
            ),
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
      contentPadding: EdgeInsets.all(20),

      leading: Icon(
        icon,
        size: 24,
        color: _getTileColor(index),
      ),
      title: Text(
        title,
        style: StyleTextAdmin(16, _getTileColor(index)),
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
      return Colors.white; // Use kColor1 when tile is selected
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

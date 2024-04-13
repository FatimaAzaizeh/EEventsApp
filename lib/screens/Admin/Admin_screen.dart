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
      backgroundColor: Colors.white,
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
      child: Padding(
        padding: const EdgeInsets.all(7.0),
        child: Scaffold(
            appBar: AppBar(
              toolbarHeight: MediaQuery.sizeOf(context).height * 0.05,
              backgroundColor: AdminColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              actions: <Widget>[
                Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
                        tooltip: 'Show Snackbar',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('This is a snackbar')));
                        },
                      ),
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
                                  color: AdminColor),
                              suffixIcon: Icon(
                                Icons.check_circle,
                                color: AdminColor,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ])
              ],
            ),
            backgroundColor: Colors.white,
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
                    //إيفِنْتْس
                    child: Text(
                        //'${widget.AdminEmail}',
                        'Eeventş',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'DancingScript',
                            fontWeight: FontWeight.w900,
                            fontSize: 20)),
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

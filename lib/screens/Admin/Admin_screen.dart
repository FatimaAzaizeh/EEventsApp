import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/Admin/ListReq.dart';
import 'package:testtapp/screens/Admin/widgets_admin/DesignFun.dart';
import 'package:testtapp/screens/Admin/widgets_admin/VendorAccount.dart';
import 'package:testtapp/screens/Event_screen.dart';
import 'package:testtapp/screens/Admin/widgets_admin/Add_Admin.dart';
import 'package:testtapp/screens/Admin/widgets_admin/NewEvent.dart';
import 'package:testtapp/screens/Admin/widgets_admin/mainSectionAdmin.dart';
import 'package:testtapp/screens/MyStepperPage.dart';

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
      backgroundColor: Color.fromARGB(8, 158, 158, 158),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        /*  decoration: const BoxDecoration(
                image: DecorationImage(
          image: AssetImage(
            'assets/images/Admin.png',
          ),
          fit: BoxFit.cover,
        )
            )*/
        child: Row(
          children: [
            SideMenuAdmin(
              AdminEmail: EmailAdmin,
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
      flex: 14,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: kColor4
                    .withOpacity(0.5), // Color of the shadow with opacity
                spreadRadius: 8, // Amount of spreading of the shadow
                blurRadius: 7, // Amount of blurring of the shadow
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: child,
        ),
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
  int notificationCount = 3;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), bottomLeft: Radius.circular(50)),
            // shape: BoxShape.rectangle,
            // border: Border.all(width: 1, color: kColor0),

            boxShadow: [
              BoxShadow(
                color: kColor4
                    .withOpacity(0.5), // Color of the shadow with opacity
                spreadRadius: 8, // Amount of spreading of the shadow
                blurRadius: 7, // Amount of blurring of the shadow
                offset: Offset(0, 3),
                // Position of the shadow (horizontal, vertical)
              ),
            ],
          ),
          child: Drawer(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            //shadowColor: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment
                  .spaceAround, // Distributes space evenly between the children
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  // color: kColor1,
                  width: double.maxFinite,
                  child: CircleAvatar(
                    radius: 90,
                    backgroundColor: Color.fromARGB(0, 255, 255, 255),
                    backgroundImage: AssetImage('assets/images/logo.png'),
                    child: Text(
                      //'${widget.AdminEmail}',
                      'Eevents',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: kColor1),
                    ),
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
              ],
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
    int index, // Pass the index of the ListTile
  ) {
    return ListTile(
        leading: Icon(
          icon,
          size: 28,
          color: Color.fromARGB(255, 14, 1, 1),
        ),
        title: Text(
          title,
          style: StyleTextAdmin(14, Colors.black),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: _buildNotificationBadge(notificationCount ?? 0),
        onTap: () {
          setState(() {
            _selectedIndex = index; // Update the selected index
          });
          onPress(); // Call the onPress callback
        },
        selected: _selectedIndex == index, // Check if this index is selected
        hoverColor: kColor2,
        selectedTileColor: kColor2);
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

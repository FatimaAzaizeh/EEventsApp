import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/Admin/ListReq.dart';
import 'package:testtapp/screens/Admin/loginAdmin.dart';
import 'package:testtapp/screens/Admin/widgets_admin/Add_Service.dart';
import 'package:testtapp/screens/Admin/widgets_admin/DisplayAllOrders.dart';
import 'package:testtapp/screens/Admin/widgets_admin/EventClassification.dart';
import 'package:testtapp/screens/Admin/widgets_admin/VendorAccount.dart';
import 'package:testtapp/screens/Admin/widgets_admin/Add_Admin.dart';
import 'package:testtapp/screens/Admin/widgets_admin/NewEvent.dart';
import 'package:testtapp/screens/Admin/widgets_admin/wizard/CreatEventWizard.dart';
import 'package:testtapp/screens/Admin/widgets_admin/wizard/WizardScreen.dart';

final _auth = FirebaseAuth.instance;
String userName = "name";
String userEmail = "email";
String userImage = "";
final TextEditingController ControllerSearch = TextEditingController();

class AdminScreen extends StatefulWidget {
  static const String screenRoute = 'Admin_screen';
  const AdminScreen({Key? key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
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

    userName = userData['name'] ??
        ''; // Save the 'name' field from the user data, or null if it's null
    userEmail = userData['email'] ??
        ''; // Save the 'email' field from the user data, or null if it's null
    userImage = userData['Image_url'];
  }
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  void initState() {
    super.initState();

    initialize();
  }

  void initialize() async {
    await getCurrentUserInfo(); // Wait for getCurrentUserInfo() to complete
    if (userName != null && userEmail != null) {
      setState(() {
        userName;
        userEmail;
        userImage;
      });
      print('User Name: $userName');
      print('User Email: $userEmail');
      // Continue with your initialization logic here
    } else {
      print('User data not available.');
      // Handle the case where user data is not available
    }
  }

  Widget _currentMainSection = Container();

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
              Center(
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(30),
                    image: DecorationImage(
                      image: AssetImage('assets/images/logo2.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 40,
                      backgroundImage: NetworkImage(userImage),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        userEmail,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              Divider(),
              buildListTile(
                'أضافة مسؤول جديد',
                Icons.person_add_alt,
                () {
                  widget.changeMainSection(AddAdmin());
                },
                1,
              ),
              Divider(),
              buildListTile(
                'طلبات إنشاء حسابات الشركاء ',
                Icons.add_business_outlined,
                () {
                  widget.changeMainSection(ListReq());
                },
                2,
              ),
              buildListTile(
                'إدارة حسابات الشركاء',
                Icons.account_circle_outlined,
                () {
                  setState(() {
                    widget.changeMainSection(VendorList());
                  });
                },
                3,
              ),
              Divider(),
              buildListTile(
                'ادارة المناسبات',
                Icons.post_add,
                () {
                  widget.changeMainSection(AddEvent());
                },
                4,
              ),
              buildListTile(
                'ادارة الخدمات',
                Icons.widgets,
                () {
                  widget.changeMainSection(AddService());
                },
                5,
              ),
              buildListTile(
                'إدارة التصنيفات  ',
                Icons.category_outlined,
                () {
                  widget.changeMainSection(EventClassification());
                },
                6,
              ),
              buildListTile(
                'تنظيم مراحل المناسبات ',
                Icons.onetwothree_rounded,
                () async {
                  String? selectedEvent = await showDialog<String>(
                    context: context,
                    builder: (context) => CreateNewEventWizard(),
                  );
                  if (selectedEvent != null) {
                    // Do something with the selected event
                    print('Selected Event: $selectedEvent');
                    widget.changeMainSection(Wizard(
                      EventName: selectedEvent,
                    ));
                  }
                },
                7,
              ),
              buildListTile(
                'الطلبات',
                Icons.online_prediction_rounded,
                () {
                  widget.changeMainSection(DisplayAllOrders());
                },
                8,
              ),
              Divider(),
              buildListTile(
                'تسجيل الخروج',
                Icons.logout,
                () {
                  _auth.signOut();
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AdminLogin.screenRoute);
                },
                9,
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _selectedIndex =
      -1; // Track the selected index, -1 means none is selected

  Expanded buildListTile(
      String title, IconData icon, Function() onPress, int index) {
    return Expanded(
      child: ListView(
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            leading: Icon(
              icon,
              size: 28,
              color: Colors.black, // Color changes based on the selection
              shadows: [BoxShadow(color: Colors.black, offset: Offset(0, 2))],
            ),
            title: Text(
              title,
              style: TextStyle(fontSize: 18, color: Colors.black),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              setState(() {
                _selectedIndex = index; // Update the selected index
                onPress();
              });
            },
            selected: _selectedIndex == index,
            selectedTileColor: Colors.white,
            hoverColor: Colors.white,
          ),
          // Add more ListTiles if needed
        ],
      ),
    );
  }
}

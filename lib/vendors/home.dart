/*
import 'package:flutter/material.dart';

import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:testtapp/screens/home.dart';
import 'package:testtapp/vendors/dashboard_screen.dart';
import 'package:testtapp/vendors/manage_category.dart';
import 'package:testtapp/vendors/manage_item.dart';
import 'home.dart';

class HomeScreen extends StatefulWidget {
  static const String id = "home-screen";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget _selectedScreen = DashboardScreen();
  currentScreen(item) {
    switch (item.route) {
      case DashboardScreen.id:
        setState(() {
          _selectedScreen = DashboardScreen();
        });
        break;
      case ManageCategories.id:
        setState(() {
          _selectedScreen = ManageCategories();
        });
        break;
      case ManageItemScreen.id:
        setState(() {
          _selectedScreen = ManageItemScreen();
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(child: const Text('Vendor Panel')),
      ),
      sideBar: SideBar(
        items: const [
          AdminMenuItem(
            title: 'Dashboard',
            route: DashboardScreen.id,
            icon: Icons.dashboard,
          ),
          AdminMenuItem(
            title: 'Manage category',
            route: ManageCategories.id,
            icon: Icons.dashboard,
          ),
          AdminMenuItem(
            title: 'manage item',
            route: ManageItemScreen.id,
            icon: Icons.pages_rounded,
          ),
        ],
        selectedRoute: HomeScreen.id,
        onSelected: (item) {
          currentScreen(item);
         // if (item.route != null) {
         //   Navigator.of(context).pushNamed(item.route!);
         // }
        }
       /* header: Container(
          height: 50,
          width: double.infinity,
          color: const Color(0xff444444),
          child: const Center(
            child: Text(
              'header',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
        footer: Container(
          height: 50,
          width: double.infinity,
          color: const Color(0xff444444),
          child: const Center(
            child: Text(
              'footer',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),*/
      ),
      body: SingleChildScrollView(
        child: _selectedScreen,
        
      ),
    );
  }
}
*/
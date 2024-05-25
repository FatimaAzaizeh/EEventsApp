import 'package:flutter/material.dart';
import 'package:testtapp/screens/Admin/DraweVendor.dart';
import 'package:testtapp/screens/Admin/displayImage.dart';
import 'package:testtapp/screens/Admin/widgets_admin/SignAV.dart';

class AdminLogin extends StatefulWidget {
  static const String screenRoute = 'loginAdmin';
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:  Color.fromARGB(121, 242, 228, 217),
        title: const Text('ضع خدمتك في أقل من 10 دقائق!'),
      ),
      drawer: DrawerVendor(),
      body: SignIn(),
    );
  }
}

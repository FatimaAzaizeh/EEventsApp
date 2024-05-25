import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:testtapp/firebase_options.dart';

import 'package:testtapp/screens/Admin/Admin_screen.dart';
import 'package:testtapp/screens/Admin/DraweVendor.dart';
import 'package:testtapp/screens/Admin/ListReq.dart';
import 'package:testtapp/screens/Admin/widgets_admin/Add_Service.dart';
import 'package:testtapp/screens/Admin/widgets_admin/AllAdmin.dart';

import 'package:testtapp/screens/Admin/widgets_admin/EventClassification.dart';
import 'package:testtapp/screens/Admin/widgets_admin/SignAV.dart';
import 'package:testtapp/screens/Admin/widgets_admin/VendorAccount.dart';
import 'package:testtapp/screens/Admin/widgets_admin/email_acceptance.dart';
import 'package:testtapp/screens/Admin/widgets_admin/email_send.dart';
import 'package:testtapp/screens/Admin/widgets_admin/wizard/CreatEventWizard.dart';
import 'package:testtapp/screens/Admin/widgets_admin/wizard/WizardScreen.dart';

import 'package:testtapp/screens/Event_screen.dart';
import 'package:testtapp/screens/Vendor/VendorHome.dart';

import 'package:testtapp/screens/loginAdmin.dart';

import 'package:testtapp/screens/Admin/widgets_admin/Add_Admin.dart';

final _auth = FirebaseAuth.instance;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //await Firebase.initializeApp();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.setLoggingEnabled(true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale("ar"), // Arabic
        const Locale("en"), // English (fallback)
      ],
      locale: const Locale('ar'), // Set Arabic as the default locale
      // Set text direction to RTL
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      routes: {
        AdminLogin.screenRoute: (context) => AdminLogin(),
        AdminScreen.screenRoute: (context) => AdminScreen(),
        SignIn.screenRoute: (context) => SignIn(),
        AddAdmin.screenRoute: (context) => AddAdmin(),
        EventScreen.screenRoute: (context) => EventScreen(),
        ListReq.screenRoute: (context) => ListReq(),
        AllAdmin.screenRoute: (context) => AllAdmin(),
        SendEmail.screenRoute: (context) => SendEmail(),
        VendorList.screenRoute: (context) => VendorList(),
        AddService.screenRoute: (context) => AddService(),
        EventClassification.screenRoute: (context) => EventClassification(),
        VendorHome.screenRoute: (context) => VendorHome(),
        CreateNewEventWizard.screenRoute: (context) => CreateNewEventWizard(),
        DrawerVendor.screenRoute: (context) => DrawerVendor(),
      },
      home: AdminLogin(),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:testtapp/constants.dart';

import 'package:testtapp/firebase_options.dart';
import 'package:testtapp/responsive.dart';
import 'package:testtapp/screens/Admin/Admin_screen.dart';
import 'package:testtapp/screens/Admin/ListReq.dart';

import 'package:testtapp/screens/AnimatedTextPage.dart';
import 'package:testtapp/screens/Event_screen.dart';
import 'package:testtapp/screens/loginAdmin.dart';
import 'package:testtapp/screens/login_signup.dart';
import 'package:testtapp/screens/chat_screen.dart';

import 'package:testtapp/screens/Admin/widgets_admin/Add_Admin.dart';
import 'package:testtapp/screens/user/free_shopping_page.dart';
import 'package:testtapp/screens/user/home_page.dart';
import 'package:testtapp/widgets/VendorPanelScreen.dart';

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
    return ChangeNotifierProvider(
        create: (context) => null //Data to be passed to all pages.//
        ,
        child: MaterialApp(
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
            AnimatedTextPage.screenRoute: (context) => AnimatedTextPage(),
            LoginSignupScreen.screenRoute: (context) => LoginSignupScreen(),
            AdminScreen.screenRoute: (context) => AdminScreen(),
            ChatScreen.screenRoute: (context) => ChatScreen(),
            AddAdmin.screenRoute: (context) => AddAdmin(),
            EventScreen.screenRoute: (context) => EventScreen(),
            ListReq.screenRoute: (context) => ListReq(),
            HomePage.screenRoute: (context) => HomePage(),
            FreeShopping.screenRoute: (context) => FreeShopping(),
            SignIn.screenRoute: (context) => SignIn(),
            VendorPanelScreen.screenRoute: (context) => VendorPanelScreen(),
          },
          home: getHomeWidget(context),
        ));
  }
}

Widget getHomeWidget(BuildContext context) {
  if (Responsive.isDesktop(context)) {
    // Check if the app is running on a desktop environment
    if (_auth.currentUser != null) {
      // Check if there's a currently authenticated user
      return AdminScreen(); // If there is an authenticated user, show the AdminScreen
    } else {
      return SignIn();
    }
  } else {
    return VendorPanelScreen();
    //AnimatedTextPage(); // If not running on desktop, show AnimatedTextPage
  }
}

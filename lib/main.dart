import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:testtapp/firebase_options.dart';
import 'package:testtapp/responsive.dart';

import 'package:testtapp/screens/Admin_screen.dart';
import 'package:testtapp/screens/AnimatedTextPage.dart';
import 'package:testtapp/screens/Event_screen.dart';
import 'package:testtapp/screens/Sign_in.dart';
import 'package:testtapp/screens/chat_screen.dart';
import 'package:testtapp/screens/registration_screen.dart';

import 'package:testtapp/widgets/alert_code.dart';
import 'package:testtapp/widgets_admin/Add_Admin.dart';

//main//hiiiiiiiiiiiiiiiii
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
            SignIn.screenRoute: (context) => SignIn(),
            AdminScreen.screenRoute: (context) => AdminScreen(),
            AlertCode.screenRoute: (context) => AlertCode(),
            ChatScreen.screenRoute: (context) => ChatScreen(),
            RegistrationScreen.screenRoute: (context) => RegistrationScreen(),
            AddAdmin.screenRoute: (context) => AddAdmin(),
            EventScreen.screenRoute: (context) => EventScreen(),
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
      return SignIn(); // If there's no authenticated user, show the SignIn screen
    }
  } else {
    return AnimatedTextPage(); // If not running on desktop, show AnimatedTextPage
  }
}

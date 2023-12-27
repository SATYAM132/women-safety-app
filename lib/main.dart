import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/child/bottom_page.dart';
//import 'package:flutter_application_1/home_screen.dart';
import 'package:flutter_application_1/child/child_login_screen.dart';
import 'package:flutter_application_1/db/share_pref.dart';
//import 'package:flutter_application_1/child/bottom_screens/child_home_page.dart';
import 'package:flutter_application_1/parent/parent_home_screen.dart';
import 'package:flutter_application_1/utils/constants.dart';
import 'package:flutter_application_1/utils/flutter_background_service.dart';

import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MySharedPrefence.init();
  await initializeService();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.firaCodeTextTheme(
          Theme.of(context).textTheme,
        ),
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: MySharedPrefence.getUserType(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == "") {
            return LoginScreen();
          }
          if (snapshot.data == "child") {
            return BottomPage();
          }
          if (snapshot.data == "parent") {
            return ParentHomeScreen();
          }
          return progressIndicator(context);
        },
      ),
    );
  }
}

//class CheckAuth extends StatelessWidget {
  //const CheckAuth({super.key});

  //checkData() {
   // if (MySharedPrefence.getUserType() == 'parent') {}
 // }

 // @override
//  Widget build(BuildContext context) {
//    return Scaffold();
 // }
//}

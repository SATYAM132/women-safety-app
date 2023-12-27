import 'package:flutter/material.dart';
import 'package:flutter_application_1/child/bottom_screens/add_contacts.dart';
import 'package:flutter_application_1/child/bottom_screens/chat_page.dart';
import 'package:flutter_application_1/child/bottom_screens/child_home_page.dart';
// import 'package:flutter_application_1/child/bottom_screens/contacts_page.dart';
import 'package:flutter_application_1/child/bottom_screens/profile_page.dart';
import 'package:flutter_application_1/child/bottom_screens/review_page.dart';

// ignore: must_be_immutable
class BottomPage extends StatefulWidget {
  @override
  State<BottomPage> createState() => _BottomPageState();
}

class _BottomPageState extends State<BottomPage> {
  int currentIndex = 0;
  List<Widget> pages = [
    HomeScreen(),
    AddContactsPage(),
    ChatPage(),
    ProfilePage(),
    ReviewPage(),
  ];

  onTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: onTapped,
        items: [
          BottomNavigationBarItem(
              label: 'home',
              icon: Icon(
                Icons.home,
              )),
          BottomNavigationBarItem(
              label: 'contacts',
              icon: Icon(
                Icons.contacts,
              )),
          BottomNavigationBarItem(
              label: 'chats',
              icon: Icon(
                Icons.chat,
              )),
          BottomNavigationBarItem(
              label: 'profile',
              icon: Icon(
                Icons.person,
              )),
          BottomNavigationBarItem(
              label: 'review',
              icon: Icon(
                Icons.reviews,
              )),
        ],
      ),
    );
  }
}

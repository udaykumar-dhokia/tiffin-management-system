import 'package:flutter/material.dart';
import 'package:tiffin/constants/color.dart';
import 'package:tiffin/screens/bill.dart';
import 'package:tiffin/screens/customers/customers.dart';
import 'package:tiffin/screens/homepage.dart';
import 'package:tiffin/screens/profile.dart';
import 'package:tiffin/screens/tiffin.dart';

class Bottombar extends StatefulWidget {
  const Bottombar({super.key});

  @override
  State<Bottombar> createState() => _BottombarState();
}

class _BottombarState extends State<Bottombar> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        backgroundColor: primaryDark,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: primaryColor,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(
              Icons.home,
              color: black,
            ),
            icon: Icon(
              Icons.home,
              color: white,
            ),
            label: 'Home',
            tooltip: "Home",
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.notes_rounded,
              color: black,
            ),
            icon: Icon(
              Icons.notes_rounded,
              color: white,
            ),
            label: 'Bills',
            tooltip: "Bills",
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.local_dining_rounded,
              color: black,
            ),
            icon: Icon(
              Icons.local_dining_rounded,
              color: white,
            ),
            label: 'Bills',
            tooltip: "Bills",
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.groups,
              color: black,
            ),
            icon: Icon(
              Icons.groups,
              color: white,
            ),
            label: 'Customers',
            tooltip: "Custumers",
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.person,
              color: black,
            ),
            icon: Icon(
              Icons.person,
              color: white,
            ),
            label: 'Profile',
            tooltip: "Profile",
          ),
        ],
      ),
      body: <Widget>[
        /// Home page
        const Homepage(),

        /// Recycle page
        const Bill(),

        /// Tiffin
        const Tiffin(),

        /// Customer page
        const Customers(),

        /// Profile page
        const Profile()
      ][currentPageIndex],
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidable/hidable.dart';
import 'package:tiffin/constants/color.dart';
import 'package:tiffin/screens/archived/archived.dart';
import 'package:tiffin/screens/customers/customers.dart';
import 'package:tiffin/screens/dashboard/homepage.dart';
import 'package:tiffin/screens/message_menu/message_menu.dart';
import 'package:tiffin/screens/profile/profile.dart';
import 'package:tiffin/screens/tiffin.dart';

final GlobalKey<_BottombarState> bottombarKey = GlobalKey<_BottombarState>();

class Bottombar extends StatefulWidget {
  const Bottombar({super.key});

  @override
  State<Bottombar> createState() => _BottombarState();
}

class _BottombarState extends State<Bottombar> {
  int currentPageIndex = 0;
  bool isBottomBarVisible = true;
  bool? dark;
  User? user = FirebaseAuth.instance.currentUser;
  bool isLoading = false;
  final ScrollController scrollController = ScrollController();

  void changePage(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  void toggleBottomBar() {
    setState(() {
      isBottomBarVisible = !isBottomBarVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            backgroundColor: primaryColor,
            body: Center(
              child: CircularProgressIndicator(
                color: primaryDark,
              ),
            ),
          )
        : Scaffold(
            // floatingActionButton: FloatingActionButton(
            //   onPressed: () {
            //     setState(() {
            //       isBottomBarVisible = !isBottomBarVisible;
            //     });
            //   },
            //   shape: const CircleBorder(),
            //   foregroundColor: white,
            //   backgroundColor: primaryDark,
            //   child: Icon(isBottomBarVisible? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded),
            // ),
            // floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
            bottomNavigationBar: Hidable(
              controller: scrollController,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: Wrap(
                  children: [
                    Visibility(
                      visible: isBottomBarVisible,
                      child: NavigationBar(
                        height: 60,
                        labelBehavior:
                            NavigationDestinationLabelBehavior.alwaysHide,
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
                              Icons.local_dining_rounded,
                              color: black,
                            ),
                            icon: Icon(
                              Icons.local_dining_outlined,
                              color: white,
                            ),
                            label: 'Tiffins',
                            tooltip: "Tiffins",
                          ),
                          NavigationDestination(
                            selectedIcon: Icon(
                              Icons.groups,
                              color: black,
                            ),
                            icon: Icon(
                              Icons.groups_2_outlined,
                              color: white,
                            ),
                            label: 'Customers',
                            tooltip: "Customers",
                          ),
                          NavigationDestination(
                            selectedIcon: Icon(
                              Icons.person,
                              color: black,
                            ),
                            icon: Icon(
                              Icons.person_2_outlined,
                              color: white,
                            ),
                            label: 'Profile',
                            tooltip: "Profile",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: <Widget>[
              /// Home page
              ///
              Homepage(
                dark: dark,
                scrollController: scrollController,
              ),

              /// Tiffin
              Tiffin(
                dark: dark,
                scrollController: scrollController,
              ),

              /// Customer page
              Customers(
                scrollController: scrollController,
              ),

              /// Profile page
              const Profile(),
            ][currentPageIndex],
          );
  }
}

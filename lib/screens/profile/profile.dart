import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:tiffin/auth/login.dart';
import 'package:tiffin/constants/color.dart';

import 'edit_profile.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic> provider = {};
  bool isLoading = false;
  User? user = FirebaseAuth.instance.currentUser;
  bool dark = false;

  Future<void> logout() async {
    // Show the alert dialog
    bool shouldDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Logout",
            style: GoogleFonts.manrope(
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: GoogleFonts.manrope(
              textStyle: const TextStyle(
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Cancel",
                style: GoogleFonts.manrope(
                    textStyle: const TextStyle(
                  color: primaryDark,
                  fontWeight: FontWeight.bold,
                )),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                "OK",
                style: GoogleFonts.manrope(
                    textStyle: const TextStyle(
                  color: primaryDark,
                  fontWeight: FontWeight.bold,
                )),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
                FirebaseAuth.instance.signOut();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Login()));
              },
            ),
          ],
        );
      },
    );
  }

  void darkMode() async {
    await FirebaseFirestore.instance
        .collection("providers")
        .doc(user!.email)
        .update({"isDarkMode": !provider["isDarkMode"]});
  }

  Future<void> getProvider() async {
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection("providers")
        .doc(user!.email)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        provider = snapshot.data() as Map<String, dynamic>;

        if (provider.containsKey("isDarkMode")) {
          setState(() {
            dark = provider["isDarkMode"];
          });
        }
      });
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProvider();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            backgroundColor: dark ? darkPrimary : primaryColor,
            body: const Center(
              child: CircularProgressIndicator(
                color: primaryDark,
              ),
            ),
          )
        : Scaffold(
            floatingActionButton: FloatingActionButton(
              shape: const CircleBorder(),
              backgroundColor: primaryDark,
              onPressed: () {
                showEditProviderBottomSheet(context, provider);
              },
              child: const Icon(
                Icons.edit,
                color: white,
              ),
            ),
            backgroundColor: provider["isDarkMode"] ? darkPrimary : white,
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(left: 0, right: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      height: MediaQuery.of(context).size.height * 0.3,
                      decoration: const BoxDecoration(
                        color: primaryDark,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              provider["Name"] ?? 'No Name',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.manrope(
                                textStyle: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.06,
                                  fontWeight: FontWeight.bold,
                                  color: white,
                                ),
                              ),
                            ),
                            Text(
                              provider["Address"] ?? 'No Address',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                textStyle: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04,
                                  color: Colors.grey.withOpacity(0.9),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 30,
                          ),
                          Text(
                            "Profile",
                            style: GoogleFonts.manrope(
                              textStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: dark ? white : darkPrimary,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.06,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          _profileDetail(
                              Icons.business_rounded, "Business", "Name"),
                          const SizedBox(
                            height: 20,
                          ),
                          _profileDetail(Icons.person, "Owner", "Username"),
                          const SizedBox(
                            height: 20,
                          ),
                          _profileDetail(Icons.phone, "Mobile", "Mobile"),
                          const SizedBox(
                            height: 20,
                          ),
                          _profileDetail(Icons.email, "Email", "Email"),
                          const SizedBox(
                            height: 20,
                          ),
                          _profileDetail(
                              Icons.home_filled, "Address", "Address"),
                          const SizedBox(
                            height: 20,
                          ),
                          _profileDetail(Icons.payments_rounded, "UPI", "UPI"),
                          const SizedBox(
                            height: 40,
                          ),
                          Container(
                            height: 1,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            onTap: () {
                              darkMode();
                            },
                            child: Opacity(
                              opacity: 1,
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 20, bottom: 20),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: dark
                                      ? white
                                      : Colors.grey.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(dark
                                        ? Icons.light_mode
                                        : Icons.dark_mode_outlined),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      provider["isDarkMode"]
                                          ? "Light mode"
                                          : "Dark mode",
                                      style: GoogleFonts.manrope(
                                        textStyle: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () async {
                              await logout();
                            },
                            child: Opacity(
                              opacity: 0.4,
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 20, bottom: 20),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.logout_rounded,
                                      color: dark ? white : darkPrimary,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "Logout",
                                      style: GoogleFonts.manrope(
                                        textStyle: TextStyle(
                                          color: dark ? white : darkPrimary,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Row _profileDetail(IconData icon, String title, String fieldValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: dark ? white : darkPrimary,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              "$title:",
              style: GoogleFonts.manrope(
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: dark ? white : darkPrimary,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(
            provider[fieldValue],
            style: GoogleFonts.manrope(
              textStyle: TextStyle(
                color: dark ? white : darkPrimary,
                fontSize: MediaQuery.of(context).size.width * 0.04,
              ),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

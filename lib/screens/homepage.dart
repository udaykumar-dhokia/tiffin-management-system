import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:tiffin/auth/login.dart';
import 'package:tiffin/components/add_customer.dart';
import 'package:tiffin/components/add_tiffin.dart';
import 'package:tiffin/constants/color.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: _buildSpeedDial(),
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Login(),
                ),
              );
            },
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedDial() {
    return SpeedDial(
      // animatedIcon: AnimatedIcons.,
      backgroundColor: primaryDark,
      foregroundColor: white,
      icon: Icons.add,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.groups),
          backgroundColor: primaryColor,
          label: 'New Customer',
          onTap: () => showAddCustomerBottomSheet(context),
        ),
        SpeedDialChild(
          child: const Icon(Icons.local_dining_rounded),
          backgroundColor: primaryColor,
          label: 'Add Tiffin',
          onTap: () => showAddTiffinBottomSheet(context),
        ),
      ],
    );
  }
}



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tiffin/constants/color.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: white,
    );
  }
}

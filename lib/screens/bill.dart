import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tiffin/constants/color.dart';

class Bill extends StatefulWidget {
  const Bill({super.key});

  @override
  State<Bill> createState() => _BillState();
}

class _BillState extends State<Bill> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: white,
    );
  }
}

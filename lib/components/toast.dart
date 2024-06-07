import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';

class ToastUtil {
  static ToastificationItem showToast(BuildContext context, String title,
      ToastificationType type, String desc) {
    return toastification.show(
      style: ToastificationStyle.fillColored,
      description: Text(
        desc,
        style: GoogleFonts.manrope(
          textStyle: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.03,
          ),
        ),
      ),
      type: type,
      context: context, // optional if you use ToastificationWrapper
      title: Text(
        title,
        style: GoogleFonts.manrope(
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: MediaQuery.of(context).size.width * 0.04,
          ),
        ),
      ),
      alignment: Alignment.bottomCenter,
      showProgressBar: false,
      autoCloseDuration: const Duration(seconds: 3),
    );
  }
}

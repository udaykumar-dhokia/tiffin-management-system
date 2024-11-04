import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tiffin/auth/login.dart';
import 'package:tiffin/components/bottombar/bottombar.dart';
import 'package:tiffin/constants/color.dart';
import 'package:tiffin/firebase_options.dart';
import 'package:firebase_auth_handler/firebase_auth_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash(),
    );
  }
}

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(
      const Duration(seconds: 1),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Auth(
              backgroundColor: transparent,
              loadingColor: primaryDark,
              loggedInBuilder: (context) => const Bottombar(),
              notLoggedInBuilder: (context) => const Login(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Made with ",
              style: GoogleFonts.manrope(
                textStyle: const TextStyle(
                  color: white,
                ),
              ),
            ),
            const Icon(
              Icons.favorite,
              color: primaryColor,
            ),
            Text(
              " in India.",
              style: GoogleFonts.manrope(
                textStyle: const TextStyle(
                  color: white,
                ),
              ),
            )
          ],
        ),
      ),
      backgroundColor: primaryDark,
      body: Center(
        child: Text(
          "tiffin.",
          style: GoogleFonts.manrope(
            textStyle: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.09,
              fontWeight: FontWeight.bold,
              color: white,
            ),
          ),
        ),
      ),
    );
  }
}


//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
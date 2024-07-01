import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:tiffin/auth/signup.dart';
import 'package:tiffin/components/bottombar.dart';
import 'package:tiffin/components/toast.dart';
import 'package:tiffin/constants/color.dart';
import 'package:toastification/toastification.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool _showPassword = true;
  bool _isLoading = false;

  Future<void> login(String email, String password) async {
    try {
      setState(() {
        _isLoading = true;
      });
      UserCredential credentials =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credentials.user != null) {
        setState(() {
          _isLoading = false;
        });
        ToastUtil.showToast(
          context,
          "Welcome",
          ToastificationType.success,
          "Welcome back to tiffin.",
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Bottombar(),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ToastUtil.showToast(
          context, "Error", ToastificationType.error, "Something went wrong");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: primaryDark,
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUp(),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8, top: 15),
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 10, left: 15, right: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: white,
                  ),
                  child: Text(
                    "SignUp",
                    style: GoogleFonts.manrope(
                      textStyle: TextStyle(
                        color: black,
                        decoration: TextDecoration.none,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 9, left: 10),
              child: Text(
                "tiffin.",
                style: GoogleFonts.manrope(
                  textStyle: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.1,
                    decoration: TextDecoration.none,
                    color: white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.only(
            //       top: MediaQuery.of(context).size.height / 8.8, left: 12),
            //   child: Text(
            //     "Brilliance.",
            //     style: GoogleFonts.manrope(
            //       textStyle: TextStyle(
            //         fontSize: MediaQuery.of(context).size.width * 0.1,
            //         decoration: TextDecoration.none,
            //         color: white.withOpacity(0.5),
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 6, left: 10),
              child: Text(
                "Login",
                style: GoogleFonts.manrope(
                  textStyle: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                    decoration: TextDecoration.none,
                    color: white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.5, // Initial size of the sheet
              minChildSize:
                  0.5, // Minimum size to which the sheet can be dragged
              maxChildSize:
                  0.7, // Maximum size to which the sheet can be dragged
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Scaffold(
                  backgroundColor: transparent,
                  resizeToAvoidBottomInset: true,
                  body: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      color: white,
                    ),
                    child: ListView(
                      controller: scrollController,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 50, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _textField('Email', TextInputType.emailAddress,
                                  _showPassword, () {}, _email),
                              const SizedBox(
                                height: 10,
                              ),
                              _textField(
                                'Password',
                                TextInputType.text,
                                _showPassword,
                                () {
                                  setState(
                                    () {
                                      _showPassword = !_showPassword;
                                    },
                                  );
                                },
                                _password,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (_email.text.isEmpty ||
                                      _password.text.isEmpty) {
                                    ToastUtil.showToast(
                                        context,
                                        'Error',
                                        ToastificationType.error,
                                        "Please fill all the required fields");
                                  } else {
                                    login(_email.text, _password.text);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 18, bottom: 18),
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: black,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "Login",
                                    style: GoogleFonts.manrope(
                                      textStyle: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                        color: white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            BackdropFilter(
              filter: _isLoading
                  ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
                  : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(),
            ),
            Center(
              child: _isLoading
                  ? LoadingAnimationWidget.flickr(
                      leftDotColor: primaryColor,
                      rightDotColor: black,
                      size: 50,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  TextFormField _textField(String label, TextInputType type, bool showPassword,
          VoidCallback toggleVisibility, TextEditingController controller) =>
      TextFormField(
        controller: controller,
        keyboardType: type,
        cursorColor: black,
        obscureText: label == "Password" ? showPassword : false,
        decoration: InputDecoration(
          suffixIcon: label == "Password"
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      toggleVisibility();
                    });
                  },
                  icon: showPassword
                      ? const Icon(Icons.visibility)
                      : const Icon(Icons.visibility_off),
                )
              : null,
          filled: true,
          fillColor: black.withOpacity(0.1),
          label: Text(label),
          labelStyle: GoogleFonts.manrope(
            textStyle: TextStyle(
              color: black,
              fontSize: MediaQuery.of(context).size.width * 0.04,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(),
          ),
        ),
      );
}

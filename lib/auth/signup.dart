import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:tiffin/auth/login.dart';
import 'package:tiffin/components/bottombar/bottombar.dart';
import 'package:tiffin/components/toast/toast.dart';
import 'package:tiffin/constants/color.dart';
import 'package:toastification/toastification.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _name = TextEditingController();
  TextEditingController _owner = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _mobile = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _upi = TextEditingController();
  TextEditingController _address = TextEditingController();
  bool _showPassword = true;
  bool _isLoading = false;
  bool _isEmailTaken = false;

  Future<bool> checkEmailAvailability(String email) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('providers')
        .where('Email', isEqualTo: email)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  void _checkEmail(String email) async {
    bool exists = await checkEmailAvailability(email);
    setState(() {
      _isEmailTaken = exists;
    });
  }

  Future<void> signUp(String email, String password, final data) async {
    try {
      setState(() {
        _isLoading = true;
      });
      UserCredential creadentials = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (creadentials.user != null) {
        await FirebaseFirestore.instance
            .collection("providers")
            .doc(email)
            .set(data);

        // await FirebaseFirestore.instance
        //     .collection("providers")
        //     .doc(email)
        //     .collection("Customers")
        //     .add();

        // await FirebaseFirestore.instance
        //     .collection("providers")
        //     .doc(email)
        //     .collection("Tiffins")
        //     .add();

        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Bottombar(),
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ToastUtil.showToast(
          context, "Error", ToastificationType.error, "Something went wrong.");
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
                      builder: (context) => const Login(),
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
                    "Login",
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
                "SignUp",
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
              initialChildSize: 0.75, // Initial size of the sheet
              minChildSize:
                  0.75, // Minimum size to which the sheet can be dragged
              maxChildSize:
                  0.75, // Maximum size to which the sheet can be dragged
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
                              _textField('Business Name', TextInputType.text,
                                  _showPassword, () {}, _name),
                              const SizedBox(
                                height: 10,
                              ),
                              _textField('Owner', TextInputType.text,
                                  _showPassword, () {}, _owner),
                              // const SizedBox(
                              //   height: 5,
                              // ),
                              const SizedBox(
                                height: 10,
                              ),
                              _textField('Mobile', TextInputType.phone,
                                  _showPassword, () {}, _mobile),
                              const SizedBox(
                                height: 10,
                              ),
                              _textField('Address', TextInputType.text,
                                  _showPassword, () {}, _address),
                              const SizedBox(
                                height: 10,
                              ),
                              _textField('Email', TextInputType.emailAddress,
                                  _showPassword, () {}, _email),
                              // const SizedBox(
                              //   height: 5,
                              // ),
                              if (_isEmailTaken)
                                Text(
                                  'Email already exists',
                                  style: GoogleFonts.manrope(
                                    textStyle: TextStyle(
                                      color: red,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.03,
                                    ),
                                  ),
                                ),

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
                                height: 10,
                              ),
                              _textField(
                                'UPI',
                                TextInputType.text,
                                _showPassword,
                                () {},
                                _upi,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (_name.text.isEmpty ||
                                      _owner.text.isEmpty ||
                                      _email.text.isEmpty ||
                                      _mobile.text.isEmpty ||
                                      _password.text.isEmpty ||
                                      _upi.text.isEmpty ||
                                      _address.text.isEmpty) {
                                    ToastUtil.showToast(
                                        context,
                                        'Error',
                                        ToastificationType.error,
                                        "Please fill all the required fields");
                                  } else if (_mobile.text.length != 10) {
                                    ToastUtil.showToast(
                                        context,
                                        "Mobile",
                                        ToastificationType.error,
                                        "Please enter valid mobile number.");
                                  } else if (_isEmailTaken) {
                                    ToastUtil.showToast(
                                        context,
                                        "Email Address",
                                        ToastificationType.info,
                                        "This email is already in use.");
                                  } else {
                                    final data = {
                                      "Name": _name.text.toString(),
                                      "Username": _owner.text.toString(),
                                      "Email": _email.text.toString(),
                                      "Password": _password.text.toString(),
                                      "Mobile": _mobile.text.toString(),
                                      "UPI": _upi.text.toString(),
                                      "Address": _address.text.toString(),
                                    };
                                    signUp(_email.text, _password.text, data);
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
                                    "Sign Up",
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
                              // Container(
                              //   alignment: Alignment.center,
                              //   padding: const EdgeInsets.all(16.0),
                              //   child: Container(
                              //     width: MediaQuery.of(context).size.width / 3,
                              //     height: 2,
                              //     decoration: BoxDecoration(
                              //       color: Colors.grey,
                              //       borderRadius: BorderRadius.circular(20),
                              //     ),
                              //   ),
                              // ),
                              // const SizedBox(
                              //   height: 10,
                              // ),
                              // Container(
                              //   padding: const EdgeInsets.all(15),
                              //   alignment: Alignment.center,
                              //   decoration: BoxDecoration(
                              //     border: Border.all(),
                              //     shape: BoxShape.circle,
                              //     color: black.withOpacity(0.1),
                              //   ),
                              //   child: const FaIcon(FontAwesomeIcons.google),
                              // ),
                              // const SizedBox(
                              //   height: 80,
                              // ),
                              // Text(
                              //   "Showcase the next big thing.",
                              //   style: GoogleFonts.manrope(
                              //     textStyle: TextStyle(
                              //       color: black,
                              //       fontWeight: FontWeight.bold,
                              //       fontSize:
                              //           MediaQuery.of(context).size.width * 0.1,
                              //     ),
                              //   ),
                              // ),
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
        onChanged: (value) {
          if (label == 'Email') {
            _checkEmail(value);
          }
        },
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tiffin/components/toast/toast.dart';
import 'package:tiffin/constants/color.dart';
import 'package:toastification/toastification.dart';

void showEditProviderBottomSheet(
    BuildContext context, Map<String, dynamic> provider) async {
  String? mealType;
  TextEditingController _name = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _mobile = TextEditingController();
  TextEditingController _upi = TextEditingController();
  TextEditingController _owner = TextEditingController();

  bool isLoading = false;

  Future<void> updateProfile(final data) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection("providers")
          .doc(user!.email)
          .update(data);

      ToastUtil.showToast(context, "Success", ToastificationType.success,
          "Profile updated successfully.");
      Navigator.pop(context);
    } catch (e) {
      ToastUtil.showToast(
          context, "Error", ToastificationType.error, "Something went wrong");
    }
  }

  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentSnapshot providerSnapshot = await FirebaseFirestore.instance
        .collection("providers")
        .doc(user.email)
        .get();

    if (providerSnapshot.exists) {
      var providerData = providerSnapshot.data() as Map<String, dynamic>;
      _name.text = providerData['Name'] ?? '';
      _address.text = providerData['Address'] ?? '';
      _email.text = providerData['Email'] ?? user.email!;
      _mobile.text = providerData['Mobile'] ?? '';
      _upi.text = providerData['UPI'] ?? '';
      _owner.text = providerData['Username'] ?? '';
    }
  }

  showModalBottomSheet(
    backgroundColor: primaryColor,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Edit details',
                      style: GoogleFonts.manrope(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _name,
                      cursorColor: black,
                      style: GoogleFonts.manrope(
                        textStyle: const TextStyle(
                          color: black,
                        ),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Business name*',
                        hintStyle: GoogleFonts.manrope(),
                        labelStyle: GoogleFonts.manrope(
                          textStyle: const TextStyle(
                            color: black,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: black),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      readOnly: true,
                      controller: _owner,
                      cursorColor: black,
                      style: GoogleFonts.manrope(
                        textStyle: const TextStyle(
                          color: black,
                        ),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Owner*',
                        hintStyle: GoogleFonts.manrope(),
                        labelStyle: GoogleFonts.manrope(
                          textStyle: const TextStyle(
                            color: black,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: black),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _mobile,
                      keyboardType: TextInputType.phone,
                      cursorColor: black,
                      style: GoogleFonts.manrope(
                        textStyle: const TextStyle(
                          color: black,
                        ),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Mobile*',
                        hintStyle: GoogleFonts.manrope(),
                        labelStyle: GoogleFonts.manrope(
                          textStyle: const TextStyle(
                            color: black,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: black),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      readOnly: true,
                      controller: _email,
                      cursorColor: black,
                      style: GoogleFonts.manrope(
                        textStyle: const TextStyle(
                          color: black,
                        ),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Email*',
                        hintStyle: GoogleFonts.manrope(),
                        labelStyle: GoogleFonts.manrope(
                          textStyle: const TextStyle(
                            color: black,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: black),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _address,
                      cursorColor: black,
                      style: GoogleFonts.manrope(
                        textStyle: const TextStyle(
                          color: black,
                        ),
                      ),
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Address*',
                        hintStyle: GoogleFonts.manrope(),
                        labelStyle: GoogleFonts.manrope(
                          textStyle: const TextStyle(
                            color: black,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: black),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _upi,
                      cursorColor: black,
                      style: GoogleFonts.manrope(
                        textStyle: const TextStyle(
                          color: black,
                        ),
                      ),
                      decoration: InputDecoration(
                        labelText: 'UPI',
                        hintStyle: GoogleFonts.manrope(),
                        labelStyle: GoogleFonts.manrope(
                          textStyle: const TextStyle(
                            color: black,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: black),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    isLoading
                        ? const CircularProgressIndicator(
                            color: primaryDark,
                          )
                        : GestureDetector(
                            onTap: () async {
                              if (_name.text.isEmpty ||
                                  _address.text.isEmpty ||
                                  _mobile.text.isEmpty ||
                                  _upi.text.isEmpty) {
                                ToastUtil.showToast(
                                  context,
                                  "Error",
                                  ToastificationType.error,
                                  "Please fill all required fields.",
                                );
                              } else if (_mobile.text.length != 10) {
                                ToastUtil.showToast(
                                  context,
                                  "Error",
                                  ToastificationType.error,
                                  "Please provide valid mobile number.",
                                );
                              } else if (_name.text == provider["Name"] &&
                                  _mobile.text == provider["Mobile"] &&
                                  _address.text == provider["Address"] &&
                                  _upi.text == provider["UPI"]) {
                                ToastUtil.showToast(
                                  context,
                                  "Error",
                                  ToastificationType.error,
                                  "Please change the details to update.",
                                );
                              } else {
                                final data = {
                                  "Name": _name.text.toString(),
                                  "Mobile": _mobile.text.toString(),
                                  "Address": _address.text.toString().trim(),
                                  "UPI": _upi.text.toString(),
                                };
                                setState(() {
                                  isLoading = true;
                                });
                                await updateProfile(data);
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.only(
                                  top: 10, bottom: 10, left: 15, right: 15),
                              decoration: BoxDecoration(
                                color: primaryDark,
                                borderRadius: BorderRadius.circular(
                                  15,
                                ),
                              ),
                              child: Text(
                                "Update",
                                style: GoogleFonts.manrope(
                                  textStyle: TextStyle(
                                    color: white,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.04,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tiffin/components/toast.dart';
import 'package:tiffin/constants/color.dart';
import 'package:toastification/toastification.dart';

void showAddTiffinBottomSheet(BuildContext context) {
  String? mealType;
  TextEditingController _name = TextEditingController();
  TextEditingController _price = TextEditingController();
  TextEditingController _details = TextEditingController();
  TextEditingController _items = TextEditingController();
  bool isLoading = false;

  Future<void> addTiffin(final data) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection("providers")
          .doc(user!.email)
          .collection("Tiffins")
          .add(data);

      ToastUtil.showToast(context, "Success", ToastificationType.success,
          "Tiffin added successfully.");
      Navigator.pop(context);
    } catch (e) {
      ToastUtil.showToast(
          context, "Error", ToastificationType.error, "Something went wrong");
    }
  }

  showModalBottomSheet(
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
                      'Add Tiffin',
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
                        labelText: 'Name*',
                        hintText: "Eg. Full, Half",
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
                      controller: _price,
                      keyboardType: TextInputType.number,
                      cursorColor: black,
                      style: GoogleFonts.manrope(
                        textStyle: const TextStyle(
                          color: black,
                        ),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Price*',
                        hintText: "Eg. 60, 70",
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
                      controller: _items,
                      cursorColor: black,
                      style: GoogleFonts.manrope(
                        textStyle: const TextStyle(
                          color: black,
                        ),
                      ),
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Items*',
                        hintText: "Eg. Rice, Dal, Roti",
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
                    DropdownButtonFormField(
                      value: mealType,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: black),
                        ),
                        labelText: 'Meal Type*',
                        labelStyle: GoogleFonts.manrope(
                          textStyle: const TextStyle(
                            color: black,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: "Lunch",
                          child: Text(
                            "Lunch",
                            style: GoogleFonts.manrope(),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Dinner",
                          child: Text(
                            "Dinner",
                            style: GoogleFonts.manrope(),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Both",
                          child: Text(
                            "Both",
                            style: GoogleFonts.manrope(),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        mealType = value;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _details,
                      cursorColor: black,
                      style: GoogleFonts.manrope(
                        textStyle: const TextStyle(
                          color: black,
                        ),
                      ),
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Additional details',
                        hintText:
                            "E.g., Basmati rice, Yellow dal, 2 chapatis, Salad, Dessert",
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
                                  _items.text.isEmpty ||
                                  _price.text.isEmpty ||
                                  mealType == null) {
                                ToastUtil.showToast(
                                  context,
                                  "Error",
                                  ToastificationType.error,
                                  "Please fill all required fields.",
                                );
                              } else {
                                final data = {
                                  "Name": _name.text.toString(),
                                  "Price": int.parse(_price.text),
                                  "Items": _items.text.toString().trim(),
                                  "Details": _details.text.toString().trim(),
                                  "Meal Type": mealType!,
                                };
                                setState(() {
                                  isLoading = true;
                                });
                                await addTiffin(data);
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
                                "Add",
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

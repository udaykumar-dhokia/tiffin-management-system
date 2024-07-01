import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tiffin/components/toast.dart';
import 'package:tiffin/constants/color.dart';
import 'package:toastification/toastification.dart';

void showEditTiffinBottomSheet(BuildContext context, String id) {
  showModalBottomSheet(
    backgroundColor: white,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (context) {
      return EditTiffinForm(id: id);
    },
  );
}

class EditTiffinForm extends StatefulWidget {
  final String id;

  const EditTiffinForm({required this.id});

  @override
  _EditTiffinFormState createState() => _EditTiffinFormState();
}

class _EditTiffinFormState extends State<EditTiffinForm> {
  bool isLoading = false;
  String? mealType;
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _detailsController;
  late TextEditingController _itemsController;
  List<Map<String, dynamic>> tiffins = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _detailsController = TextEditingController();
    _itemsController = TextEditingController();
    _fetchTiffinData();
  }

  Future<void> _fetchTiffinData() async {
    User? user = FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance
        .collection("providers")
        .doc(user!.email)
        .collection("Tiffins")
        .doc(widget.id)
        .get();

    if (doc.exists) {
      tiffins.add(doc.data()!);
      final data = doc.data()!;
      setState(() {
        _nameController.text = data['Name'];
        _priceController.text = data['Price'].toString();
        _detailsController.text = data['Details'];
        _itemsController.text = data['Items'];
        mealType = data['Meal Type'];
      });
    }
  }

  Future<void> _updateTiffin(Map<String, dynamic> data) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection("providers")
          .doc(user!.email)
          .collection("Tiffins")
          .doc(widget.id)
          .update(data);

      ToastUtil.showToast(context, "Edit", ToastificationType.info,
          "Tiffin updated successfully.");
      Navigator.pop(context);
    } catch (e) {
      ToastUtil.showToast(
          context, "Error", ToastificationType.error, "Something went wrong");
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'Edit Tiffin',
                style: GoogleFonts.manrope(
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
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
                controller: _priceController,
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
                controller: _itemsController,
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
                  setState(() {
                    mealType = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _detailsController,
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
                        if (_nameController.text == tiffins[0]["Name"] &&
                            _itemsController.text == tiffins[0]["Items"] &&
                            _priceController.text ==
                                tiffins[0]["Price"].toString() &&
                            mealType == tiffins[0]["Meal Type"]) {
                          ToastUtil.showToast(
                            context,
                            "Error",
                            ToastificationType.error,
                            "Please fill all required fields.",
                          );
                        } else {
                          final data = {
                            "Name": _nameController.text.toString(),
                            "Price": int.parse(_priceController.text),
                            "Items": _itemsController.text.toString().trim(),
                            "Details":
                                _detailsController.text.toString().trim(),
                            "Meal Type": mealType
                          };
                          setState(() {
                            isLoading = true;
                          });
                          await _updateTiffin(data);
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
                                  MediaQuery.of(context).size.width * 0.04,
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
  }
}

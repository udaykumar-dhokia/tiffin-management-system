import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tiffin/components/toast.dart';
import 'package:tiffin/constants/color.dart';
import 'package:toastification/toastification.dart';

void showEditCustomerBottomSheet(BuildContext context, String id) {
  showModalBottomSheet(
    backgroundColor: white,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (context) {
      return EditCustomerForm(id: id);
    },
  );
}

class EditCustomerForm extends StatefulWidget {
  final String id;

  const EditCustomerForm({required this.id});

  @override
  _EditCustomerFormState createState() => _EditCustomerFormState();
}

class _EditCustomerFormState extends State<EditCustomerForm> {
  String? mealType;
  String? selectedTiffin;
  String? timePeriod;
  DateTime? startDate;
  DateTime? endDate;
  TextEditingController _name = TextEditingController();
  TextEditingController _details = TextEditingController();
  TextEditingController _mobile = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _address2 = TextEditingController();
  bool isLoading = false;
  List<Map<String, dynamic>> customer = [];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _address = TextEditingController();
    _address2 = TextEditingController();
    _mobile = TextEditingController();
    _details = TextEditingController();
    _fetchTiffinData();
  }

  Future<void> _fetchTiffinData() async {
    User? user = FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance
        .collection("providers")
        .doc(user!.email)
        .collection("Customers")
        .doc(widget.id)
        .get();

    if (doc.exists) {
      customer.add(doc.data()!);
      final data = doc.data()!;
      setState(() {
        _name.text = data['Name'];
        _mobile.text = data['Mobile'].toString();
        _details.text = data['Details'];
        _address.text = data['Address'];
        _address2.text = data['Address 2'];
        mealType = data['MealType'];
        selectedTiffin = data["SelectedTiffin"];
        startDate = data["Start Date"].toIso8601String().split('T')[0];
        timePeriod = data["Fixed"] == true ? "Fixed" : "Not fixed";
      });
    }
  }

  Future<List<String>> fetchTiffinNames() async {
    User? user = FirebaseAuth.instance.currentUser;
    List<String> tiffinNames = [];
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("providers")
          .doc(user!.email)
          .collection("Tiffins")
          .get();

      for (var doc in snapshot.docs) {
        tiffinNames.add(doc['Name']);
      }
    } catch (e) {
      print("Error fetching tiffin names: $e");
    }
    return tiffinNames;
  }

  Future<void> _updateCustomer(Map<String, dynamic> data) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection("providers")
          .doc(user!.email)
          .collection("Customers")
          .doc(widget.id)
          .update(data);

      ToastUtil.showToast(context, "Edit", ToastificationType.info,
          "Customer details updated successfully.");
      Navigator.pop(context);
    } catch (e) {
      ToastUtil.showToast(
          context, "Error", ToastificationType.error, "Something went wrong");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: fetchTiffinNames(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: white,
            body: Center(
              child: CircularProgressIndicator(
                color: primaryDark,
              ),
            ),
          );
        }
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
                        'Update Customer',
                        style: GoogleFonts.manrope(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
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
                      const SizedBox(height: 15),
                      TextField(
                        keyboardType: TextInputType.phone,
                        controller: _mobile,
                        cursorColor: black,
                        style: GoogleFonts.manrope(
                          textStyle: const TextStyle(
                            color: black,
                          ),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Mobile*',
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
                      const SizedBox(height: 15),
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
                      const SizedBox(height: 15),
                      DropdownButtonFormField(
                        value: selectedTiffin,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: black),
                          ),
                          labelText: 'Select Tiffin*',
                          labelStyle: GoogleFonts.manrope(
                            textStyle: const TextStyle(
                              color: black,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        items: snapshot.data!
                            .map((name) => DropdownMenuItem(
                                  value: name,
                                  child: Text(
                                    name,
                                    style: GoogleFonts.manrope(),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTiffin = value;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _address,
                        cursorColor: black,
                        style: GoogleFonts.manrope(
                          textStyle: const TextStyle(
                            color: black,
                          ),
                        ),
                        maxLines: 1,
                        decoration: InputDecoration(
                          labelText: 'Address 1*',
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
                      const SizedBox(height: 15),
                      TextField(
                        controller: _address2,
                        cursorColor: black,
                        style: GoogleFonts.manrope(
                          textStyle: const TextStyle(
                            color: black,
                          ),
                        ),
                        maxLines: 1,
                        decoration: InputDecoration(
                          labelText: 'Address 2',
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
                      const SizedBox(height: 15),
                      TextField(
                        controller: _details,
                        cursorColor: black,
                        style: GoogleFonts.manrope(
                          textStyle: const TextStyle(
                            color: black,
                          ),
                        ),
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Additional note',
                          hintText: "E.g., No onions, Extra spicy, Less oil",
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
                      const SizedBox(height: 15),
                      isLoading
                          ? const CircularProgressIndicator(
                              color: primaryDark,
                            )
                          : GestureDetector(
                              onTap: () async {
                                if (_name.text == customer[0]["Name"] &&
                                    _mobile.text == customer[0]["Mobile"] &&
                                    _address.text ==
                                        customer[0]["Adress"].toString() &&
                                    mealType == customer[0]["Meal Type"]) {
                                  ToastUtil.showToast(
                                    context,
                                    "Error",
                                    ToastificationType.error,
                                    "Please fill all required fields.",
                                  );
                                } else if (timePeriod == "Fixed" &&
                                    endDate == null) {
                                  ToastUtil.showToast(
                                    context,
                                    "Error",
                                    ToastificationType.error,
                                    "Error in time period selection!",
                                  );
                                } else if (_mobile.text.length != 10) {
                                  ToastUtil.showToast(
                                      context,
                                      "Error",
                                      ToastificationType.error,
                                      "Please enter a valid mobile number.");
                                } else {
                                  final data = {
                                    "Name": _name.text.toString(),
                                    "Details": _details.text.toString().trim(),
                                    "MealType": mealType.toString(),
                                    "SelectedTiffin": selectedTiffin.toString(),
                                    "Mobile": _mobile.text.toString(),
                                    "Address": _address.text.toString().trim(),
                                    "Address 2":
                                        _address2.text.toString().trim(),
                                  };
                                  setState(() {
                                    isLoading = true;
                                  });
                                  // await addCustomer(data);
                                  await _updateCustomer(data);
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
}

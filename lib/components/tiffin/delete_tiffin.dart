import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tiffin/components/toast/toast.dart';
import 'package:tiffin/constants/color.dart';
import 'package:toastification/toastification.dart';

void showDeleteTiffinOfCustomerBottomSheet(BuildContext context, String id) {
  String? mealType;
  String? selectedTiffin;
  String? timePeriod;
  DateTime? startDate;
  DateTime? endDate;
  TextEditingController _name = TextEditingController();
  TextEditingController _date = TextEditingController();
  TextEditingController _mobile = TextEditingController();
  bool isLoading = false;
  List<Map<String, dynamic>> tiffin = [];

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

      final doc = await FirebaseFirestore.instance
          .collection("providers")
          .doc(user.email)
          .collection("Customers")
          .doc(id)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _name.text = data['Name'];
        _mobile.text = data['Mobile'].toString();
        startDate = DateTime.now();
      }
    } catch (e) {
      print("Error fetching tiffin names: $e");
    }
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("providers")
          .doc(user!.email)
          .collection("Tiffins")
          .get();

      for (var doc in snapshot.docs) {
        tiffin.add(doc.data());
      }
    } catch (e) {
      print("Error fetching tiffin names: $e");
    }
    return tiffinNames;
  }

  Future<void> updateTiffin(final data) async {
    try{
      User? user = FirebaseAuth.instance.currentUser;
      final docRef = await FirebaseFirestore.instance
          .collection("providers")
          .doc(user!.email)
          .collection("Customers")
          .doc(id)
          .collection("TimePeriod")
          .doc(startDate!.toIso8601String().split("T")[0])
          .set(data);
      ToastUtil.showToast(context, "Delete", ToastificationType.info, "Tiffin Deleted Successfully");
      Navigator.pop(context);
    }catch(e){
      ToastUtil.showToast(context, "Error", ToastificationType.error, "Something went wrong...");
      Navigator.pop(context);
    }
  }

  void deleteTiffin(var mealtype) async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      final docRef = await FirebaseFirestore.instance
          .collection("providers")
          .doc(user!.email)
          .collection("Customers")
          .doc(id)
          .collection("TimePeriod")
          .doc(startDate!.toIso8601String().split("T")[0]);

      // Fetch the current document data
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final docData = docSnapshot.data()!;

        if (mealtype == "Lunch") {
          final data = {
            "Dinner": docData['Dinner'] ?? 0,
            "dinnerType": docData['dinnerType'] ?? ''
          };
          updateTiffin(data);
          String monthId = DateTime.now().month.toString();
          String yearMonthId = '${DateTime.now().year}-$monthId';
          await FirebaseFirestore.instance
              .collection('providers')
              .doc(user.email)
              .collection('Fees')
              .doc(yearMonthId)
              .set(
            {'platformFee': FieldValue.increment(-3)}, SetOptions(merge: true),
          );
        } else {
          final data = {
            "Lunch": docData['Lunch'] ?? 0,
            "lunchType": docData['lunchType'] ?? ''
          };
          updateTiffin(data);
          String monthId = startDate!.month.toString();
          String yearMonthId = '${startDate!.year}-$monthId';
          await FirebaseFirestore.instance
              .collection('providers')
              .doc(user.email)
              .collection('Fees')
              .doc(yearMonthId)
              .set(
            {'platformFee': FieldValue.increment(-3)}, SetOptions(merge: true),
          );
        }
      } else {}
    } catch (e) {
      ToastUtil.showToast(
          context, "Error", ToastificationType.error, "Something went wrong.");
      Navigator.pop(context);
      print("Error updating tiffin data: $e");
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
      return FutureBuilder<List<String>>(
        future: fetchTiffinNames(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryDark,
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
                          'Delete Tiffin',
                          style: GoogleFonts.manrope(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          readOnly: true,
                          controller: _name,
                          cursorColor: black,
                          style: GoogleFonts.manrope(
                            textStyle: const TextStyle(
                              color: black,
                            ),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Name',
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
                          ],
                          onChanged: (value) {
                            setState(() {
                              mealType = value;
                            });
                          },
                        ),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: () async {
                            final pickedStartDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (pickedStartDate != null) {
                              setState(() {
                                startDate = pickedStartDate;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: black),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  startDate == null
                                      ? 'Select start date*'
                                      : "${startDate!.year}/${startDate!.month}/${startDate!.day}",
                                  style: GoogleFonts.manrope(
                                    textStyle: const TextStyle(
                                      color: black,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.calendar_today,
                                  color: black,
                                ),
                              ],
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
                                  if (_name.text.isEmpty ||
                                      mealType == null ||
                                      startDate == null ||
                                      _mobile.text.isEmpty) {
                                    ToastUtil.showToast(
                                      context,
                                      "Error",
                                      ToastificationType.error,
                                      "Please fill all required fields.",
                                    );
                                  }
                                  else {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    deleteTiffin(mealType);
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10, left: 15, right: 15),
                                  decoration: BoxDecoration(
                                    color: red,
                                    borderRadius: BorderRadius.circular(
                                      15,
                                    ),
                                  ),
                                  child: Text(
                                    "Delete",
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
    },
  );
}

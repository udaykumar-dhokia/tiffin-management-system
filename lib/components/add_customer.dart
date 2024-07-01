import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tiffin/components/toast.dart';
import 'package:tiffin/constants/color.dart';
import 'package:toastification/toastification.dart';

void showAddCustomerBottomSheet(BuildContext context) {
  String? mealType;
  String? selectedTiffin;
  // String? timePeriod;
  // DateTime? startDate;
  // DateTime? endDate;
  TextEditingController _name = TextEditingController();
  TextEditingController _details = TextEditingController();
  TextEditingController _mobile = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _address2 = TextEditingController();
  bool isLoading = false;

  Future<void> addCustomer(final data) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection("providers")
          .doc(user!.email)
          .collection("Customers")
          .doc(_mobile.text.toString())
          .set(data);

      ToastUtil.showToast(context, "Success", ToastificationType.success,
          "Customer added successfully.");
      Navigator.pop(context);
    } catch (e) {
      ToastUtil.showToast(
          context, "Error", ToastificationType.error, "Something went wrong");
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

  showModalBottomSheet(
    backgroundColor: white,
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
                          'Add Customer',
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
                        // const SizedBox(height: 15),
                        // DropdownButtonFormField(
                        //   value: timePeriod,
                        //   decoration: InputDecoration(
                        //     focusedBorder: OutlineInputBorder(
                        //       borderRadius: BorderRadius.circular(15),
                        //       borderSide: const BorderSide(color: black),
                        //     ),
                        //     labelText: 'Time Period*',
                        //     labelStyle: GoogleFonts.manrope(
                        //       textStyle: const TextStyle(
                        //         color: black,
                        //       ),
                        //     ),
                        //     border: OutlineInputBorder(
                        //       borderRadius: BorderRadius.circular(15),
                        //     ),
                        //   ),
                        //   items: [
                        //     DropdownMenuItem(
                        //       value: "Fixed",
                        //       child: Text(
                        //         "Fixed",
                        //         style: GoogleFonts.manrope(),
                        //       ),
                        //     ),
                        //     DropdownMenuItem(
                        //       value: "Not fixed",
                        //       child: Text(
                        //         "Not fixed",
                        //         style: GoogleFonts.manrope(),
                        //       ),
                        //     ),
                        //   ],
                        //   onChanged: (value) {
                        //     setState(() {
                        //       timePeriod = value;
                        //     });
                        //   },
                        // ),
                        // const SizedBox(height: 15),
                        // GestureDetector(
                        //   onTap: () async {
                        //     final pickedStartDate = await showDatePicker(
                        //       context: context,
                        //       initialDate: DateTime.now(),
                        //       firstDate: DateTime.now(),
                        //       lastDate: DateTime(2101),
                        //     );
                        //     if (pickedStartDate != null) {
                        //       setState(() {
                        //         startDate = pickedStartDate;
                        //       });
                        //     }
                        //   },
                        //   child: Container(
                        //     padding: const EdgeInsets.all(16.0),
                        //     decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(15),
                        //       border: Border.all(color: black),
                        //     ),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: [
                        //         Text(
                        //           startDate == null
                        //               ? 'Select start date*'
                        //               : "${startDate!.day}/${startDate!.month}/${startDate!.year}",
                        //           style: GoogleFonts.manrope(
                        //             textStyle: const TextStyle(
                        //               color: black,
                        //             ),
                        //           ),
                        //         ),
                        //         const Icon(
                        //           Icons.calendar_today,
                        //           color: black,
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(height: 15),
                        // if (timePeriod == "Fixed") ...[
                        //   GestureDetector(
                        //     onTap: () async {
                        //       final pickedEndDate = await showDatePicker(
                        //         context: context,
                        //         initialDate: DateTime.now(),
                        //         firstDate: DateTime.now(),
                        //         lastDate: DateTime(2101),
                        //       );
                        //       if (pickedEndDate != null) {
                        //         setState(() {
                        //           endDate = pickedEndDate;
                        //         });
                        //       }
                        //     },
                        //     child: Container(
                        //       padding: const EdgeInsets.all(16.0),
                        //       decoration: BoxDecoration(
                        //         borderRadius: BorderRadius.circular(15),
                        //         border: Border.all(color: black),
                        //       ),
                        //       child: Row(
                        //         mainAxisAlignment:
                        //             MainAxisAlignment.spaceBetween,
                        //         children: [
                        //           Text(
                        //             endDate == null
                        //                 ? 'Select end date*'
                        //                 : "${endDate!.day}/${endDate!.month}/${endDate!.year}",
                        //             style: GoogleFonts.manrope(
                        //               textStyle: const TextStyle(
                        //                 color: black,
                        //               ),
                        //             ),
                        //           ),
                        //           const Icon(
                        //             Icons.calendar_today,
                        //             color: black,
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ],
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
                                  if (_name.text.isEmpty ||
                                      mealType == null ||
                                      selectedTiffin == null ||
                                      _mobile.text.isEmpty ||
                                      _address.text.isEmpty) {
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
                                        "Please enter a valid mobile number.");
                                  } else {
                                    final data = {
                                      "Name": _name.text.toString(),
                                      "Details":
                                          _details.text.toString().trim(),
                                      "MealType": mealType.toString(),
                                      "SelectedTiffin":
                                          selectedTiffin.toString(),
                                      // "Start Date": startDate,
                                      // "End Date": endDate,
                                      "Mobile": _mobile.text.toString(),
                                      "Address":
                                          _address.text.toString().trim(),
                                      "Address 2":
                                          _address2.text.toString().trim(),
                                      // "Fixed":
                                      //     timePeriod == "Fixed" ? true : false,
                                    };
                                    setState(() {
                                      isLoading = true;
                                    });
                                    await addCustomer(data);
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
    },
  );
}

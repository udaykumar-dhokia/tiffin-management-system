import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tiffin/components/toast/toast.dart';
import 'package:tiffin/constants/color.dart';
import 'package:toastification/toastification.dart';

void showAddTiffinToCustomerBottomSheet(BuildContext context, String id, VoidCallback _refresh) {
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
  List<Map<String, dynamic>> extraItems = [];


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

  void addTiffin(var data, var selectedTiffinItem) async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      final docRef = FirebaseFirestore.instance
          .collection("providers")
          .doc(user!.email)
          .collection("Customers")
          .doc(id)
          .collection("TimePeriod")
          .doc(startDate!.toIso8601String().split("T")[0]);

      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final docData = docSnapshot.data()!;
        final currentTotal = docData['total'] ?? 0;
        final currentLunch = docData['Lunch'] ?? 0;
        final currentDinner = docData['Dinner'] ?? 0;

        if ((mealType == 'Lunch' && currentLunch > 0) || (mealType == 'Dinner' && currentDinner > 0)) {
          await ToastUtil.showToast(
              context, "Error", ToastificationType.error, "$mealType already exists for the selected date.");
          return;
        }


        final newTotal =
            currentLunch + currentDinner + selectedTiffinItem["Price"];

        data['$mealType Extra Items'] = extraItems;

        print(data);

        await docRef.update(data);

        String monthId = startDate!.month.toString();
        String yearMonthId = '${startDate!.year}-$monthId';
        await FirebaseFirestore.instance
            .collection('providers')
            .doc(user.email)
            .collection('Fees')
            .doc(yearMonthId)
            .set(
          {'platformFee': FieldValue.increment(3), "isPaid": false}, SetOptions(merge: true),
        );

        ToastUtil.showToast(
            context, "Success", ToastificationType.success, "Tiffin added successfully");
      } else {
        data['$mealType Extra Items'] = extraItems;
        await docRef.set(data);
        String monthId = startDate!.month.toString();
        String yearMonthId = '${startDate!.year}-$monthId';
        await FirebaseFirestore.instance
            .collection('providers')
            .doc(user.email)
            .collection('Fees')
            .doc(yearMonthId)
            .set(
          {'platformFee': FieldValue.increment(3), "isPaid": false}, SetOptions(merge: true),
        );
      }
    } catch (e) {
      ToastUtil.showToast(
          context, "Error", ToastificationType.error, "Something went wrong.");
      Navigator.pop(context);
      print("Error updating tiffin data: $e");
    }
  }

  void _showAddExtraItemDialog(BuildContext context, StateSetter setState) {
    TextEditingController itemNameController = TextEditingController();
    TextEditingController itemPriceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: white,
          title: Text("Add Extra Item", style: GoogleFonts.manrope(),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: itemNameController,
                decoration: InputDecoration(labelText: "Item"),
              ),
              TextField(
                controller: itemPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Price"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel", style: GoogleFonts.manrope(color: black),),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  extraItems.add({
                    "item": itemNameController.text,
                    "price": int.tryParse(itemPriceController.text) ?? 0,
                  });
                });
                itemNameController.clear();
                itemPriceController.clear();
                Navigator.of(context).pop();
              },
              child: Text("Add", style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: primaryDark),),
            ),
          ],
        );
      },
    );
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
                          'Add Tiffin',
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
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => _showAddExtraItemDialog(context, setState),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width,
                            padding: EdgeInsets.only(top: 15, bottom: 15),
                            // onPressed: () => _showAddExtraItemDialog(context, setState),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: primaryDark
                            ),
                            child: Center(child: Text("Extra Items", style: GoogleFonts.manrope(color: white),)),
                          ),
                        ),

                        if (extraItems.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: extraItems.length,
                            itemBuilder: (context, index) {
                              final item = extraItems[index];
                              return ListTile(
                                title: Text(item['item'], style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.bold),),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("₹${item['price']}", style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.bold,),),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: red,),
                                      onPressed: () {
                                        setState(() {
                                          extraItems.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () async {
                            final pickedStartDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate:  DateTime(DateTime.now().year, DateTime.now().month, 1),
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
                                      selectedTiffin == null ||
                                      startDate == null ||
                                      _mobile.text.isEmpty) {
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
                                    var selectedTiffinItem;
                                    for (var doc in tiffin) {
                                      if (doc["Name"] == selectedTiffin) {
                                        selectedTiffinItem = doc;
                                        break;
                                      }
                                    }
                                    final data = {
                                      if (mealType == "Lunch")
                                        "Lunch": selectedTiffinItem["Price"],
                                      if (mealType == "Dinner")
                                        "Dinner": selectedTiffinItem["Price"],
                                      if (mealType == "Lunch")
                                        "lunchType": selectedTiffinItem["Name"],
                                      if (mealType == "Dinner")
                                        "dinnerType":
                                            selectedTiffinItem["Name"],
                                    };

                                    addTiffin(data, selectedTiffinItem);
                                    // ToastUtil.showToast(
                                    //   context,
                                    //   "Success",
                                    //   ToastificationType.success,
                                    //   "Tiffin added successfully.",
                                    // );
                                    Navigator.pop(context);
                                    setState((){
                                      _refresh();
                                    });
                                    // Navigator.pop(context);
                                    // setState(() {
                                    //   isLoading = true;
                                    // });
                                    // setState(() {
                                    //   isLoading = false;
                                    // });
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

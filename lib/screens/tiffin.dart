import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tiffin/components/add_tiffin.dart';
import 'package:tiffin/components/edit_tiffin.dart';
import 'package:tiffin/constants/color.dart';

class Tiffin extends StatefulWidget {
  const Tiffin({super.key});

  @override
  State<Tiffin> createState() => _TiffinState();
}

class _TiffinState extends State<Tiffin> {
  List<Map<String, dynamic>> tiffins = [];
  bool isLoading = false;

  Future<void> getTiffin() async {
    setState(() {
      isLoading = true;
    });
    User? user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection("providers")
        .doc(user!.email)
        .collection("Tiffins")
        .orderBy("Price")
        .snapshots()
        .listen((snapshot) {
      setState(() {
        tiffins = snapshot.docs.map((doc) {
          var data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    });
    setState(() {
      isLoading = false;
    });
  }

  Future<void> deleteTiffin(String id) async {
    // Show the alert dialog
    bool shouldDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Delete Tiffin",
            style: GoogleFonts.manrope(
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Text(
            "Are you sure you want to delete this tiffin?",
            style: GoogleFonts.manrope(
              textStyle: const TextStyle(
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Cancel",
                style: GoogleFonts.manrope(
                    textStyle: const TextStyle(
                  color: primaryDark,
                  fontWeight: FontWeight.bold,
                )),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                "OK",
                style: GoogleFonts.manrope(
                    textStyle: const TextStyle(
                  color: primaryDark,
                  fontWeight: FontWeight.bold,
                )),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
    User? user = FirebaseAuth.instance.currentUser;
    if (shouldDelete && user != null) {
      await FirebaseFirestore.instance
          .collection("providers")
          .doc(user.email)
          .collection("Tiffins")
          .doc(id)
          .delete();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTiffin();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            backgroundColor: white,
            body: Center(
              child: CircularProgressIndicator(
                color: primaryDark,
              ),
            ),
          )
        : Scaffold(
            backgroundColor: white,
            floatingActionButton: FloatingActionButton(
              onPressed: () => showAddTiffinBottomSheet(context),
              backgroundColor: primaryDark,
              foregroundColor: white,
              shape: const CircleBorder(),
              tooltip: "Add tiffin",
              child: const Icon(Icons.add),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 30),
                        child: Text(
                          "Tiffins",
                          style: GoogleFonts.manrope(
                            textStyle: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.09,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      tiffins.isEmpty
                          ? Text(
                              "Please add tiffins",
                              style: GoogleFonts.manrope(),
                            )
                          : Container(
                              child: Text(
                                "Total (${tiffins.length})",
                                style: GoogleFonts.manrope(
                                  textStyle: TextStyle(
                                    color: black.withOpacity(0.5),
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.05,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(
                        height: 30,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height / 1.5,
                        child: ListView.builder(
                          itemCount: tiffins.length,
                          itemBuilder: (context, item) {
                            return Card(
                              color: primaryColor,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tiffins[item]["Name"],
                                              style: GoogleFonts.manrope(
                                                textStyle: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.05,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.6,
                                              child: Text(
                                                'Items: ${tiffins[item]["Items"]}',
                                                style: GoogleFonts.manrope(),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              'Meal Type: ${tiffins[item]["Meal Type"] == "Both" ? 'Lunch & Dinner' : tiffins[item]["Meal Type"]}',
                                              style: GoogleFonts.manrope(
                                                textStyle: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.035,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.6,
                                              child: Text(
                                                tiffins[item]["Details"] == ""
                                                    ? "No details available"
                                                    : 'Details: ${tiffins[item]["Details"]}',
                                                style: GoogleFonts.manrope(
                                                  textStyle: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.035,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '₹${tiffins[item]["Price"]}',
                                              style: GoogleFonts.manrope(
                                                textStyle: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.06,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            // const SizedBox(
                                            //   width: 15,
                                            // ),
                                            // const Icon(Icons.edit),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            showEditTiffinBottomSheet(
                                              context,
                                              tiffins[item]["id"],
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            width: (MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2) -
                                                30,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: primaryDark,
                                            ),
                                            child: Center(
                                                child: Text(
                                              "View & Edit",
                                              style: GoogleFonts.manrope(
                                                textStyle: const TextStyle(
                                                  color: white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            )),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            deleteTiffin(tiffins[item]["id"]);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            width: (MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2) -
                                                30,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: red.withOpacity(0.8),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Delete",
                                                style: GoogleFonts.manrope(
                                                  textStyle: const TextStyle(
                                                    color: white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}

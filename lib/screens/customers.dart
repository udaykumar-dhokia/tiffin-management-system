import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tiffin/components/add_customer.dart';
import 'package:tiffin/components/edit_tiffin.dart';
import 'package:tiffin/constants/color.dart';

class Customers extends StatefulWidget {
  const Customers({super.key});

  @override
  State<Customers> createState() => _CustomersState();
}

class _CustomersState extends State<Customers> {
  List<Map<String, dynamic>> customers = [];
  bool isLoading = false;

  Future<void> getCustomer() async {
    setState(() {
      isLoading = true;
    });
    User? user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection("providers")
        .doc(user!.email)
        .collection("Customers")
        .snapshots()
        .listen((snapshot) async {
      List<Map<String, dynamic>> tempCustomers = [];
      for (var doc in snapshot.docs) {
        var data = doc.data();
        data['id'] = doc.id;
        double totalAmount = 0;

        // Fetch the TimePeriod collection and sum the 'total' fields
        QuerySnapshot timePeriodsSnapshot = await FirebaseFirestore.instance
            .collection("providers")
            .doc(user.email)
            .collection("Customers")
            .doc(doc.id)
            .collection("TimePeriod")
            .get();

        for (var timePeriodDoc in timePeriodsSnapshot.docs) {
          totalAmount += timePeriodDoc['total'];
        }

        data['totalAmount'] = totalAmount;
        tempCustomers.add(data);
      }

      setState(() {
        customers = tempCustomers;
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCustomer();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryDark,
              ),
            )
          : Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () => showAddCustomerBottomSheet(context),
                backgroundColor: primaryDark,
                foregroundColor: white,
                shape: const CircleBorder(),
                tooltip: "New Customer",
                child: const Icon(Icons.add),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 30),
                        child: Text(
                          "Customers",
                          style: GoogleFonts.manrope(
                            textStyle: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.09,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      customers.isEmpty
                          ? Text(
                              "Please add customers",
                              style: GoogleFonts.manrope(),
                            )
                          : Container(
                              child: Text(
                                "Total (${customers.length})",
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
                          itemCount: customers.length,
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
                                              customers[item]["Name"],
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
                                                  0.5,
                                              child: Text(
                                                'Mobile: ${customers[item]["Mobile"]}',
                                                style: GoogleFonts.manrope(),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              'Meal Type: ${customers[item]["MealType"] == "Both" ? 'Lunch & Dinner' : customers[item]["MealType"]}',
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
                                                  0.5,
                                              child: Text(
                                                "Start Date: ${(customers[item]["Start Date"]).toDate().toIso8601String().split('T')[0]}",
                                                style: GoogleFonts.manrope(
                                                  textStyle: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.035,
                                                  ),
                                                ),
                                                // overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.5,
                                              child: Text(
                                                '${customers[item]["Address"]}',
                                                style: GoogleFonts.manrope(
                                                  textStyle: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.035,
                                                  ),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            customers[item]["Address 2"] == ""
                                                ? Container()
                                                : SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                    child: Text(
                                                      customers[item][
                                                                  "Address 2"] ==
                                                              ""
                                                          ? ""
                                                          : 'Address 2: ${customers[item]["Address 2"]}',
                                                      style:
                                                          GoogleFonts.manrope(
                                                        textStyle: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
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
                                              '₹${customers[item]["totalAmount"]}',
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
                                              customers[item]["id"],
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            width: (MediaQuery.of(context)
                                                    .size
                                                    .width) -
                                                60,
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

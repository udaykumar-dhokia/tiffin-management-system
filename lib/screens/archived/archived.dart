import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tiffin/components/toast/toast.dart';
import 'package:tiffin/constants/color.dart';
import 'package:toastification/toastification.dart';

class Archived extends StatefulWidget {
  const Archived({super.key});

  @override
  State<Archived> createState() => _ArchivedState();
}

class _ArchivedState extends State<Archived> {
  bool isLoading = false;
  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> filteredCustomers = [];

  Future<void> getArchivedCustomer() async {
    setState(() {
      isLoading = true;
    });
    User? user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection("providers")
        .doc(user!.email)
        .collection("Customers")
        .where("isArchived", isEqualTo: true)
        .snapshots()
        .listen((snapshot) async {
      List<Map<String, dynamic>> tempCustomers = [];
      for (var doc in snapshot.docs) {
        var data = doc.data();
        data['id'] = doc.id;
        double totalAmount = 0;

        QuerySnapshot timePeriodsSnapshot = await FirebaseFirestore.instance
            .collection("providers")
            .doc(user.email)
            .collection("Customers")
            .doc(doc.id)
            .collection("TimePeriod")
            .get();

        for (var timePeriodDoc in timePeriodsSnapshot.docs) {
          var timePeriodData = timePeriodDoc.data() as Map<String, dynamic>;
          var currentLunch =
              timePeriodData.containsKey("Lunch") ? timePeriodDoc["Lunch"] : 0;
          var currentDinner = timePeriodData.containsKey("Dinner")
              ? timePeriodDoc["Dinner"]
              : 0;
          totalAmount += currentDinner + currentLunch;
        }

        data['totalAmount'] = totalAmount;
        if (data["isArchived"] == true) {
          tempCustomers.add(data);
        }
      }

      setState(() {
        customers = tempCustomers;
        filteredCustomers = tempCustomers;
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getArchivedCustomer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: primaryDark,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: white,
                )),
            const SizedBox(
              width: 10,
            ),
            Text(
              "Archived Customers",
              style: GoogleFonts.manrope(
                fontSize: 25,
                color: white,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryDark,
              ),
            )
          : filteredCustomers.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.only(
                      left: 10, right: 10, top: 15, bottom: 15),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  filteredCustomers[item]["Name"],
                                  style: GoogleFonts.manrope(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(filteredCustomers[item]["Mobile"]),
                              ],
                            ),
                            IconButton(
                                onPressed: () async {
                                  User? user =
                                      FirebaseAuth.instance.currentUser;
                                  await FirebaseFirestore.instance
                                      .collection("providers")
                                      .doc(user!.email)
                                      .collection("Customers")
                                      .doc(filteredCustomers[item]["Mobile"])
                                      .update({"isArchived": false});

                                  ToastUtil.showToast(context, "Success", ToastificationType.success, "Unarchived successfully");
                                },
                                icon: const Icon(
                                  Icons.unarchive_rounded,
                                  color: Colors.green,
                                ))
                          ],
                        ),
                      );
                    },
                    itemCount: filteredCustomers.length,
                  ),
                )
              : Center(
                  child: Text(
                    "No archived customers.",
                    style: GoogleFonts.manrope(fontSize: 15),
                  ),
                ),
    );
  }
}

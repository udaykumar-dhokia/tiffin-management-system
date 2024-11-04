import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tiffin/components/customer/add_customer.dart';
import 'package:tiffin/components/customer/add_tiffin_to_customer.dart';
import 'package:tiffin/components/customer/edit_customer.dart';
import 'package:tiffin/constants/color.dart';
import 'package:tiffin/screens/archived/archived.dart';
import 'package:tiffin/screens/customers/particular.dart';
import 'package:url_launcher/url_launcher.dart';

class Customers extends StatefulWidget {
  ScrollController scrollController;
  Customers({super.key, required this.scrollController});

  @override
  State<Customers> createState() => _CustomersState();
}

class _CustomersState extends State<Customers> {
  List<Map<String, dynamic>> customers = [];
  Map<String, dynamic> provider = {};
  bool dark = false;

  bool isLoading = false;
  List<Map<String, dynamic>> filteredCustomers = [];
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  bool isSearching = false;

  Future<void> getCustomer() async {
    setState(() {
      isLoading = true;
    });
    User? user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection("providers")
        .doc(user!.email)
        .collection("Customers")
        .where("isArchived", isEqualTo: false)
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

        await FirebaseFirestore.instance
            .collection("providers")
            .doc(user.email)
            .snapshots()
            .listen((snapshot) {
          setState(() {
            provider = snapshot.data() as Map<String, dynamic>;

            if (provider.containsKey("isDarkMode")) {
              setState(() {
                dark = provider["isDarkMode"];
              });
            }
          });
        });

        for (var timePeriodDoc in timePeriodsSnapshot.docs) {
          var timePeriodData = timePeriodDoc.data() as Map<String, dynamic>;
          var currentLunch =
              timePeriodData.containsKey("Lunch") ? timePeriodDoc["Lunch"] : 0;
          var currentDinner = timePeriodData.containsKey("Dinner")
              ? timePeriodDoc["Dinner"]
              : 0;

          double extraItemsCost = 0;
          if (timePeriodData.containsKey("Lunch Extra Items")) {
            List<dynamic> extraItems = timePeriodData["Lunch Extra Items"];
            for (var item in extraItems) {
              extraItemsCost += (item['price'] as num).toDouble(); // Handle potential num type
            }
          }
          if (timePeriodData.containsKey("Dinner Extra Items")) {
            List<dynamic> extraItems = timePeriodData["Dinner Extra Items"];
            for (var item in extraItems) {
              extraItemsCost += (item['price'] as num).toDouble(); // Handle potential num type
            }
          }
          totalAmount += currentDinner + currentLunch + extraItemsCost;
        }


        data['totalAmount'] = totalAmount;
        if (data["isArchived"] == false) {
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

  Future<void> _makePhoneCall(String url) async {
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void filterCustomers() {
    List<Map<String, dynamic>> tempFilteredCustomers = [];
    if (searchQuery.isEmpty) {
      tempFilteredCustomers = customers;
    } else {
      tempFilteredCustomers = customers
          .where((customer) =>
              customer["Name"]
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              customer["Mobile"]
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              customer["Address"]
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
          .toList();
    }
    setState(() {
      filteredCustomers = tempFilteredCustomers;
    });
  }

  Future<void> _refresh() async {
    await getCustomer();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCustomer();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
        filterCustomers();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            backgroundColor: dark ? darkPrimary : primaryColor,
            body: Center(
              child: CircularProgressIndicator(
                color: dark ? primaryColor : primaryDark,
              ),
            ),
          )
        : Scaffold(
            backgroundColor: dark ? darkPrimary : white,
            floatingActionButton: FloatingActionButton(
              onPressed: () => showAddCustomerBottomSheet(context),
              backgroundColor: primaryDark,
              foregroundColor: white,
              shape: const CircleBorder(),
              tooltip: "New Customer",
              child: const Icon(Icons.add),
            ),
            appBar: AppBar(
              surfaceTintColor: white,
              backgroundColor: dark ? darkPrimary : white,
              toolbarHeight: 100,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        // margin: const EdgeInsets.only(top: 30),
                        child: Text(
                          "Customers",
                          style: GoogleFonts.manrope(
                            textStyle: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: dark ? white : darkPrimary,
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
                                "Total (${filteredCustomers.length})",
                                style: GoogleFonts.manrope(
                                  textStyle: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: dark
                                        ? white.withOpacity(0.5)
                                        : darkPrimary.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Archived(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.archive_rounded,
                            color: red,
                          )),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isSearching = !isSearching;
                          });
                        },
                        icon: const Icon(Icons.search),
                        color: dark ? white : darkPrimary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            body: SafeArea(
              child: RefreshIndicator(
                backgroundColor: primaryColor,
                color: primaryDark,
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, top: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const SizedBox(height: 20),
                        if (customers.isNotEmpty)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 3),
                            child: Wrap(
                              children: [
                                Visibility(
                                  visible: isSearching,
                                  child: TextFormField(
                                    style: GoogleFonts.manrope(
                                        textStyle: TextStyle(
                                            color: dark ? white : darkPrimary)),
                                    cursorColor: dark ? white : darkPrimary,
                                    controller: searchController,
                                    decoration: InputDecoration(
                                      suffixIcon: const Icon(
                                        Icons.search,
                                        color: Colors.grey,
                                      ),
                                      label: Text(
                                        "Search",
                                        style: GoogleFonts.manrope(
                                          textStyle: TextStyle(
                                            color: Colors.grey,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04,
                                          ),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 5),
                        if (customers.isNotEmpty)
                          Text(
                            "*Swipe from left to right for more options.",
                            style: GoogleFonts.manrope(
                              textStyle: TextStyle(
                                color: dark ? white : Colors.grey,
                              ),
                            ),
                          ),
                        const SizedBox(height: 10),
                        Container(
                          // height: MediaQuery.of(context).size.height - kBottomNavigationBarHeight*4,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 0),
                            child: ListView.builder(
                              shrinkWrap: true,
                              controller: widget.scrollController,
                              itemCount: filteredCustomers.length,
                              itemBuilder: (context, item) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ParticularCustomer(
                                          mobile: filteredCustomers[item]
                                              ["Mobile"],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Slidable(
                                    key: const ValueKey(0),
                                    startActionPane: ActionPane(
                                      motion: const ScrollMotion(),
                                      children: [
                                        SlidableAction(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          autoClose: true,
                                          onPressed: (context) =>
                                              _makePhoneCall("tel:" +
                                                  filteredCustomers[item]
                                                      ["Mobile"]),
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          icon: Icons.call,
                                          label: 'Call',
                                        ),
                                        SlidableAction(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          autoClose: true,
                                          onPressed: (context) async {
                                            User? user = FirebaseAuth
                                                .instance.currentUser;
                                            await FirebaseFirestore.instance
                                                .collection("providers")
                                                .doc(user!.email)
                                                .collection("Customers")
                                                .doc(filteredCustomers[item]
                                                        ["Mobile"]
                                                    .toString())
                                                .update({"isArchived": true});
                                          },
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          icon: Icons.archive_rounded,
                                          label: 'Archived',
                                        ),
                                      ],
                                    ),
                                    child: Card(
                                      color: primaryColor,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      filteredCustomers[item]
                                                          ["Name"],
                                                      style:
                                                          GoogleFonts.manrope(
                                                        textStyle: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.05,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.5,
                                                      child: Text(
                                                        'Mobile: ${filteredCustomers[item]["Mobile"]}',
                                                        style: GoogleFonts
                                                            .manrope(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      'Meal Type: ${filteredCustomers[item]["MealType"] == "Both" ? 'Lunch & Dinner' : filteredCustomers[item]["MealType"]}',
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
                                                    const SizedBox(height: 5),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.5,
                                                      child: Text(
                                                        '${filteredCustomers[item]["Address"]}',
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
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    filteredCustomers[item]
                                                                ["Address 2"] ==
                                                            ""
                                                        ? Container()
                                                        : SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.5,
                                                            child: Text(
                                                              filteredCustomers[
                                                                              item]
                                                                          [
                                                                          "Address 2"] ==
                                                                      ""
                                                                  ? ""
                                                                  : 'Address 2: ${filteredCustomers[item]["Address 2"]}',
                                                              style: GoogleFonts
                                                                  .manrope(
                                                                textStyle:
                                                                    TextStyle(
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
                                                      '₹${(filteredCustomers[item]['totalAmount'])}',
                                                      style:
                                                          GoogleFonts.manrope(
                                                        textStyle: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.06,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 15),
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    showEditCustomerBottomSheet(
                                                      context,
                                                      filteredCustomers[item]
                                                          ["id"],
                                                    );
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    width:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width) /
                                                                2 -
                                                            30,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      color: primaryDark,
                                                    ),
                                                    child: Center(
                                                        child: Text(
                                                      "View & Edit",
                                                      style:
                                                          GoogleFonts.manrope(
                                                        textStyle:
                                                            const TextStyle(
                                                          color: white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    )),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                GestureDetector(
                                                  onTap: () {
                                                    showAddTiffinToCustomerBottomSheet(
                                                        context,
                                                        filteredCustomers[item]
                                                            ["id"], () async {
                                                      Timer(
                                                          const Duration(
                                                              seconds: 1),
                                                          () async {
                                                        await getCustomer();
                                                      });
                                                    });
                                                    // _refresh();
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    width:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width) /
                                                                2 -
                                                            30,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      color: Colors.green,
                                                    ),
                                                    child: Center(
                                                        child: Text(
                                                      "Add tiffin",
                                                      style:
                                                          GoogleFonts.manrope(
                                                        textStyle:
                                                            const TextStyle(
                                                          color: white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    )),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}

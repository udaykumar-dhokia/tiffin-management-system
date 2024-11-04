import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tiffin/components/customer/add_customer.dart';
import 'package:tiffin/components/tiffin/add_tiffin.dart';
import 'package:tiffin/constants/color.dart';
import 'package:tiffin/screens/dashboard/fees.dart';
import 'package:tiffin/screens/dashboard/graph.dart';
import 'package:tiffin/screens/dashboard/history.dart';

class Homepage extends StatefulWidget {
  final dark;
  ScrollController scrollController;
  Homepage({super.key, required this.dark, required this.scrollController});

  @override
  State<Homepage> createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  Map<String, dynamic> provider = {};
  bool isLoading = false;
  User? user = FirebaseAuth.instance.currentUser;
  Future<double>? currentMonthIncomeFuture;
  int totalCustomers = 0;
  int totalTiffins = 0;
  int fees = 0;
  bool dark = false;
  final List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  String getMonthName(int month) {
    return monthNames[month - 1];
  }

  Future<double> getCurrentMonthIncome(String providerId) async {
    final firestore = FirebaseFirestore.instance;
    final customerCollection = firestore
        .collection('providers')
        .doc(providerId)
        .collection('Customers');

    final customerDocs = await customerCollection.get();
    double currentMonthIncome = 0.0;
    double extraItemsCost = 0;
    final now = DateTime.now();
    final currentMonthKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';

    for (var customerDoc in customerDocs.docs) {
      final timePeriodCollection =
          customerDoc.reference.collection('TimePeriod');
      final timePeriodDocs = await timePeriodCollection.get();

      for (var timePeriodDoc in timePeriodDocs.docs) {
        final data = timePeriodDoc.data();
        final date = DateTime.parse(timePeriodDoc.id);
        final monthKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}';

        if (monthKey == currentMonthKey) {
          if (data.containsKey('Lunch')) {
            currentMonthIncome += data['Lunch'];
          }
          if (data.containsKey('Dinner')) {
            currentMonthIncome += data['Dinner'];
          }
          if (data.containsKey("Lunch Extra Items")) {
            List<dynamic> extraItems = data["Lunch Extra Items"];
            for (var item in extraItems) {
              extraItemsCost += (item['price'] as num).toDouble();
            }
          }
          if (data.containsKey("Dinner Extra Items")) {
            List<dynamic> extraItems = data["Dinner Extra Items"];
            for (var item in extraItems) {
              extraItemsCost += (item['price'] as num).toDouble();
            }
          }
        }
      }
    }

    return currentMonthIncome+extraItemsCost;
  }

  Future<void> getProvider() async {
    setState(() {
      isLoading = true;
    });

    final data = await FirebaseFirestore.instance
        .collection("providers")
        .doc(user!.email)
        .get();

    final archived = await FirebaseFirestore.instance
        .collection("providers")
        .doc(user!.email)
        .collection("Customers")
        .get();

    for (var doc in archived.docs) {
      if (!doc.data().containsKey('isArchived')) {
        await doc.reference.update({'isArchived': false});
      }
    }

    if (data.exists) {
      setState(() {
        provider = data.data() as Map<String, dynamic>;
        if (provider.containsKey("isDarkMode")) {
          setState(() {
            dark = provider["isDarkMode"];
          });
        }
      });
    }

    if (!provider.containsKey("isDarkMode")) {
      provider["isDarkMode"] = false;
      final data = await FirebaseFirestore.instance
          .collection("providers")
          .doc(user!.email)
          .update({"isDarkMode": false});
    }

    String monthId = DateTime.now().month.toString();
    String yearMonthId = '${DateTime.now().year}-$monthId';
    final message = await FirebaseFirestore.instance
        .collection("providers")
        .doc(user!.email)
        .collection("Message")
        .doc('${yearMonthId}-${DateTime.now().day}').get();

    if(!message.exists){
      final message = await FirebaseFirestore.instance
          .collection("providers")
          .doc(user!.email)
          .collection("Message")
          .doc('${yearMonthId}-${DateTime.now().day}').set({"Lunch": true, "Dinner": true});
    }

    final platformFeeData = await FirebaseFirestore.instance
        .collection('providers')
        .doc(user!.email)
        .collection('Fees')
        .doc(yearMonthId)
        .get();

    if (platformFeeData.exists) {
      final platformFee = platformFeeData.data()?['platformFee'];
      setState(() {
        fees = platformFee;
      });
    }

    final tiffins = await FirebaseFirestore.instance
        .collection("providers")
        .doc(user!.email)
        .collection("Tiffins")
        .get();

    final int tiffinCount = tiffins.docs.length;
    setState(() {
      totalTiffins = tiffinCount;
    });

    final customers = await FirebaseFirestore.instance
        .collection("providers")
        .doc(user!.email)
        .collection("Customers")
        .get();

    final int customersCount = customers.docs.length;
    setState(() {
      totalCustomers = customersCount;
      isLoading = false;
    });
  }

  // void removeEmptyTimePeriods() async {
  //   final providersDocument = FirebaseFirestore.instance.collection('providers').doc(user!.email);
  //   final customersCollection = providersDocument.collection('Customers');
  //
  //   await customersCollection.get().then((customerQuerySnapshot) async {
  //     for (final customerDoc in customerQuerySnapshot.docs) {
  //       final timePeriodsCollection = customerDoc.reference.collection('TimePeriod');
  //
  //       // Query for time periods with empty lunch OR empty dinner
  //       final emptyLunchQuery = timePeriodsCollection.where('Lunch', isEqualTo: 0).where('lunchType', isEqualTo: '').where("Dinner", isNull: true).where("dinnerType", isNull: true);
  //       final emptyDinnerQuery = timePeriodsCollection.where('Dinner', isEqualTo: 0).where('dinnerType', isEqualTo: '');
  //
  //       // Delete matching time periods from both queries
  //       await emptyLunchQuery.get().then((timePeriodSnapshot) {for (final timePeriodDoc in timePeriodSnapshot.docs) {
  //         timePeriodDoc.reference.delete();
  //       }
  //       });
  //
  //       await emptyDinnerQuery.get().then((timePeriodSnapshot) {
  //         for (final timePeriodDoc in timePeriodSnapshot.docs) {
  //           timePeriodDoc.reference.delete();
  //         }
  //       });
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();
    getProvider();
    // removeEmptyTimePeriods();
    currentMonthIncomeFuture = getCurrentMonthIncome(user!.email.toString());
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonthName = getMonthName(now.month);

    return provider.isEmpty
        ? Scaffold(
            backgroundColor: dark ? darkPrimary : primaryColor,
            body: Center(
              child: CircularProgressIndicator(
                color: dark ? primaryColor : primaryDark,
              ),
            ),
          )
        : Scaffold(
            backgroundColor: provider["isDarkMode"] ? darkPrimary : white,
            resizeToAvoidBottomInset: true,
            floatingActionButton: _buildSpeedDial(),
            body: SafeArea(
              child: SingleChildScrollView(
                // controller: widget.scrollController,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 0),
                        child: Text(
                          provider["Name"] ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            textStyle: TextStyle(
                              color: dark ? white : darkPrimary,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.07,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              provider["Address"] ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                textStyle: TextStyle(
                                  color: dark
                                      ? white.withOpacity(0.5)
                                      : darkPrimary.withOpacity(0.5),
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 1,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 25),
                      Text(
                        "Dashboard",
                        style: GoogleFonts.manrope(
                          textStyle: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                            fontWeight: FontWeight.bold,
                            color: dark ? white : darkPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => History(
                                    provider: provider,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width / 2 - 20,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.green.withOpacity(0.7),
                              ),
                              child: FutureBuilder<double>(
                                future: currentMonthIncomeFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator(
                                      color: dark ? primaryColor : primaryDark,
                                    ));
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child:
                                            Text('Error: ${snapshot.error}'));
                                  } else if (!snapshot.hasData) {
                                    return const Center(
                                        child:
                                            Text('No income data available'));
                                  }

                                  final income = snapshot.data!;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "$currentMonthName's income",
                                        style: GoogleFonts.manrope(
                                          textStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2 *
                                                0.08,
                                            color: dark
                                                ? white.withOpacity(0.7)
                                                : darkPrimary.withOpacity(0.7),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      TweenAnimationBuilder<double>(
                                        tween: Tween<double>(
                                            begin: snapshot.data! == 0
                                                ? 0
                                                : snapshot.data! * 0.75,
                                            end: snapshot.data!),
                                        duration: Duration(seconds: 2),
                                        builder: (context, value, child) {
                                          return Text(
                                            '\₹${value.toStringAsFixed(2)}',
                                            style: GoogleFonts.manrope(
                                              textStyle: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 *
                                                    0.1,
                                                color:
                                                    dark ? white : darkPrimary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // bottombarKey.currentState?.changePage(3);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width / 2 - 20,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: dark ? primaryColor : primaryDark,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Customers",
                                    style: GoogleFonts.manrope(
                                      textStyle: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                2 *
                                                0.07,
                                        color: dark ? darkPrimary : white,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '$totalCustomers',
                                    style: GoogleFonts.manrope(
                                      textStyle: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                2 *
                                                0.1,
                                        color: dark ? darkPrimary : white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width / 2 - 20,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: dark ? primaryColor : primaryDark,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Tiffins",
                                    style: GoogleFonts.manrope(
                                      textStyle: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                2 *
                                                0.07,
                                        color: dark ? darkPrimary : white,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '$totalTiffins',
                                    style: GoogleFonts.manrope(
                                      textStyle: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                2 *
                                                0.1,
                                        color: dark ? darkPrimary : white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Fees(provider: provider)));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width / 2 - 20,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: dark ? primaryColor : primaryDark,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Platform fees",
                                    style: GoogleFonts.manrope(
                                      textStyle: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                2 *
                                                0.07,
                                        color: dark ? darkPrimary : white,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '₹$fees',
                                    style: GoogleFonts.manrope(
                                      textStyle: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                2 *
                                                0.1,
                                        color: dark ? darkPrimary : white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Text(
                        "Analysis",
                        style: GoogleFonts.manrope(
                          textStyle: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                            fontWeight: FontWeight.bold,
                            color: dark ? white : darkPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height / 2.5,
                        width: MediaQuery.of(context).size.width,
                        child: MonthlyIncomeBarChart(
                          providerId: user!.email.toString(),
                          provider: provider,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  Widget _buildSpeedDial() {
    return SpeedDial(
      backgroundColor: primaryDark,
      foregroundColor: white,
      icon: Icons.add,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.groups),
          backgroundColor: primaryColor,
          label: 'New Customer',
          onTap: () => showAddCustomerBottomSheet(context),
        ),
        SpeedDialChild(
          child: const Icon(Icons.local_dining_rounded),
          backgroundColor: primaryColor,
          label: 'Add Tiffin',
          onTap: () => showAddTiffinBottomSheet(context),
        ),
      ],
    );
  }
}

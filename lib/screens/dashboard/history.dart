import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tiffin/constants/color.dart';

class History extends StatefulWidget {
  Map<String, dynamic> provider;
  History({super.key, required this.provider});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  Future<Map<String, double>>? monthlyIncomeFuture;
  User? user = FirebaseAuth.instance.currentUser;

  Future<Map<String, double>> getMonthlyIncome(String providerId) async {
    final firestore = FirebaseFirestore.instance;
    final customerCollection = firestore
        .collection('providers')
        .doc(providerId)
        .collection('Customers');

    final customerDocs = await customerCollection.get();
    Map<String, double> monthlyIncome = {};

    for (var customerDoc in customerDocs.docs) {
      final timePeriodCollection =
          customerDoc.reference.collection('TimePeriod');
      final timePeriodDocs = await timePeriodCollection.get();
      for (var timePeriodDoc in timePeriodDocs.docs) {
        final data = timePeriodDoc.data();
        final date = DateTime.parse(timePeriodDoc.id);
        final monthKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}';

        if (data.containsKey('Lunch')) {
          monthlyIncome[monthKey] =
              (monthlyIncome[monthKey] ?? 0) + data['Lunch'];
        }
        if (data.containsKey('Dinner')) {
          monthlyIncome[monthKey] =
              (monthlyIncome[monthKey] ?? 0) + data['Dinner'];
        }
      }
    }

    return monthlyIncome;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    monthlyIncomeFuture = getMonthlyIncome(user!.email.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding:
            const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
        child: Row(
          children: [
            IconButton(
              color: primaryDark,
                highlightColor: primaryColor,
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: widget.provider["isDarkMode"]? primaryColor : primaryDark,),)
          ],
        ),
      ),
      backgroundColor: widget.provider["isDarkMode"]? darkPrimary : white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                height: MediaQuery.of(context).size.height * 0.3,
                child: Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // GestureDetector(
                      //     onTap: () {
                      //       Navigator.pop(context);
                      //     },
                      //     child: Icon(Icons.arrow_back_ios_new_rounded)),
                      // const SizedBox(
                      //   width: 10,
                      // ),
                      Text(
                        "Monthly income",
                        style: GoogleFonts.manrope(
                          textStyle: TextStyle(
                            color:  widget.provider["isDarkMode"]?  white: darkPrimary ,
                            fontSize: MediaQuery.of(context).size.width * 0.06,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                child: FutureBuilder<Map<String, double>>(
                  future: monthlyIncomeFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return  Center(
                          child: CircularProgressIndicator(
                        color: widget.provider["isDarkMode"]? primaryColor : primaryDark,
                      ));
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('No income data available'));
                    }

                    final incomeData = snapshot.data!;
                    final sortedKeys = incomeData.keys.toList()
                      ..sort((a, b) => b.compareTo(a));

                    return ListView.builder(
                      itemCount: sortedKeys.length,
                      itemBuilder: (context, index) {
                        final month = sortedKeys[index];
                        final income = incomeData[month]!;
                        final date = DateTime.parse('$month-01');
                        final formattedMonth =
                            DateFormat('MMMM yyyy').format(date);
                        return ListTile(
                          tileColor: widget.provider["isDarkMode"]? primaryColor : primaryDark,
                          textColor: white,
                          title: Text(
                            formattedMonth,
                            style: GoogleFonts.manrope(
                              textStyle: TextStyle(
                                color:  widget.provider["isDarkMode"]? darkPrimary : white,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04,
                              ),
                            ),
                          ),
                          trailing: Text(
                            '₹${income.toStringAsFixed(2)}',
                            style: GoogleFonts.manrope(
                              textStyle: TextStyle(
                                color:  widget.provider["isDarkMode"]? darkPrimary : white,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.045,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

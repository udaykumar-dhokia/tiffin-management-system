import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:tiffin/components/toast/toast.dart';
import 'package:tiffin/constants/color.dart';
import 'package:toastification/toastification.dart';

class Fees extends StatefulWidget {
  final Map<String, dynamic> provider;
  Fees({Key? key, required this.provider}) : super(key: key);

  @override
  State<Fees> createState() => _FeesState();
}

class _FeesState extends State<Fees> {
  Future<Map<String, Map<String, dynamic>>>? monthlyIncomeFuture;
  User? user = FirebaseAuth.instance.currentUser;
  final Razorpay _razorpay = Razorpay();
  String currentCustomerId = "";

  Future<Map<String, Map<String, dynamic>>> getMonthlyIncome(
      String providerId) async {
    final firestore = FirebaseFirestore.instance;
    final customerCollection =
        firestore.collection('providers').doc(providerId).collection('Fees');

    final customerDocs = await customerCollection.get();
    Map<String, Map<String, dynamic>> monthlyIncome = {};

    for (var fees in customerDocs.docs) {
      final data = fees.data();
      print(data);

      if (monthlyIncome[fees.id] == null) {
        monthlyIncome[fees.id] = {
          "platformFee": data["platformFee"],
          "isPaid": data["isPaid"],
        };
      } else {
        monthlyIncome[fees.id]!["platformFee"] += data["platformFee"];
        monthlyIncome[fees.id]!["isPaid"] = data["isPaid"];
      }
    }

    print(monthlyIncome);
    return monthlyIncome;
  }

  // Future<void> _makePayment(UpiApp app, String fees) async {
  //   UpiResponse response = await _upiIndia.startTransaction(
  //     app: app,
  //     receiverUpiId: "9537527143@upi",
  //     receiverName: "Udaykumar Dhokia",
  //     transactionRefId: "UniqueTransactionId",
  //     transactionNote: "Payment for platform fee",
  //     amount: double.parse(fees),
  //   );
  //
  //   switch (response.status) {
  //     case UpiPaymentStatus.SUCCESS:
  //       monthlyIncomeFuture = getMonthlyIncome(user!.email.toString());
  //       ToastUtil.showToast(context, "Success", ToastificationType.success,
  //           "Payment successful.");
  //       await FirebaseFirestore.instance
  //           .collection("providers")
  //           .doc(user!.email)
  //           .update({"isPaid": true});
  //       break;
  //     case UpiPaymentStatus.FAILURE:
  //       ToastUtil.showToast(context, "Failure", ToastificationType.error,
  //           "Payment failed. Please try again.");
  //       break;
  //     case UpiPaymentStatus.SUBMITTED:
  //       ToastUtil.showToast(context, "Pending", ToastificationType.warning,
  //           "Payment submitted. Please check your UPI app for confirmation.");
  //       break;
  //     default:
  //       ToastUtil.showToast(context, "Error", ToastificationType.error,
  //           "Payment error. Please try again.");
  //       break;
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) {
      _handlePaymentSuccess(response, currentCustomerId);
    });
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    monthlyIncomeFuture = getMonthlyIncome(user!.email.toString());
  }
  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response,  String month) {
    ToastUtil.showToast(context, "Success", ToastificationType.success,
        "Payment successful.");
    FirebaseFirestore.instance
        .collection("providers")
        .doc(user!.email)
        .collection("Fees")
        .doc(month)
        .update({"isPaid": true});
    setState(() {
      monthlyIncomeFuture = getMonthlyIncome(user!.email.toString());
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ToastUtil.showToast(context, "Failure", ToastificationType.error,
        "Payment failed. Please try again.");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ToastUtil.showToast(context, "External Wallet", ToastificationType.warning,
        "Payment via external wallet.");
  }

  void _makePayment(String amount, String month) {
    var options = {
      'key': 'rzp_test_wTRZuiYSYcUi0y',
      'amount': double.parse(amount) * 100,
      'name': 'Tiffin Service',
      'description': 'Payment for platform fee',
      'prefill': {'contact': '9537527143', 'email': user!.email},
      'theme': {
        'color': '#1e4e73',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // void _showPaymentOptions(String amount) {
  //   showModalBottomSheet(
  //     backgroundColor: white,
  //     context: context,
  //     builder: (BuildContext context) {
  //       if (_availableApps == null) {
  //         return Center(child: CircularProgressIndicator());
  //       }
  //       if (_availableApps!.isEmpty) {
  //         return Center(child: Text("No UPI apps available"));
  //       }
  //       return Padding(
  //         padding: const EdgeInsets.only(left: 15, right: 15),
  //         child: Column(
  //           children: [
  //             const SizedBox(
  //               height: 20,
  //             ),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   "Select Payment Method",
  //                   style: GoogleFonts.barlow(
  //                     textStyle: TextStyle(
  //                       fontSize: MediaQuery.of(context).size.width * 0.05,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                 ),
  //                 Text(
  //                   "₹$amount",
  //                   style: GoogleFonts.barlow(
  //                     textStyle: TextStyle(
  //                       fontSize: MediaQuery.of(context).size.width * 0.05,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(
  //               height: 20,
  //             ),
  //             Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: _availableApps!.map((UpiApp app) {
  //                 return ListTile(
  //                   leading: Image.memory(app.icon, width: 24, height: 24),
  //                   title: Text(app.name),
  //                   onTap: () {
  //                     Navigator.pop(context);
  //                     _makePayment(amount);
  //                   },
  //                 );
  //               }).toList(),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  void _showPaymentOptions(String amount, String month) {
    currentCustomerId = month;
    _makePayment(amount, month);
  }

  bool _isPayButtonEnabled(int month) {
    DateTime now = DateTime.now();
    DateTime lastDayOfMonth = DateTime(now.year, month + 1, 0);

    return now.isAfter(lastDayOfMonth);
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
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color:
                    widget.provider["isDarkMode"] ? primaryColor : primaryDark,
              ),
            )
          ],
        ),
      ),
      backgroundColor: widget.provider["isDarkMode"] ? darkPrimary : white,
      body: SafeArea(
        child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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
                        Text(
                          "Platform Fees",
                          style: GoogleFonts.manrope(
                            textStyle: TextStyle(
                              color: widget.provider["isDarkMode"]
                                  ? white
                                  : darkPrimary,
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
                  child: FutureBuilder<Map<String, Map<String, dynamic>>>(
                    future: monthlyIncomeFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: widget.provider["isDarkMode"]
                                ? primaryColor
                                : primaryDark,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No data available'));
                      }

                      final incomeData = snapshot.data!;
                      final sortedKeys = incomeData.keys.toList()
                        ..sort((a, b) => b.compareTo(a));


                      return ListView.builder(
                        itemCount: sortedKeys.length,
                        itemBuilder: (context, index) {
                          final customerId = sortedKeys[index];
                          final incomeDetails = incomeData[customerId]!;
                          final platformFee = incomeDetails["platformFee"];
                          final isPaid = incomeDetails["isPaid"];

                          return ListTile(
                            tileColor: incomeDetails["isPaid"]
                                ? Colors.green
                                : Colors.red,
                            textColor: Colors.white,
                            title: Text(
                              '$customerId',
                              style: GoogleFonts.manrope(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04,
                                ),
                              ),
                            ),
                            subtitle: Text(
                              'Paid: ${incomeDetails["isPaid"] ? "Yes" : "No"}',
                              style: GoogleFonts.manrope(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.035,
                                ),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '₹${incomeDetails["platformFee"].toStringAsFixed(2)}',
                                  style: GoogleFonts.manrope(
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.045,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: incomeDetails["isPaid"]
                                      ? () {
                                        }
                                      : !_isPayButtonEnabled( int.parse(customerId.split('-')[1]))?(){
                                    ToastUtil.showToast(context, "Disabled", ToastificationType.warning, "Pay option will be enabled at the end of the month.");
                                  }
                                      :
                                      () {
                                          _showPaymentOptions(
                                              incomeDetails["platformFee"]
                                                  .toString(), customerId);
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: incomeDetails["isPaid"]
                                        ? Colors.grey.withOpacity(0.1)
                                        : Colors.green,
                                  ),
                                  child: Text(
                                    incomeDetails["isPaid"]? "Paid" : 'Pay',
                                    style: GoogleFonts.manrope(
                                      textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.035,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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

import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tiffin/components/customer/add_tiffin_to_customer.dart';
import 'package:tiffin/components/customer/edit_customer.dart';
import 'package:tiffin/constants/color.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/tiffin/delete_tiffin.dart';

class ParticularCustomer extends StatefulWidget {
  String mobile;
  ParticularCustomer({super.key, required this.mobile});

  @override
  State<ParticularCustomer> createState() => ParticularCustomerState();
}

class ParticularCustomerState extends State<ParticularCustomer> {
  Map<String, dynamic>? customer;
  Map<String, dynamic>? provider;
  bool isLoading = false;
  double totalAmount = 0;
  double tempAmount = 0;
  double tempextraItemsCost = 0;
  double extraItemsCost = 0;
  bool dark = false;
  bool isExpanded = false;
  double totalMonthlyAmount = 0;


  @override
  void initState() {
    super.initState();
    getCustomer();
  }

  void toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  void fetchMonthlyIncome(String monthKey)async{
    User? user = FirebaseAuth.instance.currentUser;
    final timePeriodsSnapshot = await FirebaseFirestore.instance
        .collection("providers")
        .doc(user!.email)
        .collection("Customers")
        .doc(widget.mobile)
        .collection("TimePeriod")
        .get();

    List<QueryDocumentSnapshot> filteredDocs =
    timePeriodsSnapshot.docs.where((doc) {
      return doc.id.startsWith(monthKey);
    }).toList();

    for (var timePeriodDoc in filteredDocs) {
      var timePeriodData = timePeriodDoc.data() as Map<String, dynamic>;

      var currentLunch =
      timePeriodData.containsKey("Lunch") ? timePeriodData["Lunch"] : 0;
      var currentDinner =
      timePeriodData.containsKey("Dinner") ? timePeriodData["Dinner"] : 0;
      setState(() {
        totalMonthlyAmount += currentDinner + currentLunch;
      });
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> _fetchData() async {
    User? user = FirebaseAuth.instance.currentUser;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('providers')
        .doc(user!.email)
        .collection("Customers")
        .doc(widget.mobile)
        .collection("TimePeriod")
        .get();

    List<Map<String, dynamic>> dataList = querySnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'data': doc.data(),
      };
    }).toList();

    dataList.sort((a, b) {
      DateTime dateA = DateTime.parse(a['id']);
      DateTime dateB = DateTime.parse(b['id']);
      return dateA.compareTo(dateB);
    });

    Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (var data in dataList) {
      DateTime date = DateTime.parse(data['id']);
      String monthKey = DateFormat('yyyy-MM').format(date);

      if (groupedData.containsKey(monthKey)) {
        groupedData[monthKey]!.add(data);
      } else {
        groupedData[monthKey] = [data];
      }
    }

    return groupedData;
  }

  Future<void> getCustomer() async {
    setState(() {
      isLoading = true;
    });
    User? user = FirebaseAuth.instance.currentUser;
    final data = await FirebaseFirestore.instance
        .collection("providers")
        .doc(user!.email)
        .collection("Customers")
        .doc(widget.mobile)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        customer = snapshot.data();
      });
    });

    final data2 = await FirebaseFirestore.instance
        .collection("providers")
        .doc(user.email)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        provider = snapshot.data();

        if(provider!.containsKey("isDarkMode")){
          setState(() {
            dark = provider!["isDarkMode"];
          });
        }
      });
    });

    QuerySnapshot timePeriodsSnapshot = await FirebaseFirestore.instance
        .collection("providers")
        .doc(user.email)
        .collection("Customers")
        .doc(widget.mobile)
        .collection("TimePeriod")
        .get();

    for (var timePeriodDoc in timePeriodsSnapshot.docs) {
      var timePeriodData = timePeriodDoc.data() as Map<String, dynamic>;
      var currentLunch =
          timePeriodData.containsKey("Lunch") ? timePeriodDoc["Lunch"] : 0;
      var currentDinner =
          timePeriodData.containsKey("Dinner") ? timePeriodDoc["Dinner"] : 0;
      if (timePeriodData.containsKey("Lunch Extra Items")) {
        List<dynamic> extraItems = timePeriodData["Lunch Extra Items"];
        for (var item in extraItems) {
          tempextraItemsCost += (item['price'] as num).toDouble();
        }
      }
      if (timePeriodData.containsKey("Dinner Extra Items")) {
        List<dynamic> extraItems = timePeriodData["Dinner Extra Items"];
        for (var item in extraItems) {
          tempextraItemsCost += (item['price'] as num).toDouble();
        }
      }
      setState(() {
        tempAmount += currentDinner + currentLunch + tempextraItemsCost;
      });
    }

    if (totalAmount == tempAmount || totalAmount == 0) {
      QuerySnapshot timePeriodsSnapshot = await FirebaseFirestore.instance
          .collection("providers")
          .doc(user.email)
          .collection("Customers")
          .doc(widget.mobile)
          .collection("TimePeriod")
          .get();

      for (var timePeriodDoc in timePeriodsSnapshot.docs) {
        var timePeriodData = timePeriodDoc.data() as Map<String, dynamic>;
        var currentLunch =
            timePeriodData.containsKey("Lunch") ? timePeriodDoc["Lunch"] : 0;
        var currentDinner =
            timePeriodData.containsKey("Dinner") ? timePeriodDoc["Dinner"] : 0;
        if (timePeriodData.containsKey("Lunch Extra Items")) {
          List<dynamic> extraItems = timePeriodData["Lunch Extra Items"];
          for (var item in extraItems) {
            extraItemsCost += (item['price'] as num).toDouble();
          }
        }
        if (timePeriodData.containsKey("Dinner Extra Items")) {
          List<dynamic> extraItems = timePeriodData["Dinner Extra Items"];
          for (var item in extraItems) {
            extraItemsCost += (item['price'] as num).toDouble();
          }
        }
        setState(() {
          totalAmount += currentDinner + currentLunch + extraItemsCost;
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _makePhoneCall(String url) async {
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _refresh() async {
    await _fetchData();
    await getCustomer();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ?  Scaffold(
            backgroundColor: dark? darkPrimary : white,
            body: Center(
              child: CircularProgressIndicator(
                color: dark? primaryColor : primaryDark,
              ),
            ),
          )
        : RefreshIndicator(
            backgroundColor: primaryColor,
            color: primaryDark,
            onRefresh: _refresh,
            child: Scaffold(
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.only(left: 0, right: 0, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        showEditCustomerBottomSheet(context, widget.mobile);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2 - 15,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: primaryDark,
                        ),
                        child: Center(
                          child: Text(
                            "Edit",
                            style: GoogleFonts.manrope(
                              textStyle: const TextStyle(
                                color: white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        showAddTiffinToCustomerBottomSheet(
                            context, widget.mobile, () async {
                          Timer(Duration(seconds: 1), ()async{
                            await getCustomer();
                          });
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2 - 15,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.green,
                        ),
                        child: Center(
                          child: Text(
                            "Add tifin",
                            style: GoogleFonts.manrope(
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: provider!["isDarkMode"]? darkPrimary : white,
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child:  Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color:  dark? white : darkPrimary,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                overflow: TextOverflow.ellipsis,
                                customer?["Name"],
                                style: GoogleFonts.manrope(
                                  textStyle: TextStyle(
                                    color:  dark? white : darkPrimary,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.07,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _makePhoneCall("tel:${widget.mobile}");
                              },
                              child: const CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.green,
                                foregroundColor: white,
                                child: Icon(
                                  Icons.call,
                                  size: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              overflow: TextOverflow.ellipsis,
                              customer!["Address"],
                              style: GoogleFonts.manrope(
                                textStyle: TextStyle(
                                  color:  dark? white : darkPrimary,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        widget.mobile,
                        style: GoogleFonts.manrope(
                          textStyle: TextStyle(
                            color:  dark? white : darkPrimary,
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Total income: ",
                              style: GoogleFonts.manrope(
                                textStyle: TextStyle(
                                  color:  dark? white : darkPrimary,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                              ),
                            ),
                            Text(
                              "₹$totalAmount",
                              style: GoogleFonts.manrope(
                                textStyle: TextStyle(
                                  color:  dark? white : darkPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.07,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "History",
                            style: GoogleFonts.manrope(
                              textStyle: TextStyle(
                                color:  dark? white : darkPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.05,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  await _refresh();
                                },
                                child: Icon(Icons.history, color:  dark? white : darkPrimary,),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  showDeleteTiffinOfCustomerBottomSheet(
                                      context, widget.mobile);
                                  await getCustomer();
                                },
                                child: const Icon(
                                  Icons.delete_rounded,
                                  color: red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      RefreshIndicator(
                        onRefresh: _refresh,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: FutureBuilder<
                              Map<String, List<Map<String, dynamic>>>>(
                            future: _fetchData(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color:  dark? primaryColor : primaryDark,
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              }

                              Map<String, List<Map<String, dynamic>>>
                                  groupedData = snapshot.data ?? {};

                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                // decoration: BoxDecoration(
                                //   borderRadius: BorderRadius.circular(15),
                                //   color: Colors.grey.withOpacity(0.3),
                                // ),
                                height: MediaQuery.of(context).size.height / 2,
                                child: ListView.builder(
                                  itemCount: groupedData.keys.length,
                                  itemBuilder: (context, index) {
                                    String monthKey =
                                        groupedData.keys.elementAt(index);
                                    List<Map<String, dynamic>> monthData =
                                        groupedData[monthKey]!;

                                    List<String> allColumns =
                                        _getAllColumns(monthData);
                                    // fetchMonthlyIncome(monthKey);

                                    return ExpansionTile(
                                      textColor: primaryDark,
                                      backgroundColor: primaryColor,
                                      initiallyExpanded: isExpanded,
                                      enableFeedback: true,
                                      shape: const BeveledRectangleBorder(),
                                      subtitle: Text(
                                        "Total: ${monthData.length.toString()}",
                                        style: GoogleFonts.manrope(
                                          textStyle: TextStyle(
                                            color:  dark? white : darkPrimary,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.03,
                                          ),
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize
                                            .min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.download,
                                              color:  dark? white : darkPrimary,
                                            ),
                                            onPressed: () async {
                                              _generateInvoiceForMonth(
                                                  monthData, monthKey);
                                            },
                                          ),
                                        ],
                                      ),
                                      title: Text(
                                        DateFormat('MMMM yyyy').format(
                                            DateTime.parse('$monthKey-01')),
                                        style: GoogleFonts.manrope(
                                          textStyle: TextStyle(
                                            color:  dark? white : darkPrimary,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.05,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      children: [
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: DataTable(
                                            border: TableBorder.all(
                                              width: 0.5,
                                              color: primaryDark,
                                            ),
                                            columns: _createColumns(allColumns),
                                            rows: _createRows(
                                                monthData, allColumns),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
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
          );
  }

  List<String> _getAllColumns(List<Map<String, dynamic>> data) {
    Set<String> columns = {"Date"};
    for (var item in data) {
      columns.addAll(item['data'].keys);
    }
    return columns.toList();
  }

  List<DataColumn> _createColumns(List<String> columns) {
    return columns.map(
      (column) {
        return DataColumn(
          label: column == "lunchType"
              ? Text(
                  "Lunch type",
                  style: GoogleFonts.manrope(
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              : column == "dinnerType"
                  ? Text(
                      "Dinner type",
                      style: GoogleFonts.manrope(
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.bold)),
                    )
                  : column == "Lunch"
                      ? Text(
                          "Lunch (₹)",
                          style: GoogleFonts.manrope(
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      : column == "Dinner"
                          ? Text(
                              "Dinner (₹)",
                              style: GoogleFonts.manrope(
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          : Text(
                              column,
                              style: GoogleFonts.manrope(
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
        );
      },
    ).toList();
  }

  List<DataRow> _createRows(
      List<Map<String, dynamic>> data, List<String> allColumns) {
    return data.map((item) {
      Map<String, dynamic> rowData = item['data'];
      return DataRow(
          cells: allColumns.map((column) {
        if (column == 'Date') {
          return DataCell(
            Text(
              item['id'],
              style: GoogleFonts.manrope(),
            ),
          );
        }  else if (column == 'Lunch Extra Items' || column == "Dinner Extra Items") {
          // Handle Extra Items column
          if (rowData.containsKey('Lunch Extra Items')) {
            List<dynamic> extraItems = rowData['Lunch Extra Items'];
            return DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: extraItems.map((extraItem) {
                  return Text(
                    "${extraItem['item']} (₹${extraItem['price']})",
                    style: GoogleFonts.manrope(),
                  );
                }).toList(),
              ),
            );
          } else if (rowData.containsKey('Dinner Extra Items')) {
            List<dynamic> extraItems = rowData['Dinner Extra Items'];
            return DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: extraItems.map((extraItem) {
                  return Text(
                    "${extraItem['item']} (₹${extraItem['price']})",
                    style: GoogleFonts.manrope(),
                  );
                }).toList(),
              ),
            );
          }
          else {
            return DataCell(Text('-', style: GoogleFonts.manrope()));
          }
        }
        else {
          return DataCell(Text(
            rowData[column] == null? "-" : rowData[column] == 0? "-" : rowData[column].toString() ?? '-',
            style: GoogleFonts.manrope(),
          ));
        }
      }).toList());
    }).toList();
  }

  Future<Uint8List> getImageData(String imagePath) async {
    final ByteData data = await rootBundle.load(imagePath);
    return data.buffer.asUint8List();
  }

  Future<Uint8List> generateQrCode(String data) async {
    final qrValidationResult = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );
    final qrCode = qrValidationResult.qrCode;
    final painter = QrPainter.withQr(
      qr: qrCode!,
      // color: const Color(0xFF000000),
      gapless: true,
    );
    final picData = await painter.toImageData(200);
    return picData!.buffer.asUint8List();
  }

  void _generateInvoiceForMonth(
      List<Map<String, dynamic>> monthData, String monthKey) async {
    final pdf = pw.Document();
    final Uint8List imageData = await getImageData('lib/assets/logo.png');
    double totalMonthlyAmount = 0;
    double extraItemsCost = 0;


    User? user = FirebaseAuth.instance.currentUser;
    final timePeriodsSnapshot = await FirebaseFirestore.instance
        .collection("providers")
        .doc(user!.email)
        .collection("Customers")
        .doc(widget.mobile)
        .collection("TimePeriod")
        .get();

    List<QueryDocumentSnapshot> filteredDocs =
        timePeriodsSnapshot.docs.where((doc) {
      return doc.id.startsWith(monthKey);
    }).toList();

    for (var timePeriodDoc in filteredDocs) {
      var timePeriodData = timePeriodDoc.data() as Map<String, dynamic>;

      var currentLunch =
          timePeriodData.containsKey("Lunch") ? timePeriodData["Lunch"] : 0;
      var currentDinner =
          timePeriodData.containsKey("Dinner") ? timePeriodData["Dinner"] : 0;

      if (timePeriodData.containsKey("Lunch Extra Items")) {
        List<dynamic> extraItems = timePeriodData["Lunch Extra Items"];
        for (var item in extraItems) {
          extraItemsCost += (item['price'] as num).toDouble();
        }
      }
      if (timePeriodData.containsKey("Dinner Extra Items")) {
        List<dynamic> extraItems = timePeriodData["Dinner Extra Items"];
        for (var item in extraItems) {
          extraItemsCost += (item['price'] as num).toDouble();
        }
      }
      setState(() {
        totalMonthlyAmount += currentDinner + currentLunch + extraItemsCost;
      });
    }

    final upiLink = Uri.encodeFull(
        'upi://pay?pa=${provider!["UPI"]}&am=$totalMonthlyAmount&cu=INR');
    final qrCodeData = await generateQrCode(upiLink);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Invoice for ${DateFormat('MMMM yyyy').format(DateTime.parse('$monthKey-01'))}',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Image(
                    pw.MemoryImage(imageData),
                    width: 50,
                    height: 50,
                  ),
                ],
              ),
              pw.SizedBox(height: 50),
              pw.Text("To,"),
              pw.Text(
                customer!["Name"],
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                customer!["Mobile"],
                style: const pw.TextStyle(),
              ),
              pw.Text(
                customer!["Address"],
                style: const pw.TextStyle(),
              ),
              pw.SizedBox(height: 20),
              pw.Text("From,"),
              pw.Text(
                provider!["Name"],
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                provider!["Username"],
                style: const pw.TextStyle(),
              ),
              pw.Text(
                provider!["Mobile"],
                style: const pw.TextStyle(),
              ),
              pw.Text(
                provider!["Email"],
                style: const pw.TextStyle(),
              ),
              pw.SizedBox(height: 30),
              pw.TableHelper.fromTextArray(
                context: context,
                headers: _getAllColumns(monthData),
                data: _getTableData(monthData, _getAllColumns(monthData)),
              ),
              pw.SizedBox(height: 10),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "Total: $totalMonthlyAmount",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Image(pw.MemoryImage(qrCodeData), width: 135, height: 135),
              pw.SizedBox(height: 10),
              pw.Text(
                "Scan the QR code to pay",
                style: const pw.TextStyle(),
              ),
            ],
          );
        },
      ),
    );

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF generated successfully for $monthKey'),
          duration: const Duration(seconds: 2),
        ),
      );
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate PDF for $monthKey'),
          duration: const Duration(seconds: 2),
        ),
      );
      print('Failed to generate PDF: $e');
    }
  }

  List<List<dynamic>> _getTableData(
      List<Map<String, dynamic>> data, List<String> columns) {
    return data.map((item) {
      Map<String, dynamic> rowData = item['data'];
      return columns.map((column) {
        if (column == 'Date') {
          return item['id'];
        } else if (column == 'Lunch Extra Items' || column == "Dinner Extra Items") {
          // Handle Extra Items column
          if (rowData.containsKey('Lunch Extra Items')) {
            List<dynamic> extraItems = rowData['Lunch Extra Items'];
            return DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: extraItems.map((extraItem) {
                  return Text(
                    "${extraItem['item']} (₹${extraItem['price']})",
                    style: GoogleFonts.manrope(),
                  );
                }).toList(),
              ),
            );
          } else if (rowData.containsKey('Dinner Extra Items')) {
            List<dynamic> extraItems = rowData['Dinner Extra Items'];
            return DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: extraItems.map((extraItem) {
                  return Text(
                    "${extraItem['item']} (₹${extraItem['price']})",
                    style: GoogleFonts.manrope(),
                  );
                }).toList(),
              ),
            );
          }
        else {
          return rowData[column] == null? "-" :  rowData[column] == 0? "-" :  rowData[column].toString() ?? '-';
        }
      }}).toList();
    }).toList();
  }
}

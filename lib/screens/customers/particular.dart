import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tiffin/components/add_tiffin_to_customer.dart';
import 'package:tiffin/components/edit_customer.dart';
import 'package:tiffin/constants/color.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool isExpanded = false;

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
        .doc(user!.email)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        provider = snapshot.data();
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
      setState(() {
        tempAmount += currentDinner + currentLunch;
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
        setState(() {
          totalAmount += currentDinner + currentLunch;
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
        : RefreshIndicator(
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
                            context, widget.mobile);
                        _refresh();
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
              backgroundColor: white,
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
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
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
                                customer!["Name"],
                                style: GoogleFonts.manrope(
                                  textStyle: TextStyle(
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
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                              ),
                            ),
                            Text(
                              "₹$totalAmount",
                              style: GoogleFonts.manrope(
                                textStyle: TextStyle(
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
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.05,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          GestureDetector(
                            onTap: () async {
                              await _refresh();
                            },
                            child: const Icon(Icons.history),
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
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: primaryDark,
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              }

                              Map<String, List<Map<String, dynamic>>>
                                  groupedData = snapshot.data ?? {};

                              return SizedBox(
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
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.03,
                                          ),
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize
                                            .min, // Ensure the row takes minimum space
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.list_alt_rounded,
                                              color: black,
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
        } else {
          return DataCell(Text(
            rowData[column]?.toString() ?? '-',
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
        } else {
          return rowData[column]?.toString() ?? '';
        }
      }).toList();
    }).toList();
  }
}

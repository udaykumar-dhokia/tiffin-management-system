import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:telephony/telephony.dart';
import 'package:tiffin/components/toast/toast.dart';
import 'package:tiffin/constants/color.dart';
import 'package:toastification/toastification.dart';

class MessageMenu extends StatefulWidget {
  const MessageMenu({super.key});

  @override
  State<MessageMenu> createState() => _MessageMenuState();
}

class _MessageMenuState extends State<MessageMenu> {
  final Telephony telephony = Telephony.instance;
  bool isLoading = false;
  bool ismsgLoading = false;
  bool dark = false;
  List<Map<String, dynamic>> filteredCustomers = [];
  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> selectedCustomers = [];
  Map<String, dynamic> message = {};
  TextEditingController _menu = TextEditingController();
  bool selectAll = false;
  String providerName = "";
  String selectedMeal = "null";

  void sendSMS(String message, List<String> recipients) async {
    bool? permissionsGranted = await telephony.requestSmsPermissions;
    if (permissionsGranted == true) {
      setState(() {
        ismsgLoading = true;
      });
      for (String recipient in recipients) {
        await telephony.sendSms(
          to: recipient,
          message:
              '''Hello,\n\nHere's $selectedMeal tiffin menu:\n\n$message\n\nThank you for choosing our service!\n\nBest regards,\n$providerName''',
        );
      }
      setState(() {
        ismsgLoading = false;
      });
      ToastUtil.showToast(context, "Success", ToastificationType.success,
          "Menu sent successfully.");
    } else {
      ToastUtil.showToast(context, "Error", ToastificationType.error,
          "SMS permissions not granted");
      print("SMS permissions not granted");
    }
  }

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
            final provider = snapshot.data() as Map<String, dynamic>;

            setState(() {
              providerName = provider["Name"];
            });

            if (provider.containsKey("isDarkMode")) {
              setState(() {
                dark = provider["isDarkMode"];
              });
            }
          });
        });
        
        final messageData = await FirebaseFirestore.instance.collection("providers").doc(user.email).collection("Message").doc('${DateTime.now().year}-${DateTime.now().month.toString()}-${DateTime.now().day}').get();
        setState(() {
          message = messageData.data()!;
        });

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

  @override
  void initState() {
    super.initState();
    getCustomer();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            backgroundColor: primaryColor,
            body: Center(
              child: CircularProgressIndicator(
                color: primaryDark,
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: dark ? darkPrimary : white,
              toolbarHeight: 100,
              surfaceTintColor: dark ? darkPrimary : white,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Text(
                      "Send Menu",
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
                            "Total Customers (${customers.length})",
                            style: GoogleFonts.manrope(
                              textStyle: TextStyle(
                                color: dark
                                    ? white.withOpacity(0.5)
                                    : darkPrimary.withOpacity(0.5),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
            backgroundColor: dark ? darkPrimary : white,
            body: customers.isNotEmpty
                ? SafeArea(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 50,
                            left: 10,
                            right: 10,
                            bottom: kBottomNavigationBarHeight),
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: primaryColor,
                                  labelText: 'Select a meal',
                                  labelStyle: GoogleFonts.barlow(
                                      textStyle: const TextStyle(color: black)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide:
                                          const BorderSide(color: black)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  )),
                              items: ["Lunch", "Dinner"]
                                  .map((meal) => DropdownMenuItem(
                                        value: meal,
                                        child: Text(
                                          meal,
                                          style: GoogleFonts.barlow(
                                            textStyle: const TextStyle(
                                              color: black,
                                            ),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                print(value);
                                setState(() {
                                  selectedMeal = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    style: GoogleFonts.barlow(
                                      textStyle: TextStyle(
                                        color: dark ? black : darkPrimary,
                                      ),
                                    ),
                                    controller: _menu,
                                    cursorColor: dark ? black : darkPrimary,
                                    maxLines: 5,
                                    minLines: 1,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: primaryColor,
                                      label: Text(
                                        "Menu",
                                        style: GoogleFonts.barlow(
                                          textStyle: TextStyle(
                                            color: dark ? black : darkPrimary,
                                          ),
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                            color: dark ? white : darkPrimary),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (_menu.text.isNotEmpty &&
                                        selectedMeal != "null" &&
                                        selectedCustomers.isNotEmpty) {
                                      if(selectedMeal == "Lunch" && message["Lunch"] == false){
                                        ToastUtil.showToast(context, "Limit Reached", ToastificationType.error, "You have reached the maximum limit for sending the lunch menu for today.");
                                      }
                                      else if(selectedMeal == "Dinner" && message["Dinner"] == false){
                                        ToastUtil.showToast(context, "Limit Reached", ToastificationType.error, "You have reached the maximum limit for sending the dinnerq menu for today.");
                                      }
                                      else{
                                        List<String> numbers = selectedCustomers
                                            .map((customer) =>
                                            customer["Mobile"].toString())
                                            .toList();
                                        sendSMS(_menu.text, numbers);
                                      }
                                    } else if (_menu.text.isEmpty &&
                                        selectedMeal == "null") {
                                      ToastUtil.showToast(
                                          context,
                                          "Error",
                                          ToastificationType.error,
                                          "Please fill all required fields.");
                                    } else if (selectedMeal == "null") {
                                      ToastUtil.showToast(
                                          context,
                                          "Meal",
                                          ToastificationType.error,
                                          "Please select meal type.");
                                    } else if (_menu.text.isEmpty) {
                                      ToastUtil.showToast(
                                          context,
                                          "Message",
                                          ToastificationType.error,
                                          "Please enter the menu.");
                                    } else {
                                      ToastUtil.showToast(
                                          context,
                                          "Customers",
                                          ToastificationType.error,
                                          "Please select customers to send menu.");
                                    }
                                  },
                                  child: Opacity(
                                    opacity: 1,
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          top: 20,
                                          bottom: 20),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.send, color: dark? primaryColor : black),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Select All Customers",
                                  style: GoogleFonts.barlow(
                                    textStyle: TextStyle(
                                      color: dark ? white : darkPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Checkbox(
                                  activeColor: Colors.green,
                                  value: selectAll,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      selectAll = value!;
                                      selectedCustomers =
                                          selectAll ? List.from(customers) : [];
                                    });
                                  },
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  bottom: kBottomNavigationBarHeight),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: dark ? white : Colors.grey.shade50,
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: customers.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                      customers[index]["Name"],
                                      style: GoogleFonts.barlow(
                                        textStyle: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    subtitle: Text(
                                      customers[index]["Mobile"],
                                      style: GoogleFonts.barlow(
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    trailing: Checkbox(
                                      activeColor: Colors.green,
                                      value: selectedCustomers
                                          .contains(customers[index]),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            selectedCustomers
                                                .add(customers[index]);
                                          } else {
                                            selectedCustomers
                                                .remove(customers[index]);
                                          }
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : null,
          );
  }
}

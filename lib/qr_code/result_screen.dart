import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/FetchData/FetchClientData.dart';

import 'package:myapp/qr_code/qr_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ResultScreen extends StatefulWidget {
  final String code;

  ResultScreen({super.key, required this.code});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String myDocID = "";
  String error = "";
  String User_ID = "";
  TextEditingController _editingController = TextEditingController();
  final FirebaseAuth _authUser = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  String available_S = "";
  String val = "";
  final formKey = GlobalKey<FormState>();
  Future<MyData?>? _dataFuture;
  final DateTime now = DateTime.now();
  String CurrAval = "";
  String user_name = "";
  String officer_ID = "";
  final valueRegex = RegExp(r'^[0-9]+$');
  double enteredVal = 0;
  bool currentApprove = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dataFuture = fetchData(widget.code);
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Qr_scanner(),
              ),
            );
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Center(
          child: Text(
            "QR Scanner",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 6, 251, 165),
      ),
      body: FutureBuilder<MyData?>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "This is not a valid QR Code",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            );
          }

          if (snapshot.hasData &&
              snapshot.data != null &&
              currentApprove == true) {
            final data = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.0),
                        color: const Color.fromARGB(255, 129, 205, 241),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 20),
                          Text(
                            "Email : ${data.Email}",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Full Name : ${data.Full_Name}",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Address : ${data.Address}",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Mobile : ${data.mobile}",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "NIC : ${data.NIC}",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Daily Quota : ${data.DailyQuota}",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Available : ${data.Available}",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: 400,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.0),
                      color: Color.fromARGB(255, 199, 248, 144),
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _editingController,
                              decoration: InputDecoration(
                                labelText: "Enter Amount",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return "Enter a value";
                                }
                                if (!valueRegex.hasMatch(value)) {
                                  return "Not a valid number";
                                }
                                enteredVal = double.parse(value!);
                                if (enteredVal > 100) {
                                  return "The maximum limit is 100 liters";
                                }
                                if (enteredVal <= 0) {
                                  return "The entered value is not valid";
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                val = newValue!;
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "${error}",
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Colors.lightBlueAccent),
                            ),
                            onPressed: () async {
                              if (formKey.currentState!.validate() == false) {
                                return;
                              }

                              formKey.currentState!.save();

                              try {
                                double available_D = double.parse(val);

                                double dailyQuota_D =
                                    double.parse(data.DailyQuota);
                                if (dailyQuota_D >= available_D) {
                                  await fetchAvailableData();
                                  double currAval_d = double.parse(CurrAval);
                                  double newAval = currAval_d - available_D;

                                  if (dailyQuota_D >= newAval && newAval >= 0) {
                                    String newAval_String = newAval.toString();
                                    setState(() {
                                      User_ID = data.User_id;
                                      user_name = data.Full_Name;
                                    });
                                    //here
                                    await addScannedTime();
                                    await updateUsererAvailable(newAval_String);
                                    await addWaterUsage();
                                    Fluttertoast.showToast(
                                      msg: "Successfully Updated!",
                                      toastLength: Toast.LENGTH_SHORT,
                                    );
                                    //here

                                    setState(() {
                                      error = "";
                                    });
                                  } else {
                                    setState(() {
                                      error = "No enough water";
                                    });
                                  }
                                } else {
                                  setState(() {
                                    error = "Your Dily Quota is Full";
                                  });
                                }
                              } catch (e) {
                                Text(
                                  "Something went wrong!.",
                                  style: TextStyle(color: Colors.red),
                                );
                              }
                            },
                            child: Text(
                              "Enter",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  const Color.fromARGB(255, 219, 227, 231)),
                            ),
                            onPressed: () {
                              setState(() {
                                _editingController.clear();
                              });
                            },
                            child: Text(
                              "Clear",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: Text(
              "This QR code is not valid",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<MyData?> fetchData(String docID) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('User').doc(docID);
      final snapshot = await docRef.get();

      setState(() {
        myDocID = docID;
      });

      if (snapshot.exists) {
        setState(() {
          currentApprove = snapshot.data()!["Approve"];
        });
        return MyData(
          User_id: snapshot.data()!["User_id"],
          Email: snapshot.data()!["Email"],
          Full_Name: snapshot.data()!["User name"],
          mobile: snapshot.data()!["Mobile"],
          NIC: snapshot.data()!["NIC"],
          Address: snapshot.data()!["Address"],
          DailyQuota: snapshot.data()!["Daily Quota"],
          Available: snapshot.data()!["Available"],
          approvation: snapshot.data()!["Approve"],
        );
      } else {
        //return null;
        Text(
          "This QR code is not valid.",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        );
      }
    } catch (e) {
      Text("Please scan a valid QR");
    }
  }

  Future<void> updateUsererAvailable(String newAvailable) async {
    //User? user1 = _authUser.currentUser;
    try {
      try {
        final docRef =
            _firebaseFirestore.collection('User').doc(myDocID); //user1?.uid

        await docRef.update({
          "Available": newAvailable,
        });

        print("Updated successfully");
      } on FirebaseException catch (e) {
        print("Your Update Error is ${e.toString()}");
      }
    } catch (e) {
      print("Error is :" + e.toString());
    }
  }

  Future<void> fetchAvailableData() async {
    User? currentUser = _authUser.currentUser;

    if (currentUser != null) {
      DocumentSnapshot driverData =
          await _firebaseFirestore.collection('User').doc(myDocID).get();

      if (driverData.exists) {
        Map<String, dynamic> myData = driverData.data() as Map<String, dynamic>;
        setState(() {
          CurrAval = myData["Available"] ?? '';
        });
      } else
        print("No User Logged In.");
    }
  }

  Future<void> addWaterUsage() async {
    final CollectionReference waterUsageCollection =
        _firebaseFirestore.collection('water_usage');

    // Get current date and time in desired format

    final Map<String, String> waterUsageData = {
      'User_id': User_ID, // Ensure userId is not null before adding
      'Date': date(),
      'Time': time(),
      'Amount': val,
    };

    await waterUsageCollection.add(waterUsageData);

    // Clear the amount field after successful addition (optional)

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Water usage data added successfully!'),
      ),
    );
  }

  String time() {
    String formattedTime = now.toString().substring(11, 16);
    return formattedTime;
  }

  String date() {
    String formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    return formattedDate;
  }

  Future<void> fetchUserData() async {
    User? currentUser = _authUser.currentUser;

    if (currentUser != null) {
      DocumentSnapshot driverData = await _firebaseFirestore
          .collection('Officer')
          .doc(currentUser!.uid)
          .get();

      if (driverData.exists) {
        print("Existing data in the document");
        Map<String, dynamic> myData = driverData.data() as Map<String, dynamic>;
        setState(() {
          officer_ID = myData["Officer_id"] ?? '';
        });
      } else
        print("No User Logged In.");
    }
  }

  Future<void> addScannedTime() async {
    final CollectionReference scannedHistory =
        _firebaseFirestore.collection('scan_history');
    final Map<String, String> addScanningHistory = {
      "Officer_id": officer_ID,
      "User_id": User_ID,
      "User_name": user_name,
      "Date": date(),
      "Time": time(),
    };

    await scannedHistory.add(addScanningHistory);
  }
}

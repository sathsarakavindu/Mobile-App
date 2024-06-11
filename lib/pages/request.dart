import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Request extends StatefulWidget {
  const Request({super.key});

  @override
  State<Request> createState() => _RequestState();
}

class _RequestState extends State<Request> {
  DateTime nowTime = DateTime.now();
  String u_id = "";
  String u_name = "";
  String u_address = "";
  String u_available = "";
  String requestStatement = "";
  bool dataFetched = false;
  final formKeyRequest = GlobalKey<FormState>();
  String err = "";

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchUserData() async {
    User? currUser = _auth.currentUser;
    if (currUser == null) {
      print("No User Logged iN");
      return;
    } else {
      print("There is a user");

      DocumentSnapshot user_data =
          await _firestore.collection('User').doc(currUser!.uid).get();

      if (user_data.exists) {
        print("Don't be afraid. The data are available.");
        Map<String, dynamic> myData = user_data.data() as Map<String, dynamic>;
        setState(() {
          u_id = myData["User_id"] ?? '';
          u_name = myData["User name"] ?? '';
          u_address = myData["Address"] ?? '';
          u_available = myData["Available"] ?? '';
          dataFetched = true;

          print(u_id);
          print(u_name);
          print(u_address);
          print(u_available);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
        title: Text(
          "Requests",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 70),
                Container(
                  width: 370,
                  height: 500,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Color.fromARGB(255, 154, 236, 242)),
                  child: Form(
                    key: formKeyRequest,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Make Your Request...",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 50),
                        Icon(
                          Icons.request_quote,
                          size: 70,
                        ),
                        SizedBox(height: 50),
                        SizedBox(
                          width: 350,
                          height: 110,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Enter your Requests Here..",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            minLines: 1,
                            maxLines: 4,
                            validator: (String? value) {
                              if (value != null) {
                                if (value.isEmpty) {
                                  return "Enter Request";
                                }
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              this.requestStatement = newValue!;
                            },
                          ),
                        ),
                        SizedBox(height: 40),
                        Text(
                          "${err}",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.red,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (formKeyRequest.currentState!.validate() ==
                                  false) {
                                return;
                              }
                              formKeyRequest.currentState!.save();

                              await fetchUserData();
                              double u_available_d = double.parse(u_available);

                              if (u_available_d > 5) {
                                setState(() {
                                  err =
                                      "The availability must be low than 5 Liters for making requsets";
                                });
                                return;
                              }
                              String formattedTime =
                                  nowTime.toString().substring(11, 16);
                              DateTime now = DateTime.now();
                              String formattedDate =
                                  "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

                              String id1 = generateCustomID(4);

                              try {
                                Map<String, dynamic> myReqData = {
                                  "Request_id": id1,
                                  "User_id": u_id,
                                  "User_name": u_name,
                                  "Is_Approved": false,
                                  "Statement": requestStatement,
                                  "Time": formattedTime,
                                  "Date": formattedDate,
                                  "Address": u_address,
                                };

                                await _firestore
                                    .collection('Request')
                                    .add(myReqData);

                                Fluttertoast.showToast(
                                  msg: "Your Request Successfully Sent..!",
                                  toastLength: Toast
                                      .LENGTH_SHORT, // Duration of the toast
                                );
                                Navigator.of(context).pop();
                              } on FirebaseException catch (e) {
                                print("Error : ${e.toString()}");
                              }
                            },
                            icon: Icon(
                              Icons.request_quote_sharp,
                              weight: 1000,
                            ),
                            label: Text(
                              "Make Request",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
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

  String generateCustomID(int length) {
    const chars = 'Re1234567890';
    Random random = Random();
    String uniqueID = String.fromCharCodes(List.generate(
        length, (index) => chars.codeUnitAt(random.nextInt(chars.length))));
    return uniqueID;
  }
}

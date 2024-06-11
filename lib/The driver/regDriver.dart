import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/The%20driver/driverDash.dart';
import 'package:myapp/The%20driver/loginDriver.dart';
import 'package:myapp/firebase_auth/firebase_auth_services.dart';
import 'package:myapp/login_and_register/customTextFormField.dart';
import 'package:myapp/pages/waitingPage.dart';

class regDriver extends StatefulWidget {
  const regDriver({super.key});

  @override
  State<regDriver> createState() => _regDriverState();
}

class _regDriverState extends State<regDriver> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String EPFNo = "";
  String driverName = "";
  String driverMail = "";
  String driverPassword = "";
  String driverContact = "";
  String driverAddress = "";
  String NIC = "";
  String confirmError = "";

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  final contactNumberRegex = RegExp(
    r'^[0-9]{10}$',
  );
  final RegExp nameExp = RegExp(r'^[a-zA-Z\s]+$');
  final epfNoRegex = RegExp(
    r'^[0-9]+$',
  );
  final formKeyDriver = GlobalKey<FormState>();

  bool _obscureText = true;

  void changeVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 244, 244, 247),
      body: SingleChildScrollView(
        child: Form(
          key: formKeyDriver,
          child: Column(
            children: [
              Container(
                height: 270,
                width: 390,
                color: Colors.tealAccent,
                child: Container(
                  padding: EdgeInsets.only(top: 40),
                  child: Column(
                    children: [
                      Text(
                        "Driver Registration",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Image.asset(
                        "assets/images/delivery.jpg",
                        height: 100,
                        width: 200,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Enter EPF",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Enter Your EPF No";
                    } else {
                      if (!epfNoRegex.hasMatch(value)) {
                        return "Please Enter the Valid EPF No";
                      }
                    }
                    return null;
                  },
                  onSaved: (String? value) {
                    this.EPFNo = value!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Enter Your Full Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Enter Your Name";
                    } else {
                      if (!nameExp.hasMatch(value)) {
                        return "Please Enter a Valid Name";
                      }
                    }
                    return null;
                  },
                  onSaved: (String? value) {
                    this.driverName = value!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Enter Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Enter Your Email";
                    }
                    if (!emailRegex.hasMatch(value)) {
                      return "Please Enter a Valid Email";
                    }

                    return null;
                  },
                  onSaved: (String? value) {
                    this.driverMail = value!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: "Enter Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    suffixIcon: IconButton(
                      onPressed: changeVisibility,
                      icon: Icon(_obscureText
                          ? Icons.visibility_off
                          : Icons.visibility),
                    ),
                  ),
                  obscureText: _obscureText,
                  validator: (String? value) {
                    if (value != null) {
                      if (value.isEmpty) {
                        return "Enter valid passwrod";
                      }
                    }
                    return null;
                  },
                  onSaved: (String? value) {
                    this.driverPassword = value!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  obscureText: _obscureText,
                  validator: (String? value) {
                    if (value != null) {
                      if (value.isEmpty) {
                        return "Re-Enter passwrod";
                      }
                    }
                    return null;
                  },
                  onSaved: (String? value) {
                    this.driverPassword = value!;
                  },
                ),
              ),
              Text(
                "${confirmError}",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Enter Contact No",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Enter Contact Number";
                    }
                    if (!contactNumberRegex.hasMatch(value)) {
                      return "Please Enter a Valid Mobile No";
                    }

                    return null;
                  },
                  onSaved: (String? value) {
                    this.driverContact = value!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Enter Address",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  validator: (String? value) {
                    if (value != null) {
                      if (value.isEmpty) {
                        return "Enter Address";
                      }
                    }
                    return null;
                  },
                  onSaved: (String? value) {
                    this.driverAddress = value!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Enter NIC",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  validator: (String? value) {
                    if (value != null) {
                      if (value.isEmpty) {
                        return "Enter NIC";
                      }
                    }
                    return null;
                  },
                  onSaved: (String? value) {
                    this.NIC = value!;
                  },
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Container(
                height: 60,
                width: 200,
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.tealAccent)),
                  onPressed: () async {
                    if (formKeyDriver.currentState!.validate() == false) {
                      return;
                    }
                    formKeyDriver.currentState!.save();
                    if (confirmPassword() == false) {
                      return;
                    }
                    generateCustomIDForDriver(4);
                    String uniqueID = generateCustomIDForDriver(4);

                    try {
                      UserCredential regDriver =
                          await _auth.createUserWithEmailAndPassword(
                              email: driverMail, password: driverPassword);

                      String docIdDriver = regDriver.user!.uid;

                      GeoPoint location = GeoPoint(37.00, -122.00);

                      Map<String, dynamic> driverData = {
                        "Driver_id": uniqueID,
                        "EPF": EPFNo,
                        "Driver_name": driverName,
                        "Email": driverMail,
                        "Password": driverPassword,
                        "Mobile": driverContact,
                        "Address": driverAddress,
                        "NIC": NIC,
                        "Approve": false,
                        "Location": location,
                      };

                      await _firestore
                          .collection('Driver')
                          .doc(docIdDriver)
                          .set(driverData);

                      Navigator.of(context).pop();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WaitingPage(),
                        ),
                      );
                    } on FirebaseException catch (e) {
                      print(e.toString());
                    }
                  },
                  child: Text(
                    "Register",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                height: 60,
                width: 200,
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.lightBlueAccent)),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => driverLogin()));
                  },
                  child: Text(
                    "Back",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String generateCustomIDForDriver(int length) {
    const chars = 'D0123456789';
    Random random = Random();
    String uniqueID = String.fromCharCodes(List.generate(
        length, (index) => chars.codeUnitAt(random.nextInt(chars.length))));
    return uniqueID;
  }

  confirmPassword() {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        confirmError = "Password do not match";
      });
      return false;
    }
  }
}

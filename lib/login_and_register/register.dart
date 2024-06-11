import 'dart:ffi';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:myapp/firebase_auth/firebase_auth_services.dart';
import 'package:myapp/login_and_register/customTextFormField.dart';
import 'package:myapp/login_and_register/login.dart';
import 'package:myapp/pages/waitingPage.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String fname = "";
  String mail = "";
  String newMail = "";
  String newPassword = "";
  String pswrd = "";
  String no = "";
  String adrs = "";
  String nic = "";
  String? errorMsg = "";
  String doc1 = "";

  String confirmError = "";

  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  // final emailRegex = RegExp(
  //     r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  final emailRegex = RegExp(
    r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}$',
  );
  final contactNumberRegex = RegExp(
    r'^[0-9]{10}$',
  );
  final RegExp nameExp = RegExp(r'^[a-zA-Z\s]+$');
  final myFormKey = GlobalKey<FormState>();

  bool _obscureText = true;

  void showPassword() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: content(),
    );
  }

  Widget content() {
    return SingleChildScrollView(
      child: Form(
        key: myFormKey,
        child: Column(
          children: [
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.tealAccent,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.elliptical(80, 80),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Image.asset("assets/images/waterDrop.jpg"),
                  ),
                  Text(
                    "Register",
                    style: TextStyle(
                        fontSize: 30,
                        color: const Color.fromRGBO(0, 0, 0, 1),
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: "Enter Full Name",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0)),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Enter Your Name";
                  }
                  if (!nameExp.hasMatch(value)) {
                    return "Please Enter a Valid Name";
                  }

                  return null;
                },
                onSaved: (String? value) {
                  this.fname = value!;
                },
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: "Enter Email",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0)),
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
                  this.mail = value!;
                },
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Enter Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  suffixIcon: IconButton(
                    onPressed: showPassword,
                    icon: Icon(_obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility),
                  ),
                ),
                obscureText: _obscureText,
                validator: (String? value) {
                  if (value != null) {
                    if (value.isEmpty) {
                      return "Enter Valid Password";
                    }
                  }
                  return null;
                },
                onSaved: (String? value) {
                  this.pswrd = value!;
                },
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _confirmController,
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
                      return "Re-Enter Password";
                    }
                  }
                  return null;
                },
                onSaved: (String? value) {
                  this.pswrd = value!;
                },
              ),
            ),
            Text(
              "${confirmError}",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Enter Contact Number",
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
                  this.no = value!; // do trim();
                },
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(8.0),
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
                      return "Enter Valid Address";
                    }
                  }
                  return null;
                },
                onSaved: (String? value) {
                  this.adrs = value!;
                },
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
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
                      return "Enter Valid NIC";
                    }
                  }
                },
                onSaved: (String? value) {
                  this.nic = value!;
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 60,
              width: 180,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.tealAccent),
                ),
                onPressed: () async {
                  if (myFormKey.currentState!.validate() == false) {
                    return;
                  }
                  myFormKey.currentState!.save();

                  if (confirmPassword() == false) {
                    return;
                  }

                  try {
                    String userID = generateCustomID(4);

                    UserCredential userCredential =
                        await _auth.createUserWithEmailAndPassword(
                            email: mail, password: pswrd);

                    String docIDUser = userCredential.user!.uid;

                    String dailyQ = await getDailyQuotaValue();
                    GeoPoint location = GeoPoint(37.00, -122.00);

                    Map<String, dynamic> myUserData = {
                      "User_id": userID,
                      "Approve": false,
                      "User name": fname,
                      "Email": mail,
                      "Password": pswrd,
                      "Address": adrs,
                      "Mobile": no,
                      "NIC": nic,
                      "Daily Quota": dailyQ,
                      "Available": dailyQ,
                      "Location": location,
                    };

                    await _firestore
                        .collection('User')
                        .doc(docIDUser)
                        .set(myUserData);
                  } on FirebaseException catch (e) {
                    print("Your error is ${e.toString()}");
                  }
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WaitingPage(),
                    ),
                  );
                },
                child: Text(
                  "Register",
                  style: TextStyle(
                      fontSize: 25,
                      color: Color.fromARGB(255, 1, 0, 2),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 60,
              width: 180,
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.lightBlueAccent)),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Login()));
                },
                child: Text(
                  "Back",
                  style: TextStyle(
                      fontSize: 25,
                      color: Color.fromARGB(255, 1, 0, 2),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  String generateCustomID(int length) {
    const chars = 'Us1234567890';
    Random random = Random();
    String uniqueID = String.fromCharCodes(List.generate(
        length, (index) => chars.codeUnitAt(random.nextInt(chars.length))));
    return uniqueID;
  }

  Future<String> getDailyQuotaValue() async {
    String dailyVal = "";

    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('Daily_Quota').get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs[0];
        dailyVal = documentSnapshot['Daily Quota'] ?? '';
      }
    } catch (e) {
      print('Error getting daily quota value ${e.toString()}');
    }
    return dailyVal;
  }

  confirmPassword() {
    if (_passwordController.text != _confirmController.text) {
      setState(() {
        confirmError = "Password do not match";
      });
      return false;
    }
  }
}

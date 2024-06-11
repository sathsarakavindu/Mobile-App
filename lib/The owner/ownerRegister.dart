import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/The%20owner/ownerLogin.dart';
import 'package:myapp/firebase_auth/firebase_auth_services.dart';
import 'package:myapp/login_and_register/customTextFormField.dart';
import 'package:myapp/pages/waitingPage.dart';
import 'package:myapp/qr_code/qr_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OwnerRegister extends StatefulWidget {
  const OwnerRegister({super.key});

  @override
  State<OwnerRegister> createState() => _OwnerRegisterState();
}

class _OwnerRegisterState extends State<OwnerRegister> {
  String company = "";
  String serviceNo = "";
  String ownerFname = "";
  String ownerMail = "";
  String ownerPassword = "";
  String contact = "";
  String ownerAddress = "";
  String nic = "";
  bool _obscureText = true;
  String errorConfirm = "";

  final _confirmPassword = TextEditingController();
  final _passwordController = TextEditingController();

  void changeVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  final emailRegex = RegExp(r"^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$");

  final contactNumberRegex = RegExp(
    r'^[0-9]{10}$',
  );
  final RegExp nameExp = RegExp(r'^[a-zA-Z\s]+$');
  final epfNoRegex = RegExp(
    r'^[0-9]+$',
  );

  final formKeyOwner = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 249, 248, 251),
      body: SingleChildScrollView(
        child: Form(
          key: formKeyOwner,
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
                        "Officer Registration",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Image.asset(
                        "assets/images/waterLogo1.jpg",
                        height: 100,
                        width: 200,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Enter EPF No",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Enter service number";
                    }
                    if (!epfNoRegex.hasMatch(value)) {
                      return "Enter a Valid EPF No";
                    }
                    return null;
                  },
                  onSaved: (String? value) {
                    this.serviceNo = value!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Enter Full Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Enter Full Name";
                    }
                    if (!nameExp.hasMatch(value)) {
                      return "Enter a Valid Name";
                    }
                    return null;
                  },
                  onSaved: (String? value) {
                    this.ownerFname = value!;
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
                      return "Enter Email";
                    }
                    if (!emailRegex.hasMatch(value)) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                  onSaved: (String? value) {
                    this.ownerMail = value!;
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
                    this.ownerPassword = value!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  controller: _confirmPassword,
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
                    this.ownerPassword = value!;
                  },
                ),
              ),
              Text(
                errorConfirm,
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Enter Your Contact No",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Enter Contact No";
                    }
                    if (!contactNumberRegex.hasMatch(value)) {
                      return "Enter a valid contact no";
                    }
                    return null;
                  },
                  onSaved: (String? value) {
                    this.contact = value!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Enter Valid Address",
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
                    this.ownerAddress = value!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Enter NIC",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0)),
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
                    this.nic = value!;
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
                    if (formKeyOwner.currentState!.validate() == false) {
                      return;
                    }
                    formKeyOwner.currentState!.save();

                    if (confirmPassword() == false) {
                      return;
                    }

                    try {
                      String officerID = generateCustomIDForOfficer(4);

                      UserCredential officerCredential =
                          await _auth.createUserWithEmailAndPassword(
                              email: ownerMail, password: ownerPassword);

                      String officerDocId = officerCredential.user!.uid;

                      Map<String, dynamic> ownerData = {
                        "Officer_id": officerID,
                        "EPF": serviceNo,
                        "Officer_name": ownerFname,
                        "Email": ownerMail,
                        "Password": ownerPassword,
                        "Mobile": contact,
                        "Address": ownerAddress,
                        "NIC": nic,
                        "Approve": false,
                      };

                      await _firebaseFirestore
                          .collection("Officer")
                          .doc(officerDocId)
                          .set(ownerData);

                      print(
                          "Authentication ID is replaced as the Document ID.");

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
                        MaterialPageRoute(builder: (context) => ownerLogin()));
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

  String generateCustomIDForOfficer(int length) {
    const chars = 'Off0123456789';
    Random random = Random();
    String uniqueID = String.fromCharCodes(List.generate(
        length, (index) => chars.codeUnitAt(random.nextInt(chars.length))));
    return uniqueID;
  }

  confirmPassword() {
    if (_passwordController.text != _confirmPassword.text) {
      setState(() {
        errorConfirm = "Password do not match";
      });
      return false;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:myapp/The%20driver/driverDash.dart';
import 'package:myapp/The%20driver/forgotDriverPassword.dart';
import 'package:myapp/The%20driver/regDriver.dart';
import 'package:myapp/The%20owner/ownerRegister.dart';
import 'package:myapp/firebase_auth/firebase_auth_services.dart';
import 'package:myapp/login_and_register/customTextFormField.dart';
import 'package:myapp/login_and_register/login.dart';
import 'package:myapp/pages/waitingPage.dart';
import 'package:myapp/qr_code/qr_scanner.dart';

class driverLogin extends StatefulWidget {
  const driverLogin({super.key});

  @override
  State<driverLogin> createState() => _driverLoginState();
}

class _driverLoginState extends State<driverLogin> {
  bool _obscureText = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void changeVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  final formKeyD = GlobalKey<FormState>();
  String driverEmail = "";
  String driverPassword = "";
  String? errorMsgD = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Login()));
            },
            icon: Icon(Icons.arrow_back_ios_new)),
        backgroundColor: const Color.fromARGB(255, 117, 162, 239),
        centerTitle: true,
        title: Text(
          "Driver",
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Form(
              key: formKeyD,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(60, 50, 50, 10),
                    child: Image.asset("assets/images/delivery.jpg"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Enter Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                        ),
                        validator: (String? value) {
                          if (value != null) {
                            if (value.isEmpty) {
                              return "Enter Your Email";
                            }
                          }
                          return null;
                        },
                        onSaved: (String? value) {
                          this.driverEmail = value!;
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
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
                              return "Enter Valid Password";
                            }
                          }
                          return null;
                        },
                        onSaved: (String? value) {
                          this.driverPassword = value!;
                        }),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "${errorMsgD}",
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RichText(
                    text: TextSpan(
                        text: "Forgot Password",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color.fromARGB(255, 146, 95, 228),
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotDriverPassword(),
                              ),
                            );
                          }),
                  ),
                  SizedBox(height: 30),
                  Container(
                    height: 60,
                    width: 300,
                    decoration: BoxDecoration(
                      //color: Colors.tealAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blue),
                      ),
                      onPressed: () async {
                        try {
                          await updateLocation();
                        } on FirebaseAuthException catch (err) {
                          setState(() {
                            //errorMsgD = err.message;
                            errorMsgD = "Invalid Email or Password";
                          });
                          print(errorMsgD);
                        }
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 249, 249, 251),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  RichText(
                    text: TextSpan(
                        text: "Create Account",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.orangeAccent[700],
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => regDriver(),
                              ),
                            );
                          }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> isEmailAvailable(String email) async {
    final querySnapshot = await _firestore
        .collection('Driver')
        .where('Email', isEqualTo: email)
        .get();

    final documents = querySnapshot.docs;
    return documents
        .isEmpty; // True if no documents found (email doesn't exist)
  }

  Future<void> updateLocation() async {
    try {
      bool permissionGranted = await _handleLocationPermission();
      if (!permissionGranted) {
        print('Location permission not granted');
        return;
      }

      Position? position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (position == null) {
        print('Failed to get current position');
        return;
      }
      GeoPoint location = GeoPoint(position.latitude, position.longitude);

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      //26/05/2024
      await _firestore
          .collection('Driver')
          .doc(userCredential.user?.uid)
          .update({
        'Password': _passwordController.text.trim(),
      });

      //end

      //29/05/2024
      DocumentSnapshot userSnapshot = await _firestore
          .collection('Driver')
          .doc(userCredential.user!.uid)
          .get();

      bool isApproved = await userSnapshot.get('Approve');

      if (isApproved) {
        print("Driver apprve is true");
        if (userCredential.user != null) {
          await _firestore
              .collection('Driver')
              .doc(userCredential.user!.uid)
              .update({
            'Location': location,
          });
          print('Location updated successfully');
        } else {
          print('Failed to update location');
        }
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => driverDash(),
          ),
        );
      } else {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WaitingPage(),
          ),
        );
      }

      //end
    } catch (e) {
      Text("Error is: ${e.toString()}");
      setState(() {
        // errorMsgD = e.toString();
        errorMsgD = "Invalid Email or Password";
      });
    }
  }

  Future<bool> _handleLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }
}

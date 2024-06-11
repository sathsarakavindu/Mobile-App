import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:myapp/The%20owner/ForgotOfficerPassword.dart';
import 'package:myapp/The%20owner/ownerRegister.dart';
import 'package:myapp/firebase_auth/firebase_auth_services.dart';
import 'package:myapp/login_and_register/customTextFormField.dart';
import 'package:myapp/login_and_register/login.dart';
import 'package:myapp/pages/waitingPage.dart';
import 'package:myapp/qr_code/qr_scanner.dart';

class ownerLogin extends StatefulWidget {
  const ownerLogin({super.key});

  @override
  State<ownerLogin> createState() => _ownerLoginState();
}

class _ownerLoginState extends State<ownerLogin> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _obscureText = true;

  final formKey = GlobalKey<FormState>();
  String ownerEmail = "";
  String ownerPassword = "";
  String? errorMsg = "";

  void changeVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

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
          "The officer",
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(60, 50, 50, 10),
                    child: Image.asset("assets/images/waterDrop.jpg"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
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
                          this.ownerEmail = value!;
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
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
                          this.ownerPassword = value!;
                        }),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "${errorMsg}",
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
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
                                builder: (context) => ForgotOfficerPassword(),
                              ),
                            );
                          }),
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 60,
                    width: 180,
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
                          if (formKey.currentState!.validate() == false) {
                            return;
                          }

                          formKey.currentState!.save();
                          await _signIn();
                        } on FirebaseAuthException catch (err) {
                          setState(() {
                            errorMsg = "Invalid Email or Password";
                          });
                          print(errorMsg);
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
                    height: 20,
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
                                    builder: (context) => OwnerRegister()));
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

  Future<void> _signIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: ownerEmail,
        password: ownerPassword,
      );
//26/05/2024
      await _firestore
          .collection('Officer')
          .doc(userCredential.user?.uid)
          .update({
        'Password': ownerPassword,
      });
      //end
//del
      User? user = userCredential.user;
      if (user != null) {
        // Navigate to the next screen or perform other actions
      }
//end.....

      // Check if user exists and is approved
      DocumentSnapshot userSnapshot = await _firestore
          .collection('Officer')
          .doc(userCredential.user!.uid)
          .get();

      bool isApproved = userSnapshot.get('Approve');

      if (isApproved) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Qr_scanner(),
          ),
        );

        print("Approve is True");
      } else {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WaitingPage(),
          ),
        );
        print("This officer account hasn't been approved yet.");
      }
    } catch (e) {
      setState(() {
        errorMsg = "Invalid Email or Password";
      });
    }
  }
}

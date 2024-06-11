import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/The%20driver/loginDriver.dart';

class ForgotDriverPassword extends StatefulWidget {
  const ForgotDriverPassword({super.key});

  @override
  State<ForgotDriverPassword> createState() => _ForgotDriverPasswordState();
}

class _ForgotDriverPasswordState extends State<ForgotDriverPassword> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String error = "";
  final formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String newMail = "";
  final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 149, 206, 253),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => driverLogin(),
                  ),
                );
              },
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                weight: 1000,
              ),
            ),
            SizedBox(width: 10),
            Text(
              "Back",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Receive an email to reset your password.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: 370,
                child: TextFormField(
                  controller: _emailController,
                  cursorColor: Colors.white,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (String? value) {
                    if (value != null) {
                      if (emailRegex.hasMatch(value) == false) {
                        return "Enter Valid Email";
                      }
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    newMail = newValue!;
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "${error}",
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 50),
              SizedBox(
                width: 260,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (formKey.currentState!.validate() == false) {
                      return;
                    }

                    formKey.currentState!.save();

                    if (await checkEmailExists(newMail) == true) {
                      await _resetPassword();
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => driverLogin(),
                        ),
                      );
                    } else {
                      setState(() {
                        error = "There isn't an account from this email.";
                      });
                    }
                  },
                  icon: Icon(Icons.mail),
                  label: Text(
                    "Reset Password",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resetPassword() async {
    try {
      // Send password reset email
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());

      User? user = _auth.currentUser;
      String? newPassword = user?.email ?? '';

      // Show success message
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Success'),
          content: Text('Password reset email sent.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );

      // Get the new password from Firebase Authentication
    } catch (e) {
      // Show error message
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to reset password. ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Driver')
          .where('Email', isEqualTo: email)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking email existence: $e');
      return false;
    }
  }
}

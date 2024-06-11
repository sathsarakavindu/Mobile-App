import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:myapp/The%20driver/loginDriver.dart';
import 'package:myapp/The%20driver/regDriver.dart';
import 'package:myapp/The%20owner/ownerLogin.dart';
import 'package:myapp/firebase_auth/firebase_auth_services.dart';
import 'package:myapp/login_and_register/ForgotUserPassword.dart';
import 'package:myapp/login_and_register/customTextFormField.dart';
import 'package:myapp/login_and_register/register.dart';
import 'package:myapp/pages/dashboard.dart';
import 'package:myapp/pages/waitingPage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // final mailController = TextEditingController();
  // final passController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _message = '';

  String newMail = "";
  String newPassword = "";

  String? err = "";
  String newDocReturn = "";
  final formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SingleChildScrollView(
          child: Content(),
        ),
      ),
    );
  }

  Widget Content() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.tealAccent,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.elliptical(80, 80),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Image.asset(
                "assets/images/waterDrop.jpg",
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "User Login",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 40,
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
                      return "Enter Email";
                    }
                  }
                  return null;
                },
                onSaved: (String? value) {
                  this.newMail = value!;
                }),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: "Enter Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                suffixIcon: IconButton(
                  onPressed: _togglePasswordVisibility,
                  icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility),
                ),
              ),
              validator: (String? value) {
                if (value != null) {
                  if (value.isEmpty) {
                    return "Enter Password";
                  }
                }
                return null;
              },
              onSaved: ((newValue) {
                newPassword = newValue!;
              }),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Container(
            child: Text(
              "${err}",
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),
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
                        builder: (context) => ForgotUserPassword(),
                      ),
                    );
                  }),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            height: 60,
            width: 180,
            decoration: BoxDecoration(
              //color: Colors.tealAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                      Color.fromARGB(255, 85, 196, 248))),
              onPressed: () async {
                await _loginUser();
                // await FirebaseAppCheck.instance.activate(
                //   webProvider: ReCaptchaV3Provider(
                //     '6LdDSugpAAAAAB8cg_TxcwbLu8U_60IrgkW9zPMJ', // Replace with your actual site key
                //   ),
                //   androidProvider: AndroidProvider.playIntegrity,
                // );
              },
              child: Text(
                "Login",
                style: TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Don't have an account ?   ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.grey[850],
                  ),
                ),
                TextSpan(
                    text: "Register",
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
                                builder: (context) => Register()));
                      }),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "As an Officer ? ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: const Color.fromARGB(255, 17, 15, 15),
                  ),
                ),
                TextSpan(
                  text: "   The Officer",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ownerLogin(),
                        ),
                      );
                    },
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "As a Driver ?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: const Color.fromARGB(255, 17, 15, 15),
                  ),
                ),
                TextSpan(
                  text: "    The Driver",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.orange,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => driverLogin()));
                    },
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

// login user
  _loginUser() async {
    setState(() {
      err = "";
    });

    if (formKey.currentState!.validate() == false) {
      return;
    }

    print("Validation is passed");
    formKey.currentState!.save();

    try {
      
      await _signIn();
      
    } on FirebaseAuthException catch (er) {
      setState(() {
        //err = er.message;
        err = "Invalid Email or Password";
      });
    }
  }

  Future<void> getUserDocumentID() async { // for getting user document id of firestore table this method is used
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
            .collection('User')
            .where('Email', isEqualTo: newMail)
            .where('Password', isEqualTo: newPassword)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          String documentID = querySnapshot.docs[0].id;
          print("I was printed");
          setState(() {
            newDocReturn = documentID;
          });
          print("User Document id : ${newDocReturn}");
        } else {
          print("User document not found");
        }
      } else {
        print("Kavindu, User is null");
      }
    } catch (e) {
      print("Your error is : ${e}");
    }
  }

  Future<void> _signIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: newMail,
        password: newPassword,
      );
//26/05/2024 updated code
      await _firestore.collection('User').doc(userCredential.user?.uid).update({
        'Password': newPassword,
      });
      //end
//del
      User? user = userCredential.user;
      if (user != null) {
        await _updateAvailableField(user.uid);
        // Navigate to the next screen or perform other actions
      }
//end.....

      // Check if user exists and is approved
      DocumentSnapshot userSnapshot = await _firestore
          .collection('User')
          .doc(userCredential.user!.uid)
          .get();
      bool isApproved = await userSnapshot.get('Approve');
      if (isApproved) {
        await getUserDocumentID();
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Dashboard(qrData: newDocReturn),
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
      }
    } catch (e) {
      setState(() {
        //err = 'Error: ${e.toString()}';
        err = "Invalid Email or Password";
      });
    }
  }

  //del
  Future<void> _updateAvailableField(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('User').doc(userId).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        String dailyQuota = userData['Daily Quota'];
        Timestamp? lastUpdateTimestamp = userData['Last Update'];

        DateTime now = DateTime.now();
        DateTime lastUpdateDate = lastUpdateTimestamp != null
            ? lastUpdateTimestamp.toDate()
            : DateTime(2000); // A default old date

        // Check if the last update date is different from today
        if (lastUpdateDate.year != now.year ||
            lastUpdateDate.month != now.month ||
            lastUpdateDate.day != now.day) {
          await _firestore.collection('User').doc(userId).update({
            'Available': dailyQuota,
            'Last Update': now,
          });
          print('Available field updated to $dailyQuota');
        } else {
          print('Available field is already up-to-date.');
        }
      } else {
        print('User document not found.');
      }
    } catch (e) {
      print('Error updating available field: $e');
    }
  }
  //end
}

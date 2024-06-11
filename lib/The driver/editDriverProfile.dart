import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/login_and_register/customTextFormField.dart';

class EditDriverProfile extends StatefulWidget {
  const EditDriverProfile({super.key});

  @override
  State<EditDriverProfile> createState() => _EditDriverProfileState();
}

class _EditDriverProfileState extends State<EditDriverProfile> {
  final FirebaseAuth _authDriver = FirebaseAuth.instance;
  final FirebaseFirestore _firestoreDriver = FirebaseFirestore.instance;

  String newFName = "";
  String newMail = "";
  String currEmail = "";
  String currPassword = "";
  String newPassword = "";
  String newContact = "";
  String newAddress = "";
  String newNIC = "";
  String epf = "";
  bool dataFetched = false;

  bool _obscureText = true;

  void changeVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  final formKey = GlobalKey<FormState>();

  final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  final contactNumberRegex = RegExp(
    r'^[0-9]{10}$',
  );
  final RegExp nameExp = RegExp(r'^[a-zA-Z\s]+$');
  final epfNoRegex = RegExp(
    r'^[0-9]+$',
  );

  Future<void> fetchDriverData() async {
    User? currentDriver = _authDriver.currentUser;

    if (currentDriver != null) {
      DocumentSnapshot driverData = await _firestoreDriver
          .collection('Driver')
          .doc(currentDriver!.uid)
          .get();

      if (driverData.exists) {
        Map<String, dynamic> myData = driverData.data() as Map<String, dynamic>;
        setState(() {
          newFName = myData["Driver_name"] ?? '';
          currEmail = myData["Email"] ?? '';
          currPassword = myData["Password"] ?? '';
          newContact = myData["Mobile"] ?? '';
          newAddress = myData["Address"] ?? '';
          newNIC = myData["NIC"] ?? '';
          epf = myData["EPF"] ?? '';
          dataFetched = true;
        });
      } else
        print("No User Logged In.");
    }
  }

  Future<void> updateDriverData() async {
    User? driver1 = _authDriver.currentUser;
    try {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();

        try {
          final docRef =
              _firestoreDriver.collection('Driver').doc(driver1?.uid);

          await docRef.update({
            "Driver_name": newFName,
            "Email": newMail,
            "Password": newPassword,
            "Mobile": newContact,
            "Address": newAddress,
            "EPF": epf,
            "NIC": newNIC,
          });

          if (newMail != driver1!.email) {
            await driver1.verifyBeforeUpdateEmail(newMail);
            await driver1.sendEmailVerification();
            print(newMail);
          }

          if (currPassword != newPassword) {
            if (currPassword.isNotEmpty) {
              await driver1?.updatePassword(newPassword);
              print(newPassword);
            }
          }

          await Fluttertoast.showToast(
            msg: "The data was Successfully Updated!",
            toastLength: Toast.LENGTH_SHORT, // Duration of the toast
          );
          print("Updated successfully");
        } on FirebaseException catch (e) {
          print("Your Update Error is ${e.toString()}");
        }
      }
    } catch (e) {
      print("Error is :" + e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDriverData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
        title: Text(
          "Edit Driver Profile",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: dataFetched
          ? SafeArea(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: 40),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: newFName,
                          decoration: InputDecoration(
                            labelText: "Enter Your New Name",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Enter Your Name";
                            }
                            if (!nameExp.hasMatch(value)) {
                              return "Enter a valid name";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            newFName = value!;
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          initialValue: currEmail,
                          decoration: InputDecoration(
                            labelText: "Enter New Email",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter Email";
                            }
                            if (!emailRegex.hasMatch(value)) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            newMail = value!;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          initialValue: currPassword,
                          decoration: InputDecoration(
                            labelText: "Enter New Password",
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
                                return "Enter Password";
                              }
                            }
                            return null;
                          },
                          onSaved: (value) {
                            newPassword = value!;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          initialValue: newContact,
                          decoration: InputDecoration(
                            labelText: "Enter New Contact No",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Enter Contact Number";
                            }
                            if (!contactNumberRegex.hasMatch(value)) {
                              return "Enter a valid contact no";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            newContact = value!;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          initialValue: newAddress,
                          decoration: InputDecoration(
                            labelText: "Enter New Address",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                          ),
                          validator: (String? value) {
                            if (value != null) {
                              if (value.isEmpty) {
                                return "Enter New Address";
                              }
                            }
                            return null;
                          },
                          onSaved: (value) {
                            newAddress = value!;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          initialValue: newNIC,
                          decoration: InputDecoration(
                            labelText: "Enter New NIC",
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
                          onSaved: (value) {
                            newNIC = value!;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          initialValue: epf,
                          decoration: InputDecoration(
                            labelText: "Enter New EPF No",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Enter EPF";
                            }
                            if (!epfNoRegex.hasMatch(value)) {
                              return "Enter a valid epf no";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            epf = value!;
                          },
                        ),
                        SizedBox(height: 25),
                        Container(
                          height: 60,
                          width: 200,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.tealAccent),
                            ),
                            onPressed: () async {
                              await updateDriverData();
                            },
                            child: Text(
                              "Edit",
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Color.fromARGB(255, 1, 0, 2),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          height: 60,
                          width: 200,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  const Color.fromARGB(255, 100, 162, 255)),
                            ),
                            onPressed: () {},
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Color.fromARGB(255, 1, 0, 2),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : Center(),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/login_and_register/customTextFormField.dart';

class editProfile extends StatefulWidget {
  const editProfile({super.key});

  @override
  State<editProfile> createState() => _editProfileState();
}

class _editProfileState extends State<editProfile> {
  final FirebaseAuth _authUser = FirebaseAuth.instance;
  final FirebaseFirestore _firestoreUser = FirebaseFirestore.instance;

  final emailRegex = RegExp(
    r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}$',
  );
  final contactNumberRegex = RegExp(
    r'^[0-9]{10}$',
  );
  final RegExp nameExp = RegExp(r'^[a-zA-Z\s]+$');

  String newFName = "";
  String Mail = "";
  String newMail = "";
  String newPassword = "";
  String Password = "";
  String newContact = "";
  String newAddress = "";
  String newNIC = "";
  bool dataFetched = false;

  bool _obscureText = true;

  void changeVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  final formKey = GlobalKey<FormState>();

  Future<void> fetchUserData() async {
    User? current_User = _authUser.currentUser;

    if (current_User != null) {
      DocumentSnapshot userData =
          await _firestoreUser.collection('User').doc(current_User!.uid).get();

      if (userData.exists) {
        Map<String, dynamic> myData = userData.data() as Map<String, dynamic>;
        setState(() {
          newFName = myData["User name"] ?? '';
          Mail = myData["Email"] ?? '';
          Password = myData["Password"] ?? '';
          newContact = myData["Mobile"] ?? '';
          newAddress = myData["Address"] ?? '';
          newNIC = myData["NIC"] ?? '';

          dataFetched = true;
        });
      } else
        print("No User Logged In.");
    }
  }

  Future<void> updateUsererData() async {
    User? user1 = _authUser.currentUser;
    try {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();

        try {
          final docRef = _firestoreUser.collection('User').doc(user1?.uid);

          await docRef.update({
            "User name": newFName,
            "Email": newMail,
            "Password": newPassword,
            "Mobile": newContact,
            "Address": newAddress,
            "NIC": newNIC,
          });

          if (newMail != user1!.email) {
            await user1.verifyBeforeUpdateEmail(newMail);
            await user1.sendEmailVerification();
            print(newMail);
          }

          if (Password != newPassword) {
            if (Password.isNotEmpty) {
              await user1.updatePassword(newPassword);
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
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Center(
          child: Text(
            "Edit profile settings",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
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
                            labelText: "Enter New Name",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Enter Name";
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
                        SizedBox(height: 20),
                        TextFormField(
                          initialValue: Mail,
                          decoration: InputDecoration(
                            labelText: "Enter New Email",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Enter email";
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
                          initialValue: Password,
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
                              return "Enter Contact No";
                            }
                            if (!contactNumberRegex.hasMatch(value)) {
                              return "Enter a valid number";
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
                                return "Enter Address";
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
                        SizedBox(height: 10),
                        Container(
                          height: 60,
                          width: 200,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.tealAccent),
                            ),
                            onPressed: () async {
                              await updateUsererData();
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/login_and_register/customTextFormField.dart';

class EditOfficerProfile extends StatefulWidget {
  const EditOfficerProfile({super.key});

  @override
  State<EditOfficerProfile> createState() => _EditOfficerProfileState();
}

class _EditOfficerProfileState extends State<EditOfficerProfile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _dataFetched = false;

  String newFName = "";
  String _Mail = "";
  String newEmail = "";
  String newPassword = "";
  String _Password = "";
  String newContact = "";
  String newAddress = "";
  String newNIC = "";
  String epf = "";

  final emailRegex = RegExp(r"^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$");

  final contactNumberRegex = RegExp(
    r'^[0-9]{10}$',
  );
  final RegExp nameExp = RegExp(r'^[a-zA-Z\s]+$');
  final epfNoRegex = RegExp(
    r'^[0-9]+$',
  );

  bool _obscureText = true;

  void changeVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  final formKey = GlobalKey<FormState>();

  Future<void> fetchOfficerData() async {
    User? current_User = _firebaseAuth.currentUser;
    if (current_User != null) {
      DocumentSnapshot officerData =
          await _firestore.collection('Officer').doc(current_User.uid).get();
      if (officerData.exists) {
        Map<String, dynamic> myData =
            officerData.data() as Map<String, dynamic>;
        setState(() {
          newFName = myData["Officer_name"] ?? '';
          _Mail = myData["Email"] ?? '';
          _Password = myData["Password"] ?? '';
          newContact = myData["Mobile"] ?? '';
          newAddress = myData["Address"] ?? '';
          newNIC = myData["NIC"] ?? '';
          epf = myData["EPF"] ?? '';
          _dataFetched = true;
        });
      } else {
        print("No User");
      }
    }
  }

  Future<void> updateOfficerData() async {
    User? officer1 = _firebaseAuth.currentUser;
    try {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();

        try {
          final docRef = _firestore.collection('Officer').doc(officer1?.uid);

          await docRef.update({
            "Officer_name": newFName,
            "Email": newEmail,
            "Password": newPassword,
            "Mobile": newContact,
            "Address": newAddress,
            "EPF": epf,
            "NIC": newNIC,
          });

          if (newEmail != officer1!.email) {
            await officer1.verifyBeforeUpdateEmail(newEmail);
            await officer1.sendEmailVerification();

            print(newEmail);
          }

          if (_Password != newPassword) {
            if (_Password.isNotEmpty) {
              await officer1.updatePassword(newPassword);
              print(newPassword);
            }
          }
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
    fetchOfficerData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
        title: Text(
          "Edit Officer Profile",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
      ),
      body: _dataFetched
          ? SafeArea(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Form(
                  key: formKey,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(top: 40),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Enter Your New Name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                            initialValue: newFName,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter Your Name";
                              }
                              if (!nameExp.hasMatch(value)) {
                                return "Enter a Valid Name";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              newFName = value!;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Enter Your New Email",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                            initialValue: _Mail,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter Your Email";
                              }
                              if (!emailRegex.hasMatch(value)) {
                                return "Enter a Valid Email";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              newEmail = value!;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Enter Your New Password",
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
                            initialValue: _Password,
                            obscureText: _obscureText,
                            validator: (value) {
                              if (value != null) {
                                if (value.isEmpty) {
                                  return "Enter New Password";
                                }
                              }
                              return null;
                            },
                            onSaved: (value) {
                              newPassword = value!;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Enter Your New Contact No",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                            initialValue: newContact,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter Your Contact No";
                              }
                              if (!contactNumberRegex.hasMatch(value)) {
                                return "Enter a Valid Contact No";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              newContact = value!;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            initialValue: newAddress,
                            decoration: InputDecoration(
                              labelText: "Enter Your New Address",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                            validator: (value) {
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
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            initialValue: newNIC,
                            decoration: InputDecoration(
                              labelText: "Enter Your New NIC",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                            validator: (value) {
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
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            initialValue: epf,
                            decoration: InputDecoration(
                              labelText: "Enter Your New EPF No",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter Your EPF No";
                              }
                              if (!epfNoRegex.hasMatch(value)) {
                                return "Enter a Valid EPF No";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              epf = value!;
                            },
                          ),
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
                              await updateOfficerData();
                              print(_Mail);
                              print(_Password);
                              print(newFName);
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

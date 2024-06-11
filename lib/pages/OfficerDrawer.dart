import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DrawerOfficer extends StatefulWidget {
  const DrawerOfficer({super.key});

  @override
  State<DrawerOfficer> createState() => _DrawerOfficerState();
}

class _DrawerOfficerState extends State<DrawerOfficer> {
  String officer_name = "";
  String officer_email = "";

  final FirebaseAuth _authOfficer = FirebaseAuth.instance;
  final FirebaseFirestore _firestoreOfficer = FirebaseFirestore.instance;

  Future<void> fetchUserData() async {
    User? currentUser = _authOfficer.currentUser;

    if (currentUser != null) {
      DocumentSnapshot driverData = await _firestoreOfficer
          .collection('Officer')
          .doc(currentUser!.uid)
          .get();

      if (driverData.exists) {
        print("Existing data in the document");
        Map<String, dynamic> myData = driverData.data() as Map<String, dynamic>;
        setState(() {
          officer_name = myData["Officer_name"] ?? '';
          officer_email = myData["Email"] ?? '';
        });
      } else
        print("No User Logged In.");
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
    return Container(
      color: Color.fromARGB(255, 58, 70, 240),
      width: double.infinity,
      height: 250,
      padding: EdgeInsets.only(top: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 10),
            height: 50,
            child: Image.asset(
              "assets/images/waterLogo1.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Text(
            officer_name,
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            officer_email,
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
    ;
  }
}

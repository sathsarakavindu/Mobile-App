import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DriverDrawer extends StatefulWidget {
  const DriverDrawer({super.key});

  @override
  State<DriverDrawer> createState() => _DriverDrawerState();
}

class _DriverDrawerState extends State<DriverDrawer> {
  String Driver_name = "";
  String Driver_mail = "";
  final FirebaseAuth _authDriver = FirebaseAuth.instance;
  final FirebaseFirestore _firestoreDriver = FirebaseFirestore.instance;

  Future<void> fetchDriverData() async {
    User? currentUser = _authDriver.currentUser;

    if (currentUser != null) {
      DocumentSnapshot driverData = await _firestoreDriver
          .collection('Driver')
          .doc(currentUser!.uid)
          .get();

      if (driverData.exists) {
        print("Existing data in the document");
        Map<String, dynamic> myData = driverData.data() as Map<String, dynamic>;
        setState(() {
          Driver_name = myData["Driver_name"] ?? '';
          Driver_mail = myData["Email"] ?? '';
        });
      } else
        print("No User Logged In.");
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
            Driver_name,
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            Driver_mail,
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
    ;
  }
}

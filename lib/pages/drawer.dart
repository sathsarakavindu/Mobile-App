import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class myDrawer extends StatefulWidget {
  const myDrawer({super.key});

  @override
  State<myDrawer> createState() => _myDrawerState();
}

class _myDrawerState extends State<myDrawer> {
  final FirebaseAuth _authUser = FirebaseAuth.instance;
  final FirebaseFirestore _firestoreUser = FirebaseFirestore.instance;

  String uname = "";
  String mail = "";
  Future<void> fetchUserData() async {
    User? currentUser = _authUser.currentUser;

    if (currentUser != null) {
      DocumentSnapshot driverData =
          await _firestoreUser.collection('User').doc(currentUser!.uid).get();

      if (driverData.exists) {
        print("Existing data in the document");
        Map<String, dynamic> myData = driverData.data() as Map<String, dynamic>;
        setState(() {
          uname = myData["User name"] ?? '';
          mail = myData["Email"] ?? '';
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
            uname,
            style: TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
          ),
          Text(
            mail,
            style: TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:myapp/Widgets/DisplayDailyQuota.dart';
import 'package:myapp/Widgets/DisplayPrice.dart';
import 'package:myapp/firebase_auth/firebase_auth_services.dart';
import 'package:myapp/login_and_register/login.dart';
import 'package:myapp/pages/drawer.dart';
import 'package:myapp/pages/editProfile.dart';
import 'package:myapp/pages/OrderPage.dart';
import 'package:myapp/pages/request.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:myapp/pages/OrderPage.dart';

import 'dart:io';

class Dashboard extends StatefulWidget {
  String qrData = "";
  Dashboard({super.key, required this.qrData});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  StreamSubscription<String>? subscription;
  final FirebaseAuth _authUser2 = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  String aval = "";

  Stream<String> fetchUserAvailableData() {
    return _firebaseFirestore
        .collection('User')
        .doc(_authUser2
            .currentUser!.uid) // Assuming _authUser2 provides the user
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return data["Available"] ?? '';
      } else {
        return ''; // Return empty string if document doesn't exist
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    subscription = fetchUserAvailableData().listen((available) {
      setState(() {
        aval = available;
      });
      print(available);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
        title: Text(
          "Welcome",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                myDrawer(),
                Padding(
                  padding: EdgeInsets.only(top: 100),
                ),
                ListTile(
                  tileColor: Color.fromARGB(255, 217, 226, 243),
                  leading: Icon(Icons.edit_document),
                  title: Text("Edit Profile"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => editProfile(),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 30,
                ),
                ListTile(
                  tileColor: Color.fromARGB(255, 217, 226, 243),
                  leading: Icon(Icons.card_giftcard),
                  title: Text("Orders"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderPage(),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 30,
                ),
                ListTile(
                  tileColor: Color.fromARGB(255, 217, 226, 243),
                  leading: Icon(Icons.request_page),
                  title: Text("Requests"),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Request()));
                  },
                ),
                SizedBox(
                  height: 30,
                ),
                ListTile(
                  tileColor: Color.fromARGB(255, 217, 226, 243),
                  leading: Icon(Icons.login_outlined),
                  title: Text("Log Out"),
                  onTap: () async {
                    try {
                      await _authUser2.signOut();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Login()));
                    } on FirebaseAuthException catch (e) {
                      print("Log out error is : ${e.message}");
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 60,
                ),
                Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Color.fromARGB(255, 198, 251, 138),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DisplayPrice(),
                      SizedBox(
                        height: 20,
                      ),
                      DisplayDailyQuota(),
                      SizedBox(height: 20),
                      Text(
                        'Available : ${aval} Liters',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 60),
                QrImageView(
                  data: widget.qrData,
                  //data: "hello world",
                  version: QrVersions.auto,
                  size: 280.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:myapp/The%20owner/editOfficerProfile.dart';

import 'package:myapp/The%20owner/ownerLogin.dart';
import 'package:myapp/The%20owner/scanHistory.dart';
import 'package:myapp/firebase_auth/firebase_auth_services.dart';
import 'package:myapp/pages/OfficerDrawer.dart';
import 'package:myapp/pages/drawer.dart';
import 'package:myapp/qr_code/result_screen.dart';

const bgColor = Colors.white;

class Qr_scanner extends StatefulWidget {
  const Qr_scanner({super.key});

  @override
  State<Qr_scanner> createState() => _Qr_scannerState();
}

class _Qr_scannerState extends State<Qr_scanner> {
  bool isScanCompleted = false;

  void closeScreeen() {
    isScanCompleted = false;
  }

  var getResult = "QR Code Result";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "QR Scanner",
            style: TextStyle(
                fontSize: 25, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 6, 251, 165),
      ),
      backgroundColor: bgColor,
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                DrawerOfficer(),
                Padding(
                  padding: EdgeInsets.only(top: 100),
                ),
                ListTile(
                  tileColor: Color.fromARGB(255, 217, 226, 243),
                  leading: Icon(Icons.edit_document),
                  title: Text("Edit Officer Profile"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditOfficerProfile(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 30),
                ListTile(
                  tileColor: Color.fromARGB(255, 217, 226, 243),
                  leading: Icon(Icons.history),
                  title: Text("Scan History"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => scanHistory(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 30),
                ListTile(
                  tileColor: const Color.fromARGB(255, 199, 231, 247),
                  leading: Icon(Icons.logout),
                  title: Text("Sign Out"),
                  onTap: () async {
                    try {
                      await FirebaseAuthService().signOut();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ownerLogin()),
                      );
                    } catch (e) {
                      Text("The officer Log out Error : ${e.toString()}");
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          //height: 900,
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Place the QR code in the area.",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Click here for scanning",
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  GestureDetector(
                    onTap: () async {
                      scanQRCode();
                    },
                    child: Image.asset("assets/images/scan.jpg"),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Text(
                    "Developed by sathsara",
                    style: TextStyle(
                        color: Colors.black, fontSize: 15, letterSpacing: 1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void scanQRCode() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.QR);

      if (!mounted) return;

      setState(() {
        getResult = qrCode;
      });

      Navigator.of(context).pop();

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ResultScreen(code: getResult)));
    } on PlatformException {
      getResult = "Failed to scan QR Code.";
    }
  }
}

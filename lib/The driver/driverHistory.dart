import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/The%20driver/editDriverProfile.dart';
import 'package:myapp/pages/drawer.dart';

class DriverHistory extends StatefulWidget {
  const DriverHistory({super.key});

  @override
  State<DriverHistory> createState() => _DriverHistoryState();
}

class _DriverHistoryState extends State<DriverHistory> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String driver_ID = "";
  List<Map<String, dynamic>> _deliverHistory = [];
  bool _isLoading = false;

  Future<void> _getCurrentDriverId() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        String uid = currentUser.uid;
        print(uid);
        DocumentSnapshot userDoc =
            await _firestore.collection('Driver').doc(uid).get();

        if (userDoc.exists) {
          setState(() {
            driver_ID = userDoc['Driver_id'];
          });
          print("Driver Id is ${driver_ID}");
          await _getDeliveredHistory(driver_ID!);
        } else {
          print('No driver found for the current authenticated user.');
        }
      } else {
        print('No user is currently signed in.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _getDeliveredHistory(String driverId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('driver_history')
          .where('Driver_id', isEqualTo: driverId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _deliverHistory = snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
          _isLoading = false;
        });
        print("Not Empty");
      } else {
        setState(() {
          _deliverHistory = [];
          _isLoading = false;
        });
        print('No scan history found for the given Officer_id.');
      }
    } catch (e) {
      print('Error fetching scan history: $e');
      setState(() {
        _deliverHistory = [];
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentDriverId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text(
          "Deliver History",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: _deliverHistory.map((history) {
                  return Card(
                    child: ListTile(
                      title: Text(
                        'Client Name: ${history['User_name']}',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quantity: ${history['Quantity']} Liters',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text('Date: ${history['Date']}',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          Text('Time: ${history['Time']}',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          Text('Address: ${history['Address']}',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
}

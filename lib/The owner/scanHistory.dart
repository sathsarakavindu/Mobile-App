import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class scanHistory extends StatefulWidget {
  const scanHistory({super.key});

  @override
  State<scanHistory> createState() => _scanHistoryState();
}

class _scanHistoryState extends State<scanHistory> {
  String? officerId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _scanHistory = [];
  bool _isLoading = false;

  Future<void> _getCurrentUserId() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        String uid = currentUser.uid;
        print(uid);
        DocumentSnapshot userDoc =
            await _firestore.collection('Officer').doc(uid).get();

        if (userDoc.exists) {
          setState(() {
            officerId = userDoc['Officer_id'];
          });
          print("Officer Id is ${officerId}");
          await _getScanHistory(officerId!);
        } else {
          print('No user found for the current authenticated user.');
        }
      } else {
        print('No user is currently signed in.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _getScanHistory(String officerId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('scan_history')
          .where('Officer_id', isEqualTo: officerId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _scanHistory = snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
          _isLoading = false;
        });
        print("Not Empty");
      } else {
        setState(() {
          _scanHistory = [];
          _isLoading = false;
        });
        print('No scan history found for the given Officer_id.');
      }
    } catch (e) {
      print('Error fetching scan history: $e');
      setState(() {
        _scanHistory = [];
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentUserId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
        title: Text(
          "History",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: _scanHistory.map((history) {
                  return Card(
                    child: ListTile(
                      title: Text('User Name: ${history['User_name']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: ${history['Date']}'),
                          Text('Time: ${history['Time']}'),
                          Text('User ID: ${history['User_id']}'),
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

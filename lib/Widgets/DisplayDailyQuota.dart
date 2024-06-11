import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DisplayDailyQuota extends StatefulWidget {
  const DisplayDailyQuota({super.key});

  @override
  State<DisplayDailyQuota> createState() => _DisplayDailyQuotaState();
}

class _DisplayDailyQuotaState extends State<DisplayDailyQuota> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore.collection('Daily_Quota').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error : ${snapshot.error}");
        }
        if (!snapshot.hasData) {
          return Text('Loading...');
        }
        DocumentSnapshot documentSnapshot = snapshot.data!.docs.first;
        String quota = documentSnapshot['Daily Quota'];
        return Text(
          'Daily Quota : ${quota} Liters',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        );
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DisplayPrice extends StatefulWidget {
  const DisplayPrice({super.key});

  @override
  State<DisplayPrice> createState() => _DisplayPriceState();
}

class _DisplayPriceState extends State<DisplayPrice> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firebaseFirestore.collection('Price').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error : ${snapshot.error}");
        }
        if (!snapshot.hasData) {
          return Text("Loading...");
        }
        DocumentSnapshot document = snapshot.data!.docs.first;
        String amount = document['Price'];
        return Text(
          "Price of 1 Liter : ${amount} Rs",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        );
      },
    );
  }
}

import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:myapp/Widgets/DisplayPrice.dart';
import 'package:myapp/pages/UserOrderMap.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final valueRegex = RegExp(r'^[0-9]+$');
  final form_key = GlobalKey<FormState>();
  double? totalPrice;
  double? _price;
  double? quantityD;
  String? _priceString;
  String qty = "0";
  String? totalString;
  String newQuantity = "0";
  final TextEditingController _val = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime nowTime = DateTime.now();
  String emailUser = "";
  String passwordUser = "";
  String userID = "";
  String userName = "";
  String userDocId = "";
  String priceString = "0";
  double enteredVal = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
        title: Text(
          "Orders",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                Container(
                  width: 240,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Color.fromARGB(255, 240, 164, 255),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
                      DisplayPrice(),
                      SizedBox(height: 20),
                      Text(
                        "Quantity: ${newQuantity} Liters",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Total: ${fullTotal()} Rs",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                Container(
                  width: 390,
                  height: 330,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Color.fromARGB(255, 132, 213, 251),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        Text(
                          "Make Order",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 30),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          controller: _val,
                          decoration: InputDecoration(
                            labelText: "Enter Quantity",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            icon: Icon(Icons.water_drop),
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Enter a valid number";
                            }
                            if (!valueRegex.hasMatch(value)) {
                              return "Not a valid number";
                            }
                            enteredVal = double.parse(value!);
                            if (enteredVal > 100) {
                              return "The maximum limit is 100 liters";
                            }
                            if (enteredVal < 10) {
                              return "The entered value must be greater than 10 liters";
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            qty = newValue!;
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                                Colors.lightGreenAccent),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate() == false) {
                              return;
                            }

                            _formKey.currentState!.save();

                            setState(() {
                              newQuantity = qty;
                            });
                            await fetchPrice();
                            fullTotal();
                            await _getPriceFromFirestore();
                            await fetchUserData();
                            await updateOrderLocation();
                            await sendMail();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserOrderMap(
                                  user_ID: userDocId,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            "Order",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () {
                            _val.clear();
                          },
                          child: Text(
                            "Clear",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String generateCustomIDForDriver(int length) {
    const chars = 'Ord123456789';
    Random random = Random();
    String uniqueID = String.fromCharCodes(List.generate(
        length, (index) => chars.codeUnitAt(random.nextInt(chars.length))));
    return uniqueID;
  }

  Future<void> fetchUserData() async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      DocumentSnapshot userData =
          await _firestore.collection('User').doc(currentUser!.uid).get();

      if (userData.exists) {
        print("Existing data in the document");
        Map<String, dynamic> myData = userData.data() as Map<String, dynamic>;
        setState(() {
          userID = myData["User_id"] ?? '';
          emailUser = myData["Email"] ?? '';
          passwordUser = myData["Password"] ?? '';
          userDocId = userData.id;
        });
      } else
        print("No User Logged In.");
    }
  }

  Future<void> updateOrderLocation() async {
    bool permissionGranted = await _handleLocationPermission();
    if (!permissionGranted) {
      print('Location permission not granted');
      return;
    }

    Position? position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (position == null) {
      print('Failed to get current position');
      return;
    }
    GeoPoint location = GeoPoint(position.latitude, position.longitude);

    makeOrder(location);
  }

  Future<bool> _handleLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> makeOrder(GeoPoint? location) async {
    String order_id = generateCustomIDForDriver(4);

    String timeNow = time();
    String dateNow = date();
    total();

    Map<String, dynamic> orderData = {
      "Order_Id": order_id,
      "User_Id": userID,
      "Time": timeNow,
      "Date": dateNow,
      "Unit_Price": _priceString,
      "Quantity": qty,
      "Total": totalString,
      "Is_Approved": false,
      "Is_finished": false,
      "Location": location,
    };

    await _firestore.collection('Order').doc(userDocId).set(orderData);
  }

  String time() {
    String formattedTime = nowTime.toString().substring(11, 16);
    return formattedTime;
  }

  String date() {
    DateTime now = DateTime.now();
    String formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    return formattedDate;
  }

  Future<void> _getPriceFromFirestore() async {
    try {
      final docSnapshot = await _firestore
          .collection('Price')
          .doc('5XsRB3BroaZrKDJBNB4a') // Replace with your actual document ID
          .get();
      if (docSnapshot.exists) {
        final priceData = docSnapshot.data() as Map<String, dynamic>;
        final price = priceData['Price']; // Avoid type casting here
        if (price != null) {
          if (price is String) {
            setState(() {
              _priceString = price; // Store the string directly
            });
          } else if (price is double) {
            setState(() {
              _priceString = price.toStringAsFixed(2); // Format if double
            });
          } else {
            print('Error: Unexpected data type for Price field');
          }
          print(
              "Price of 1 Liter is ${_priceString}"); // Display price (if available)
        } else {
          print('Error: Price field not found in document');
        }
      } else {
        print('Error: Price document not found');
      }
    } catch (e) {
      print('Error getting price: $e');
    }
  }

  void total() {
    setState(() {
      _price = double.parse(_priceString!);
      quantityD = double.parse(qty);
      totalPrice = _price! * quantityD!;
      totalString = totalPrice.toString();
    });
  }

  String fullTotal() {
    double quantity_D = double.parse(qty);
    double price_D = double.parse(priceString);

    double totalPrice = quantity_D * price_D;

    return totalPrice.toString();
  }

  Future<void> fetchPrice() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Price')
          .doc('5XsRB3BroaZrKDJBNB4a')
          .get();

      if (documentSnapshot.exists) {
        setState(() {
          priceString = documentSnapshot
              .get('Price'); // Assuming the field name is 'price'
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching document: $e');
    }
  }

  Future<void> sendMail() async {
    final CollectionReference driversCollection =
        _firestore.collection('Driver');

    QuerySnapshot querySnapshot = await driversCollection.get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;

    for (var doc in documents) {
      final driverName = doc['Driver_name'];
      final driverMail = doc['Email'];

      await sendEmailForDrivers(
          userName: driverName,
          userMail: driverMail,
          subject: "New Order is available",
          message: "A new order is available.");
    }
  }

  Future sendEmailForDrivers({
    required String userName,
    required String userMail,
    required String subject,
    required String message,
  }) async {
    final serviceId = 'Your_Service_Id';
    final templateId = 'Your_Template_Id';
    final userId = 'User_Id';
    final privateKey = 'Private_Key';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    final msg = jsonEncode({
      'service_id': serviceId,
      'template_id': templateId,
      'user_id': userId,
      'accessToken': privateKey,
      'template_params': {
        'user_name': userName,
        'user_email': userMail,
        'user_subject': subject,
        'user_message': message,
      },
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: msg,
    );

    print("Your problem is " + response.body);
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myapp/login_and_register/login.dart';
import 'package:myapp/pages/OrderPage.dart';
import 'package:myapp/pages/drawer.dart';
import 'package:myapp/pages/editProfile.dart';
import 'package:myapp/pages/request.dart';

class UserOrderMap extends StatefulWidget {
  final String user_ID;
  UserOrderMap({super.key, required this.user_ID});

  @override
  State<UserOrderMap> createState() => _UserOrderMapState();
}

class _UserOrderMapState extends State<UserOrderMap> {
  final FirebaseAuth _authUserOrder = FirebaseAuth.instance;
  final FirebaseFirestore _FirestoreDriver = FirebaseFirestore.instance;
  final CollectionReference _driversCollection =
      FirebaseFirestore.instance.collection('Driver');
  GoogleMapController? _mapController;
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('Order');
  Marker? _orderMarker;
  Marker? _driverMarker;
  StreamSubscription<Position>? locationSubscription;
  double latitudeOrder = 37.012365;
  double longitudeOrder = -122.0215;
  double latitudeDriver = 37.012365;
  double longitudeDriver = -122.0215;
  String orderID = "";
  LatLng? driverLoc;
  Set<Marker> _driverMarkers = {};
  StreamSubscription<QuerySnapshot>? _driverLocationSubscription;
  final List<LatLng> _driverLocations = [];
  Stream<DocumentSnapshot>? _orderStream;
  DateTime nowTime = DateTime.now();
  String fullTotal = "";
  String orderIDForTotal = "";

  void _startListening() async {
    final String documentId = widget.user_ID;
    if (documentId.isNotEmpty) {
      setState(() {
        _orderStream = FirebaseFirestore.instance
            .collection('Order')
            .doc(documentId)
            .snapshots();
      });
    }
    Text("Document is empty");
  }

  Future<void> _getDriverLocations() async {
    _driverLocationSubscription = _driversCollection.snapshots().listen(
      (querySnapshot) {
        _driverMarkers.clear(); // Clear existing markers
        _driverLocations.clear(); // Clear existing locations
        for (final doc in querySnapshot.docs) {
          final GeoPoint driverLocation = doc['Location'] as GeoPoint;
          _driverLocations
              .add(LatLng(driverLocation.latitude, driverLocation.longitude));

          // Create a marker for each driver location
          _driverMarkers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position:
                  LatLng(driverLocation.latitude, driverLocation.longitude),
              infoWindow: InfoWindow(
                title:
                    doc['Driver_name'], // Assuming "Driver_name" field exists
              ),
            ),
          );
        }

        // Update the map with retrieved locations
        setState(() {});
      },
    );
  }

  Future<void> _getOrderLocation() async {
    final user = _authUserOrder.currentUser;

    if (user != null) {
      orderID = user.uid;
      print("Your order id is ${orderID}");
      final driverDoc = await _userCollection.doc(user.uid).get();
      if (driverDoc.exists) {
        final driverData =
            driverDoc.data() as Map<String, dynamic>; // Type cast
        if (driverData != null) {
          final GeoPoint location;
          try {
            location = driverData['Location'] as GeoPoint; // Type cast
          } catch (e) {
            // Handle the case where 'Location' field is not a GeoPoint
            print('Error: Location field is not a GeoPoint.${e.toString()}');
            return; // Or handle the error differently
          }
          final latitude1 = location.latitude;
          final longitude1 = location.longitude;

          setState(() {
            latitudeOrder = latitude1;
            longitudeOrder = longitude1;

            _orderMarker = Marker(
              markerId: MarkerId(user.uid),
              position: LatLng(latitude1, longitude1),
              infoWindow: InfoWindow(title: 'Order Location'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
            );

            print(latitudeOrder);
            print(longitudeOrder);
          });
        }
      }
    }
  }

  Future<void> _deleteOrderById(String orderId) async {
    try {
      await _FirestoreDriver.collection('Order').doc(orderId).delete();
      print('Order $orderId deleted successfully');
      // Clear the text field after deletion
      // Optionally, refresh order markers after deletion

      //_getOrderLocation();
    } catch (e) {
      print('Error deleting order: $e');
      // Show user a snackbar or dialog with the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateLocationMarker(Position position) async {
    final lat = position.latitude;
    final lng = position.longitude;
    final user = _authUserOrder.currentUser;
    if (user == null) {
      // Handle the case where no user is logged in
      print('Error: No user is currently logged in');
      return;
    }

    setState(() {
      _orderMarker = Marker(
        markerId: MarkerId(user.uid),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: 'Driver Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );
    });

    // Update Firestore with new location (optional)
    await _userCollection.doc(user.uid).update({
      'Location': GeoPoint(lat, lng),
    });
  }

  Future<void> _deleteOrder(String orderId) async {
    try {
      await _FirestoreDriver.collection('Order').doc(orderId).delete();
      print('Order $orderId deleted successfully');
      // Optionally, refresh order markers after deletion
      _getOrderLocation();
    } catch (e) {
      print('Error deleting order: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getOrderLocation();
    _getDriverLocations();
    locationSubscription = Geolocator.getPositionStream().listen((position) {
      _updateLocationMarker(position);
    });
    _startListening();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    locationSubscription?.cancel();
    _driverLocationSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
        title: Text("View Order"),
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
                      await FirebaseAuth.instance.signOut();
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
          child: Column(
            children: [
              Container(
                height: 400,
                width: double.infinity,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(37.012365, -122.0215), //
                    zoom: 16, // Set higher zoom for better tracking
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  // markers: (_orderMarker != null) ? {_orderMarker!} : {},
                  markers: _driverMarkers,
                  myLocationEnabled: true, // Show user's blue dot
                ),
              ),
              SizedBox(
                height: 40,
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    Color.fromARGB(255, 56, 248, 69),
                  ),
                ),
                onPressed: () async {
                  if (await checkOrderApprovalStatus(widget.user_ID) == true) {
                    // await updateOrderStatus(widget.user_ID);
                    await Fluttertoast.showToast(
                      msg: "The order has been successfully delivered..!",
                      toastLength: Toast.LENGTH_SHORT, // Duration of the toast
                    );
                    //

                    Navigator.of(context).pop();
                  } else {
                    Fluttertoast.showToast(
                      msg: "The order hasn't been selected by a driver..!",
                      toastLength: Toast.LENGTH_SHORT, // Duration of the toast
                    );
                  }
                },
                child: Text(
                  "Recieved Order",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    Colors.red,
                  ),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();

                  await _deleteOrderById(orderID);

                  print(orderID);
                },
                child: Text(
                  "Order Cancel",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              _orderStream != null
                  ? StreamBuilder<DocumentSnapshot>(
                      stream: _orderStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (snapshot.hasData) {
                          final data =
                              snapshot.data?.data() as Map<String, dynamic>?;

                          if (data == null) {
                            return Text('Document does not exist');
                          }

                          final isApproved = data['Is_Approved'] as bool?;
                          if (isApproved == true) {
                            return Column(
                              children: [
                                Text(
                                  "Your order has been approved by a driver",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "...Waiting few minutes until the driver comes...",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                CircularProgressIndicator(),
                                Text(
                                  "Your order has not been approved yet..",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "...Waiting until the driver approve your order...",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            );
                          }
                        }
                        return Text('Document does not exist');
                      },
                    )
                  : Text('Enter a Document ID to check approval status'),
            ],
          ),
        ),
      ),
    );
  }

  // Future<void> updateOrderStatus(String documentId) async {
  //   try {
  //     // Check if the document exists
  //     DocumentSnapshot documentSnapshot =
  //         await _FirestoreDriver.collection('Order').doc(documentId).get();
  //     if (documentSnapshot.exists) {
  //       // Update the 'Is_finished' field to true
  //       await _FirestoreDriver.collection('Order')
  //           .doc(documentId)
  //           .update({'Is_finished': true});
  //       print('Order status updated successfully.');
  //     } else {
  //       print('Order document with ID $documentId does not exist.');
  //     }
  //   } catch (e) {
  //     print('Error updating order status: $e');
  //   }
  // }

  checkOrderApprovalStatus(String documentId) async {
    try {
      // Retrieve the document
      DocumentSnapshot documentSnapshot =
          await _FirestoreDriver.collection('Order').doc(documentId).get();
      if (documentSnapshot.exists) {
        // Get the value of 'Is_Approved' field
        bool isApproved = documentSnapshot['Is_Approved'];
        if (isApproved) {
          print('The order is approved.');
          return true;
        } else {
          print('The order is not approved.');
          return false;
        }
      } else {
        print('Order document with ID $documentId does not exist.');
      }
    } catch (e) {
      print('Error checking order approval status: $e');
    }
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

  Future<void> totalPriceSave() async {
    await getOrderDetails(orderID);
    Map<String, dynamic> totalData = {
      "Id": orderIDForTotal,
      "Time": time(),
      "Date": date(),
      "Total": fullTotal,
    };

    await _FirestoreDriver.collection('Total_Price').add(totalData);
  }

  Future<void> getOrderDetails(String documentId) async {
    try {
      // Get the document snapshot
      DocumentSnapshot documentSnapshot =
          await _FirestoreDriver.collection('Order').doc(documentId).get();
      if (documentSnapshot.exists) {
        // Get the document data
        Map<String, dynamic>? documentData =
            documentSnapshot.data() as Map<String, dynamic>?;
        if (documentData != null) {
          // Retrieve specific field values
          setState(() {
            fullTotal = documentData['Total'] as String? ?? 'Unknown';
            orderIDForTotal = documentData['Order_Id'] as String? ?? 'Unknown';
          });

          // Print the retrieved values
          print('Total Price: $fullTotal');

          // Save values to string variables
          // You can use these variables later in your code
        } else {
          print('The document data is null.');
        }
      } else {
        print('Order document with ID $documentId does not exist.');
      }
    } catch (e) {
      print('Error getting order details: $e');
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myapp/Classes/OrderDataClass.dart';
import 'package:myapp/The%20driver/driverHistory.dart';
import 'package:myapp/The%20driver/editDriverProfile.dart';
import 'package:myapp/The%20driver/loginDriver.dart';
import 'package:myapp/pages/DriverDrawer.dart';
import 'package:myapp/pages/drawer.dart';

class driverDash extends StatefulWidget {
  const driverDash({super.key});

  @override
  State<driverDash> createState() => _driverDashState();
}

class _driverDashState extends State<driverDash> {
  final FirebaseAuth _authDriver = FirebaseAuth.instance;
  final FirebaseFirestore _FirestoreDriver = FirebaseFirestore.instance;
  final CollectionReference _driversCollection =
      FirebaseFirestore.instance.collection('Driver');
  final CollectionReference _deliversCollection =
      FirebaseFirestore.instance.collection('Deliver');
  final CollectionReference _driverHistoryCollection =
      FirebaseFirestore.instance.collection('driver_history');
  final FirebaseFirestore ordersCollection = FirebaseFirestore.instance;
  GoogleMapController? _mapController;
  final Map<String, OrderData> _orderDetailsMap = {};
  Marker? _driverMarker;
  String _userId = "";
  bool? finishedOrder;
  Set<Marker> _orderMarkers = {};
  StreamSubscription<Position>? locationSubscription;
  String locationDriver = "";
  LatLng? orderLocation_;
  LatLng? driverLocation;
  String driver_id = "";
  String? _userName;
  String? _email;
  String? _mobile;
  String? _address;
  String? quantity;
  String? total;
  DateTime nowTime = DateTime.now();
  BitmapDescriptor? _customOrderIcon;
  BitmapDescriptor? _customDriverIcon;

  StreamSubscription<QuerySnapshot>? _orderStreamSubscription;
  final Map<String, StreamSubscription<OrderData>> _orderDataStreams = {};
  double latitudeDriver = 37.012365;
  double longitudeDriver = -122.0215;
  double OrderLat1 = 0.0;
  double OrderLon1 = 0.0;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  LatLng? newOrderLocation;
  String orderIdAndUserID = "";
  bool? isApproved;
  bool? isFinished;

  String fullTotal = "";
  String orderIDForTotal = "";

  Future<void> _loadCustomIcons() async {
    _customOrderIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)),
      'assets/images/order.png',
    );
    _customDriverIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)),
      'assets/images/Driver.png',
    );
  }

  Future<void> cancelOrder(String orderID) async {
    if (orderID.isNotEmpty) {
      final DocumentReference orderRef =
          FirebaseFirestore.instance.collection('Order').doc(orderID);

      // Fetch the order document
      final DocumentSnapshot orderSnapshot = await orderRef.get();

      if (orderSnapshot.exists) {
        setState(() {
          isApproved = orderSnapshot['Is_Approved'];
          isFinished = orderSnapshot['Is_finished'];
        });

        if (isApproved == true) {
          await orderRef.update({'Is_Approved': false});
          print('Order $orderID updated successfully.');
          Fluttertoast.showToast(
            msg: "The Order Successfully Cancelled..!",
            toastLength: Toast.LENGTH_SHORT, // Duration of the toast
          );
        } else {
          Fluttertoast.showToast(
            msg: "The order does not approved..!",
            toastLength: Toast.LENGTH_SHORT, // Duration of the toast
          );
        }
      }
    } else {
      Fluttertoast.showToast(
        msg: "Please Select an Order..!",
        toastLength: Toast.LENGTH_SHORT, // Duration of the toast
      );
    }
  }

  Future<void> approvedOrder(String orderID) async {
    if (orderID.isNotEmpty) {
      final DocumentReference orderRef =
          FirebaseFirestore.instance.collection('Order').doc(orderID);

      // Fetch the order document
      final DocumentSnapshot orderSnapshot = await orderRef.get();

      if (orderSnapshot.exists) {
        setState(() {
          isApproved = orderSnapshot['Is_Approved'];
          isFinished = orderSnapshot['Is_finished'];
        });

        if (isApproved == false) {
          await orderRef.update({'Is_Approved': true});
          print('Order $orderID updated successfully.');
          Fluttertoast.showToast(
            msg: "The Order Successfully Approved..!",
            toastLength: Toast.LENGTH_SHORT, // Duration of the toast
          );
        } else {
          Fluttertoast.showToast(
            msg: "The order does not approved..!",
            toastLength: Toast.LENGTH_SHORT, // Duration of the toast
          );
        }
      }
    } else {
      Fluttertoast.showToast(
        msg: "Please Select an Order..!",
        toastLength: Toast.LENGTH_SHORT, // Duration of the toast
      );
    }
  }

  Future<void> updateOrderIsFinished(String orderId) async {
    if (orderId.isNotEmpty) {
      final DocumentReference orderRef =
          FirebaseFirestore.instance.collection('Order').doc(orderId);

      // Fetch the order document
      final DocumentSnapshot orderSnapshot = await orderRef.get();

      if (orderSnapshot.exists) {
        setState(() {
          isApproved = orderSnapshot['Is_Approved'];
          isFinished = orderSnapshot['Is_finished'];
        });

        if (isApproved!) {
          if (isFinished == false) {
            // Update the 'Is_finished' field to true
            await orderRef.update({'Is_finished': true});
            print('Order $orderId updated successfully.');
            Fluttertoast.showToast(
              msg: "The Order Successfully Finished..!",
              toastLength: Toast.LENGTH_SHORT, // Duration of the toast
            );
            await totalPriceSave();
          } else {
            print('Order $orderId is either not approved or already finished.');
          }
        } else {
          Fluttertoast.showToast(
            msg: "Please Select an Order..!",
            toastLength: Toast.LENGTH_SHORT, // Duration of the toast
          );
        }
      } else {
        print('Order $orderId not found in the database.');
      }
    } else {
      Fluttertoast.showToast(
        msg: "Please Select an Order..!",
        toastLength: Toast.LENGTH_SHORT, // Duration of the toast
      );
    }
  }

  Future<void> _getAndDrawPolyline(
      LatLng driverLocation, LatLng orderLocation) async {
    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'Google Map API Key', // Replaced with my actual Google Maps API key
        PointLatLng(driverLocation.latitude, driverLocation.longitude),
        PointLatLng(orderLocation.latitude, orderLocation.longitude),
        travelMode: TravelMode.driving,
      );

      if (result.status == 'OK' && result.points.isNotEmpty) {
        polylineCoordinates.clear();
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }

        PolylineId id = PolylineId('poly');
        Polyline polyline = Polyline(
          polylineId: id,
          color: Colors.red,
          points: polylineCoordinates,
          width: 5,
        );

        setState(() {
          polylines.clear(); // Clear the previous polyline
          polylines[id] = polyline;
        });
      } else {
        throw Exception('Unable to get route: ${result.status}');
      }
    } catch (e) {
      print('Error getting route: $e');
    }
  }

  void _clearPolyline() {
    setState(() {
      polylines.clear();
    });
  }

  void _startListeningForOrders() {
    _orderStreamSubscription = _FirestoreDriver.collection('Order')
        .where('Is_finished', isEqualTo: false)
        .snapshots() // Listen for changes in orders collection
        .listen((querySnapshot) {
      final updatedMarkers = <Marker>{}; // Temporary set for new markers
      for (final doc in querySnapshot.docs) {
        final orderData = doc.data() as Map<String, dynamic>;
        if (orderData != null) {
          final GeoPoint orderLocation;
          try {
            orderLocation = orderData['Location'] as GeoPoint;
            finishedOrder = orderData['Is_finished'] as bool;
          } catch (e) {
            print(
                'Error: Location field in order ${doc.id} is not a GeoPoint.${e.toString()}');
            continue;
          }
          final orderLat = orderLocation.latitude;
          final orderLng = orderLocation.longitude;
          setState(() {
            orderLocation_ = LatLng(orderLat, orderLng);
          });

          updatedMarkers.add(
            Marker(
              markerId: MarkerId(doc.id), // Use order ID as unique identifier
              position: LatLng(orderLat, orderLng),
              infoWindow: InfoWindow(
                title: 'Order Location',
                onTap: () async {
                  _showOrderDetailsDialog(doc.id);
                  await _getAndDrawPolyline(
                      driverLocation!, LatLng(orderLat, orderLng));
                },
              ),
              icon: _customOrderIcon ??
                  BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen),
            ),
          );
        }
      }
      // Update UI with new markers
      setState(() {
        _orderMarkers = updatedMarkers;
      });
    });
  }

  Future<void> _getDriverLocation() async {
    final user = _authDriver.currentUser;
    if (user != null) {
      final driverDoc = await _driversCollection.doc(user.uid).get();
      if (driverDoc.exists) {
        final driverData =
            driverDoc.data() as Map<String, dynamic>; // Type cast
        if (driverData != null) {
          final GeoPoint location;
          try {
            location = driverData['Location'] as GeoPoint; // Type cast
            setState(() {
              driver_id = driverData['Driver_id'];
            });
          } catch (e) {
            // Handle the case where 'Location' field is not a GeoPoint
            print('Error: Location field is not a GeoPoint.${e.toString()}');
            return; // Or handle the error differently
          }
          final latitude1 = location.latitude;
          final longitude1 = location.longitude;

          setState(() {
            latitudeDriver = latitude1;
            longitudeDriver = longitude1;

            _driverMarker = Marker(
              markerId: MarkerId(user.uid),
              position: LatLng(latitude1, longitude1),
              infoWindow: InfoWindow(title: 'Driver Location'),
              icon: _customDriverIcon ??
                  BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
            );

            driverLocation = LatLng(latitudeDriver, longitudeDriver);

            print(latitudeDriver);
            print(longitudeDriver);
          });
        }
      }
    }
  }

  void _showOrderDetailsDialog(String orderId) async {
    final orderDetails = _orderDetailsMap[orderId];
    if (orderDetails != null) {
      setState(() {
        quantity = orderDetails.quantity;
        total = orderDetails.totalPrice;
      });
    } else {
      print('Error: Order details not available for ID: $orderId');
      return;
    }

    if (driverLocation != null && orderLocation_ != null) {
      //await _getAndDrawPolyline(driverLocation!, orderLocation_!);
    } else {
      print('Error: Driver or order location is not available');
      return;
    }
  }

  Future<void> _updateLocationMarker(Position position) async {
    try {
      final lat = position.latitude;
      final lng = position.longitude;
      final user = _authDriver.currentUser;
      if (user == null) {
        // Handle the case where no user is logged in
        print('Error: No user is currently logged in');
        return;
      }

      setState(() {
        _driverMarker = Marker(
          markerId: MarkerId(user.uid),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: 'Driver Location'),
        );
      });

      // Update Firestore with new location (optional)
      await _driversCollection.doc(user.uid).update({
        'Location': GeoPoint(lat, lng),
      });
    } catch (e) {
      Text("There is a connection problem. Please Log again");
      print(e.toString());
    }
  }

  Future<void> _getOrderDetails(String orderId) async {
    final docSnapshot =
        await _FirestoreDriver.collection('Order').doc(orderId).get();

    if (docSnapshot.exists) {
      final orderData =
          OrderData.fromMap(docSnapshot.data() as Map<String, dynamic>);
      final GeoPoint location = docSnapshot.data()?['Location'] as GeoPoint;

      setState(() {
        newOrderLocation = LatLng(location.latitude, location.longitude);
        _orderDetailsMap[orderId] = orderData;
        if (!_orderDataStreams.containsKey(orderId)) {
          _orderDataStreams[orderId] =
              _listenForOrderUpdates(orderId).listen((updatedOrder) {
            setState(() {
              _orderDetailsMap[orderId] = updatedOrder;
            });
          });
        }
      });
    } else {
      print('Error: Order document not found for ID: $orderId');
    }
  }

  Stream<OrderData> _listenForOrderUpdates(String orderId) {
    return _FirestoreDriver.collection('Order')
        .doc(orderId)
        .snapshots()
        .map((docSnapshot) {
      if (docSnapshot.exists) {
        return OrderData.fromMap(docSnapshot.data() as Map<String, dynamic>);
      } else {
        //throw Exception('Order with ID $orderId not found');
        return _orderDetailsMap[orderId]!;
        // Return existing data or null
      }
    });
  }

  Future<void> _getUserData(String userId) async {
    try {
      final docSnapshot =
          await _FirestoreDriver.collection('User').doc(userId).get();
      if (docSnapshot.exists) {
        final userData = docSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _userName = userData['User name'] as String;
          _email = userData['Email'] as String;
          _mobile = userData['Mobile'] as String;
          _address = userData['Address'] as String;
          _userId = userData['User_id'] as String;
        });
      } else {
        print('Error: User document not found for ID: $userId');
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
  }

  Future<void> _getOrderData(String userId) async {
    try {
      final docSnapshot =
          await _FirestoreDriver.collection('Order').doc(userId).get();
      if (docSnapshot.exists) {
        final userData = docSnapshot.data() as Map<String, dynamic>;
        setState(() {
          finishedOrder = userData['Is_finished'] as bool;
        });
      } else {
        print('Error: User document not found for ID: $userId');
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
  }

  void _showUserDetailsBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(10.0),
        height: 600,
        width: double.infinity,
        // Add padding for content
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height *
              0.65, // Adjust the multiplier (0.8 here) as needed
        ),
        decoration: BoxDecoration(
          color: Color.fromARGB(
              255, 143, 246, 179), // Set bottom sheet background color
          borderRadius: BorderRadius.circular(16.0), // Rounded corners
        ),
        child: SingleChildScrollView(
          child: Column(
            //mainAxisSize: MainAxisSize.min, // Wrap content vertically
            children: [
              Text(
                'User Details',
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 237, 10, 10)),
              ),
              SizedBox(height: 10.0), // Add spacing between title and details
              ListTile(
                title: Center(
                  child: Text(
                    'Name: ${_userName}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                //trailing:Text(_userName ?? 'N/A'), // Display "N/A" if data is null
              ),
              ListTile(
                title: Center(
                  child: Text(
                    'Email: ${_email}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                // trailing: Text(_email ?? 'N/A'),
              ),
              ListTile(
                title: Center(
                    child: Text(
                  'Mobile: ${_mobile}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
                //trailing: Text(_mobile ?? 'N/A'),
              ),
              ListTile(
                title: Center(
                    child: Text(
                  'Address: ${_address}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
                //trailing: Text(_address ?? 'N/A'),
              ),
              ListTile(
                title: Center(
                    child: Text(
                  "Quantity: ${quantity} Liters",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
                //trailing: Text(quantity ?? 'N/A'),
              ),
              ListTile(
                title: Center(
                    child: Text(
                  "Total: Rs ${total}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
                //trailing: Text(total ?? 'N/A'),
              ),

              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                        Color.fromARGB(255, 19, 173, 244))),
                onPressed: () async {
                  if (driverLocation != null && orderLocation_ != null) {
                    await _getAndDrawPolyline(
                        newOrderLocation!, driverLocation!);

                    await approvedOrder(orderIdAndUserID);

                    Navigator.pop(context);
                  } else {
                    print('Error: Driver or order location is not available');
                    // Optionally, show a snackbar indicating missing locations
                  }
                },
                child: Text(
                  "Approve",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Back",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDriverLocation();
    fetchTotalPriceData();
    _startListeningForOrders();
    locationSubscription = Geolocator.getPositionStream().listen((position) {
      _updateLocationMarker(position);
    });
  }

  @override
  void dispose() {
    super.dispose();
    locationSubscription?.cancel();
    _orderStreamSubscription?.cancel();
    _orderDataStreams.forEach((orderId, subscription) => subscription.cancel());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
        title: Text("Driver Dashboard"),
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                DriverDrawer(),
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
                        builder: (context) => EditDriverProfile(),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 30,
                ),
                ListTile(
                  tileColor: Color.fromARGB(255, 217, 226, 243),
                  leading: Icon(Icons.history_rounded),
                  title: Text("Deliver History"),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DriverHistory()));
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

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => driverLogin(),
                        ),
                      );
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
        child: Column(
          children: [
            Container(
              height: 400,
              width: double.infinity,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  // target: LatLng(0, 0),
                  target: orderLocation_ != null
                      ? orderLocation_!
                      : LatLng(latitudeDriver, longitudeDriver),
                  zoom: 16, // Set higher zoom for better tracking
                ),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                polylines: Set<Polyline>.of(polylines.values),

                markers: {
                  if (_driverMarker != null) _driverMarker!,
                  if (orderLocation_ != null)
                    Marker(
                      markerId: MarkerId('orderLocation'),
                      position: orderLocation_!,
                      infoWindow: InfoWindow(title: 'Order Location'),
                    ),
                  //..._orderMarkers
                  ..._orderMarkers.map((marker) {
                    return marker.copyWith(onTapParam: () async {
                      final orderId = marker.markerId.value;
                      setState(() {
                        orderIdAndUserID = orderId;
                      });
                      //if (!_orderDetailsMap.containsKey(orderId)) {
                      await _getUserData(orderId);
                      await _getOrderDetails(orderId);

                      //}
                      _showOrderDetailsDialog(orderId);
                      if (_userName != null) {
                        _showUserDetailsBottomSheet();
                      } else {
                        return;
                      }
                    });
                  }).toSet(),
                },
                myLocationEnabled: true, // Show user's blue dot
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "Follow the direction",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll(Colors.lightBlueAccent)),
              onPressed: () async {
                await updateOrderIsFinished(orderIdAndUserID);
                _clearPolyline();
                //await totalPriceSave(); 07/06/2024

                await _getOrderData(orderIdAndUserID);

                if (isFinished == false) {
                  await saveDilivered();
                  await driverHistory();
                }
              },
              child: Column(
                children: [
                  Icon(
                    Icons.gpp_good_outlined,
                    color: Colors.black,
                  ),
                  Text(
                    "Finished Order",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                      Color.fromARGB(255, 245, 51, 37))),
              onPressed: () async {
                await cancelOrder(orderIdAndUserID);
                _clearPolyline();
              },
              child: Column(
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    color: Colors.black,
                  ),
                  Text("Cancel Order",
                      style: TextStyle(fontSize: 16, color: Colors.black)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  Future<void> updateOrderStatus(String documentId) async {
    try {
      // Check if the document exists
      DocumentSnapshot documentSnapshot =
          await _FirestoreDriver.collection('Order').doc(documentId).get();
      if (documentSnapshot.exists) {
        // Update the 'Is_finished' field to true
        await _FirestoreDriver.collection('Order')
            .doc(documentId)
            .update({'Is_finished': true});
        print('Order status updated successfully.');
      } else {
        print('Order document with ID $documentId does not exist.');
      }
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  Future<void> totalPriceSave() async {
    await getOrderDetails(orderIdAndUserID);
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

  Future<void> fetchTotalPriceData() async {
    QuerySnapshot querySnapshot =
        await _FirestoreDriver.collection('Total_Price')
            .orderBy('Date',
                descending: true) // Change to true for descending order
            .get();

    List<QueryDocumentSnapshot> documents = querySnapshot.docs;

    // Process the documents as needed
    documents.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      print('Date: ${data['Date']}, Total: ${data['Total']}');
    });
  }

  Future<void> saveDilivered() async {
    Map<String, dynamic> deliveredData = {
      "Deliver_Id": generateCustomIDForDelivered(5),
      "Driver_Id": driver_id,
      "Order_Id": orderIDForTotal,
      "User_Id": _userId,
      "Quantity": quantity,
      "Date": date(),
      "Time": time(),
      "Is_Delivered": true,
    };

    await _deliversCollection.add(deliveredData);
  }

  String generateCustomIDForDelivered(int length) {
    const chars = 'Deli1234567890';
    Random random = Random();
    String uniqueID = String.fromCharCodes(List.generate(
        length, (index) => chars.codeUnitAt(random.nextInt(chars.length))));
    return uniqueID;
  }

  Future<void> driverHistory() async {
    Map<String, dynamic> driverHistoryData = {
      "Driver_id": driver_id,
      "User_name": _userName,
      "Address": _address,
      "Date": date(),
      "Time": time(),
      "Quantity": quantity,
    };

    await _driverHistoryCollection.add(driverHistoryData);
  }
}

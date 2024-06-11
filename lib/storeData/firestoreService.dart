// import 'package:cloud_firestore/cloud_firestore.dart';

// class FireStoreRegisterationData {
//   Future<void> storeData(
//       final fName, final mail, final pswrd, final contact, adres, nic) async {
//     try {
//       CollectionReference collRef =
//           FirebaseFirestore.instance.collection('client');

//       collRef.add({
//         await 'Full Name': fName,
//         await 'Email': mail,
//         await 'Password': pswrd,
//         await 'Mobile': contact,
//         await 'Address': adres,
//         await 'NIC': nic,
//       });
//     } on FirebaseException catch (error) {
//       print("Something went wrong..!");
//     }
//   }
// }

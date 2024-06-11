// import 'package:flutter/material.dart';
// import 'package:myapp/firebase_auth/firebase_auth_services.dart';
// import 'package:myapp/login_and_register/login.dart';
// import 'package:myapp/pages/dashboard.dart';

// class AuthHandler extends StatefulWidget {
//   const AuthHandler({super.key});

//   @override
//   State<AuthHandler> createState() => _AuthHandlerState();
// }

// class _AuthHandlerState extends State<AuthHandler> {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
      
//       stream: FirebaseAuthService().authStateChange,
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           return Dashboard();
//         } else {
//           return Login();
//         }
//       },
//     );
//   }
// }

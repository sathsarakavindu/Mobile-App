import 'dart:async';

import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  startTimer() {
    var duration = Duration(seconds: 2);
    return Timer(duration, () {
      route();
    });
  }

  route() {
    Navigator.pushNamed(context, "/Login");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.tealAccent,
      child: Container(
        child: Image.asset(
          "assets/images/waterGlassA.jpg",
        ),
        padding: EdgeInsets.all(50.0),
      ),
    );
  }
}

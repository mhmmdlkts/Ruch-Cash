import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  bool freeze;
  SplashScreen({this.freeze = false, super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: Center(
        child: widget.freeze?Container():const CircularProgressIndicator(),
      ),
    );
  }
}
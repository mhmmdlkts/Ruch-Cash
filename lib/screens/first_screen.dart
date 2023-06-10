import 'package:flutter/material.dart';
import 'package:rushcash/screens/splash_screen.dart';

import '../services/init_service.dart';
import 'home_page.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  bool showSplashScreen = true;

  @override
  void initState() {
    super.initState();
    InitService.init().then((val) { if (mounted) setState(() { showSplashScreen = false; }); });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InitService.isInited?_getBody():Container(),
        showSplashScreen?SplashScreen():Container(),
      ],
    );
  }

  Widget _getBody() => Scaffold(
    body: HomePage(),
  );
}
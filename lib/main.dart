import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rushcash/screens/first_screen.dart';
import 'package:rushcash/screens/splash_screen.dart';
import 'package:rushcash/services/firebase_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  int i = 0;
  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      // auth.FirebaseAuth.instance.signOut();
    }
    Future.delayed(const Duration(seconds: 3)).then((value) => {
      if (i < 2) {
        setState((){
          i = 2;
        })
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Shape Up',
        theme: ThemeData(
          /*colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: hellBlau,
            secondary: dunkelblau,
          ),*/
        ),
        home: StreamBuilder(
            stream: auth.FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.active) {
                return loading();
              }
              final user = snapshot.data;
              if (user == null) {
                return SignInScreen(
                  providers: [EmailAuthProvider()],
                );
              } else {
                if (++i >= 2) {
                  return const FirstScreen();
                } else {
                  return loading();
                }
              }
            }
        )
    );
  }

  Widget loading() => SplashScreen(freeze: true);
}

extension StringCasingExtension on String {
  bool get isNumber {
    try {
      double.parse(this);
    } catch (e) {
      return false;
    }
    return true;
  }
  Text toWidget({TextStyle? style}) => Text(this, style: style);
  String toCapitalized() => length > 0 ?'${this[0].toUpperCase()}${substring(1).toLowerCase()}':'';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');
  String get fixed {
    if (length == 1) {
      return '0$this';
    }
    return this;
  }
}
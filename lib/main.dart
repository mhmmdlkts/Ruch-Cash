import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rushcash/decoration/colors.dart';
import 'package:rushcash/screens/first_screen.dart';
import 'package:rushcash/screens/show_qr_code_screen.dart';
import 'package:rushcash/screens/splash_screen.dart';
import 'package:rushcash/services/firebase_service.dart';
import 'package:rushcash/services/saved_qr_service.dart';
import 'package:rushcash/widgets/qr_scanner_widget.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeApp();
  await SavedQrService.initQr();
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
    SavedQrService.listen('main', () {
      setState(() {});
    });

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
      title: 'Rush Cash',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: firstColor,
          secondary: secondColor,
          background: Colors.white,
        ),
      ),
      home: SavedQrService.qrData!=null?ShowQrCodeScreen(customerId: SavedQrService.qrData!):StreamBuilder(
        stream: auth.FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return loading();
          }
          final user = snapshot.data;
          if (user == null) {
            return welcomeScreen();
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

  bool isQrOpen = false;
  bool isSigningIn = false;
  Widget welcomeScreen() => Scaffold(
    appBar: AppBar(
      title: Text('Rush Cash'),
      leading: isSigningIn?IconButton(onPressed: () {
        setState(() {
          isSigningIn = false;
          isQrOpen = true;
        });
      }, icon: Icon(Icons.arrow_back_ios)):null,
    ),
    body: isSigningIn?SignInScreen(providers: [EmailAuthProvider()]):Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 50,
          ),
          SizedBox(
            width: 300,
            height: 300,
            child: InkWell(
              onTap: () {
                setState(() {
                  isQrOpen = !isQrOpen;
                });
              },
              child: isQrOpen?QrScannerWidget(onScan: (String? val) async {
                if (val != null) {
                  await SavedQrService.saveQr(val);
                }
              }):Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 10,
                  ),
                ),
                child: Icon(
                  Icons.qr_code,
                  size: 150,
                  color: Colors.grey,
                ),
              ),
            )
          ),
          Expanded(child: Container()),
          OutlinedButton(
            onPressed: () {
              setState(() {
                isSigningIn = true;
              });
            },
            child: Container(
              width: 250,
              child: Center(
                child: Text('Sign In'),
              ),
            ),
          ),
          SafeArea(
            child: SizedBox(
              height: 20,
            )
          ),
        ],
      ),
    )
  );
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
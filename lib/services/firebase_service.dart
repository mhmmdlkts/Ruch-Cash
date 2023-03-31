import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../firebase_options.dart';
import 'init_service.dart';

class FirebaseService {
  static const bool useEmulator = false;
  static const firebaseProjectName = 'rush-cash-a44fc';
  static const functionLocation = 'europe-west1';
  static const localHostString = '127.0.0.1';
  static const authPort = 9099;
  static const functionsPort = 5001;
  static const firestorePort = 8080;
  static const storagePort = 9199;

  static Future _connectToFirebaseEmulator() async {

    FirebaseFirestore.instance.settings = Settings(
      host: '$localHostString:$firestorePort',
      sslEnabled: false,
      persistenceEnabled: false
    );

    await FirebaseAuth.instance.useAuthEmulator(localHostString, authPort);
    await FirebaseStorage.instance.useStorageEmulator(localHostString, storagePort);
  }

  static Uri getUri(String functionName) => Uri(
    port: useEmulator?functionsPort:null,
    scheme: useEmulator?'http':'https',
    host: useEmulator?localHostString:'$functionLocation-$firebaseProjectName.cloudfunctions.net',
    path: useEmulator?'$firebaseProjectName/$functionLocation}/$functionName':functionName,
  );

  static initializeApp() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (useEmulator) {
      await _connectToFirebaseEmulator();
    }
  }

  static Future signOut() async {
    InitService.cleanCache();
    await FirebaseAuth.instance.signOut();
  }
}
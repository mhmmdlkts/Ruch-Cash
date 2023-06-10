import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rushcash/services/person_service.dart';
import '../models/bazaar.dart';
import '../models/person.dart';
import 'firestore_paths_service.dart';

class BazaarService {

  static bool _isInited = false;
  static late Bazaar bazaar;

  static Future initBazaar({DateTime? now}) async {
    DocumentSnapshot snapshot = await FirestorePathsService.getBazaarsDoc(bazaarId: PersonService.person.bazaar!).get();
    bazaar = Bazaar.fromSnapshot(snapshot);
    await bazaar.init();

    _isInited = true;
    if (now != null) {
      print('initBazaar took: ${DateTime.now().difference(now).inMilliseconds}');
    }
  }

  static bool isInited() => _isInited;
}
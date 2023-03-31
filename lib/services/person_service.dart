import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/person.dart';
import 'firestore_paths_service.dart';

class PersonService {

  static bool _isInited = false;
  static late Person person;

  static Future initPerson({DateTime? now}) async {
    DocumentSnapshot snapshot = await FirestorePathsService.getUserDoc().get();
    person = Person.fromSnapshot(snapshot);

    _isInited = true;
    if (now != null) {
      print('initPerson took: ${DateTime.now().difference(now).inMilliseconds}');
    }
  }

  static bool isInited() => _isInited;

  static cleanPerson() {
    _isInited = false;
  }
}
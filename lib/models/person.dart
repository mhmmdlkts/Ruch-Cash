import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore_paths_service.dart';

class Person {
  String? uid;
  String? email;
  String? name;
  String? bazaar;
  int? role;

  Person.create({required this.email}) {
    uid = null;
  }

  Person.fromSnapshot(DocumentSnapshot<Object?> snap) {
    if (snap.data() == null) {
      return;
    }
    Map<String, dynamic> o = snap.data() as Map<String, dynamic>;

    uid = snap.id;
    if (o.containsKey('email')) {
      email = o['email'];
    }
    if (o.containsKey('name')) {
      name = o['name'];
    }
    if (o.containsKey('role')) {
      role = o['role'];
    }
    if (o.containsKey('bazaar')) {
      bazaar = o['bazaar'];
    }
  }

  Map<String, dynamic> toJson({bool withNull = true}) {
    Map<String, dynamic> map = {
      'email': email,
      'name': name,
      'role': role,
      'bazaar': bazaar,
    };
    if (withNull) {
      return map;
    }
    Map<String, dynamic> newMap = {};
    map.forEach((key, value) {
      if (value != null) {
        newMap.addAll({key: value});
      }
    });
    return newMap;
  }

  Future push() async => await FirestorePathsService.getUserDoc().set(toJson());
  Future update() async => await FirestorePathsService.getUserDoc().update(toJson(withNull: false));
}

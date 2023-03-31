import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rushcash/models/stand.dart';

import '../services/firestore_paths_service.dart';

class Bazaar {
  String? id;
  String? name;
  List<Stand> stands = [];

  Bazaar.create({required this.name}) {
    id = null;
  }

  Bazaar.fromSnapshot(DocumentSnapshot<Object?> snap) {
    if (snap.data() == null) {
      return;
    }
    Map<String, dynamic> o = snap.data() as Map<String, dynamic>;

    id = snap.id;
    if (o.containsKey('name')) {
      name = o['name'];
    }
  }

  Map<String, dynamic> toJson({bool withNull = true}) {
    Map<String, dynamic> map = {
      'name': name,
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

  Future init() async {
    QuerySnapshot querySnapshot = await FirestorePathsService.getStandCol(bazaarId: id!).get();
    for (var element in querySnapshot.docs) {
      stands.add(Stand.fromSnapshot(element));
    }
  }

  Future push() async => await FirestorePathsService.getBazaarsDoc(bazaarId: id!).set(toJson());
  Future update() async => await FirestorePathsService.getBazaarsDoc(bazaarId: id!).update(toJson(withNull: false));
}

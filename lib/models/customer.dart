import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rushcash/models/stand.dart';

import '../services/firestore_paths_service.dart';

class Customer {
  String? id;
  late double balance;
  late String bazaar;

  Customer.create() {
    balance = 0;
  }

  Customer.fromSnapshot(DocumentSnapshot<Object?> snap) {
    if (snap.data() == null) {
      return;
    }
    Map<String, dynamic> o = snap.data() as Map<String, dynamic>;

    id = snap.id;
    if (o.containsKey('balance')) {
      balance = o['balance'];
    }
    if (o.containsKey('bazaar')) {
      bazaar = o['bazaar'];
    }
  }

  Map<String, dynamic> toJson({bool withNull = true}) {
    Map<String, dynamic> map = {
      'balance': balance,
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

  Future push() async => await FirestorePathsService.getCustomersDoc(customerKey: id!).set(toJson());
  Future update() async => await FirestorePathsService.getCustomersDoc(customerKey: id!).update(toJson(withNull: false));
}

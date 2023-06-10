import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rushcash/models/stand.dart';
import 'package:rushcash/models/stand_list.dart';

import '../services/firestore_paths_service.dart';

class Bazaar {
  String? id;
  String? name;
  double? totalSales;
  double? totalPayout;
  double? totalDeposit;
  List<Stand> stands = [];
  List<StandList> standLists = [];

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
    if (o.containsKey('totalSales')) {
      totalSales = o['totalSales'] + 0.0;
    } else {
      totalSales = 0;
    }
    if (o.containsKey('totalPayout')) {
      totalPayout = o['totalPayout'] + 0.0;
    } else {
      totalPayout = 0;
    }
    if (o.containsKey('totalDeposit')) {
      totalDeposit = o['totalDeposit'] + 0.0;
    } else {
      totalDeposit = 0;
    }
  }

  get cash => totalDeposit! - totalPayout!;

  Map<String, dynamic> toJson({bool withNull = true}) {
    Map<String, dynamic> map = {
      'name': name,
      'totalSales': totalSales,
      'totalPayout': totalPayout,
      'totalDeposit': totalDeposit,
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
      stands.add(Stand.fromSnapshot(element, id));
    }

    querySnapshot = await FirestorePathsService.getStandListCol(bazaarId: id!).get();
    for (var element in querySnapshot.docs) {
      StandList sl = StandList.fromSnapshot(element, id);
      standLists.add(sl);
    }
  }

  Future push() async => await FirestorePathsService.getBazaarsDoc(bazaarId: id!).set(toJson());
  Future update() async => await FirestorePathsService.getBazaarsDoc(bazaarId: id!).update(toJson(withNull: false));
}

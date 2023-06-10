import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rushcash/models/stand.dart';
import 'package:rushcash/services/bazaar_service.dart';
import '../services/firestore_paths_service.dart';

class StandList {

  String? id;
  String? bazaarId;
  String? name;
  List<Stand>? stands;

  StandList.create({required this.name}) {
    bazaarId = BazaarService.bazaar.id;
    stands = [];
    id = FirestorePathsService.getStandCol(bazaarId: bazaarId!).doc().id;
  }

  StandList.fromSnapshot(DocumentSnapshot<Object?> snap, this.bazaarId) {
    if (snap.data() == null) {
      return;
    }
    Map<String, dynamic> o = snap.data() as Map<String, dynamic>;

    id = snap.id;
    if (o.containsKey('name')) {
      name = o['name'];
    }
    if (o.containsKey('stands')) {
      stands = [];
      List.of(o['stands']!).forEach((element) {
        Stand s = BazaarService.bazaar.stands.where((e) => e.id == element).first;
        if (s != null) {
          stands!.add(s);
        }
      });
    }
  }

  double get price {
    double total = 0;
    stands?.forEach((element) {
      total += (element.price??0) * element.count;
    });
    return total;
  }

  int get elementCount {
    int count = 0;

    stands?.forEach((element) {
      count += element.count;
    });

    return count;
  }

  Map<String, dynamic> toJson({bool withNull = true}) {
    Map<String, dynamic> map = {
      'name': name,
      'stands': stands?.map((e) => e.id).toList(),
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

  Future push() async => await FirestorePathsService.getStandListDoc(bazaarId: bazaarId!, listId: id!).set(toJson());
  Future update() async => await FirestorePathsService.getStandListDoc(bazaarId: bazaarId!, listId: id!).update(toJson(withNull: false));

  bool contains(Stand stand) {
    return stands?.contains(stand)??false;
  }

  void add(Stand stand) {
    stands?.add(stand);
  }

  void remove(Stand stand) {
    stands?.removeWhere((element) {
      return element == stand;
    });
  }

  static StandList copy(StandList standList) {
    StandList cp = StandList.create(name: standList.name);
    cp.id = standList.id;
    cp.bazaarId = standList.bazaarId;
    cp.stands = [];
    standList.stands?.forEach((element) {
      cp.stands!.add(element);
    });
    return cp;
  }

  void reset() {
    stands?.forEach((element) {
      element.count = 0;
    });
  }
}
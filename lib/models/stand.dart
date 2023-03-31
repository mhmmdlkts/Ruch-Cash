import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rushcash/services/bazaar_service.dart';
import '../services/firestore_paths_service.dart';

class Stand {

  String? id;
  String? bazaarId;
  String? name;
  double? price;
  String? seller;

  Stand.create({required this.name, required this.price}) {
    bazaarId = BazaarService.bazaar.id;
    id = FirestorePathsService.getStandCol(bazaarId: bazaarId!).doc().id;
    BazaarService.bazaar.stands.add(this);
  }

  Stand.fromSnapshot(DocumentSnapshot<Object?> snap) {
    if (snap.data() == null) {
      return;
    }
    Map<String, dynamic> o = snap.data() as Map<String, dynamic>;

    id = snap.id;
    if (o.containsKey('name')) {
      name = o['name'];
    }
    if (o.containsKey('seller')) {
      seller = o['seller'];
    }
    if (o.containsKey('price')) {
      price = o['price'] + 0.0;
    }
  }

  String get readablePrice => '${price!.toStringAsFixed(2)} €';

  Map<String, dynamic> toJson({bool withNull = true}) {
    Map<String, dynamic> map = {
      'name': name,
      'price': price,
      'seller': seller,
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

  Future push() async => await FirestorePathsService.getStandDoc(bazaarId: bazaarId!, standId: id!).set(toJson());
  Future update() async => await FirestorePathsService.getStandDoc(bazaarId: bazaarId!, standId: id!).update(toJson(withNull: false));
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rushcash/models/stand_list.dart';
import 'package:rushcash/services/bazaar_service.dart';
import '../services/firestore_paths_service.dart';

class Stand {

  String? id;
  String? bazaarId;
  String? name;
  double? price;
  List<String>? seller;
  int? totalSales;
  int? status;
  int count = 0;

  Stand.create({required this.name, required this.price}) {
    bazaarId = BazaarService.bazaar.id;
    id = FirestorePathsService.getStandCol(bazaarId: bazaarId!).doc().id;
    BazaarService.bazaar.stands.add(this);
    totalSales = 0;
    status = 1;
  }

  Stand.fromSnapshot(DocumentSnapshot<Object?> snap, this.bazaarId) {
    if (snap.data() == null) {
      return;
    }
    Map<String, dynamic> o = snap.data() as Map<String, dynamic>;

    id = snap.id;
    if (o.containsKey('name')) {
      name = o['name'];
    }
    if (o.containsKey('seller')) {
      seller = List.of(o['seller']??[]).map((e) => e.toString()).toList();
    }
    if (o.containsKey('price')) {
      price = o['price'] + 0.0;
    }
    if (o.containsKey('status')) {
      status = o['status'];
    }
    if (o.containsKey('totalSales')) {
      try {
        totalSales = o['totalSales'];
      } catch (e) {
        try {
          totalSales  = (o['totalSales'] as double).toInt();
        } catch (e) {
          totalSales = 0;
        }
      }
    } else {
      totalSales = 0;
    }
  }

  String get readablePrice => '${price!.toStringAsFixed(2)} €';

  double get totalSalesPrice => (totalSales??0) * (price??0);

  Map<String, dynamic> toJson({bool withNull = true}) {
    Map<String, dynamic> map = {
      'name': name,
      'price': price,
      'seller': seller,
      'totalSales': totalSales,
      'status': status,
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

  Future changeStatus(int i) async {
    await FirestorePathsService.getStandDoc(bazaarId: bazaarId!, standId: id!).update({
      'status': i
    });
    status = i;
  }

  StandList toStandList() {
    StandList sl = StandList.create(name: name);
    sl.add(this);
    return sl;
  }
}
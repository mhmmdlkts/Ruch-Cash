import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rushcash/models/stand.dart';
import 'package:rushcash/models/stand_list.dart';
import 'package:rushcash/services/bazaar_service.dart';
import '../services/firestore_paths_service.dart';

class Basket {

  StandList standList;
  Map<Stand, int>? stands;

  Basket({required this.standList}) {
    standList.stands?.forEach((element) {
      stands?[element] = 0;
    });
  }
}
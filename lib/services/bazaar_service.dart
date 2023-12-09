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

  static Future resetBazaar() async {
    await Future.wait([
      _resetCustomers(),
      _resetTotalSales(bazaar.id!),
      _resetStats(bazaar.id!),
    ]);
  }

  static Future _resetStats(String bazaarId) async {
    DocumentReference documentRef = FirestorePathsService.getBazaarsDoc(bazaarId: bazaarId);

    await documentRef.update({
      'totalDeposit': 0,
      'totalPayout': 0,
      'totalSales': 0,
    });
  }

  static Future<void> _resetCustomers() async {
    CollectionReference customersCollection = FirestorePathsService.getCustomersCol();
    QuerySnapshot customersQuerySnapshot = await customersCollection.get();

    for (DocumentSnapshot customerDocSnapshot in customersQuerySnapshot.docs) {
      CollectionReference historySubcollection =
      customerDocSnapshot.reference.collection('history');

      QuerySnapshot historyQuerySnapshot = await historySubcollection.get();

      for (DocumentSnapshot historyDocSnapshot in historyQuerySnapshot.docs) {
        await historyDocSnapshot.reference.delete();
      }

      await customerDocSnapshot.reference.delete();
    }
  }


  static Future _resetTotalSales(String bazaarId) async {
    CollectionReference standsCollection = FirestorePathsService.getStandCol(bazaarId: bazaarId);

    QuerySnapshot querySnapshot = await standsCollection.get();

    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      String standId = documentSnapshot.id;
      DocumentReference standRef = standsCollection.doc(standId);

      await standRef.update({
        'totalSales': 0,
      });
    }
  }
}
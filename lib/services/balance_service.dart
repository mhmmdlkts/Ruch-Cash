import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rushcash/services/firestore_paths_service.dart';

import '../models/stand.dart';

class BalanceService {

  static Future<double> getUserBalance(String userId) async {
    DocumentReference ref = FirestorePathsService.getCustomersDoc(customerKey: userId);

    DocumentSnapshot snapshot = await ref.get();

    if (!snapshot.exists) {
      throw Exception("Benutzerdokument nicht vorhanden");
    }

    return snapshot.get('balance');
  }


  static Future addBalance(String id, double balance) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference ref = FirestorePathsService.getCustomersDoc(customerKey: id);
    await firestore.runTransaction((transaction) async {
      // Lesen des aktuellen Dokuments
      DocumentSnapshot snapshot = await transaction.get(ref);

      double currentBalance;

      if (!snapshot.exists) {
        // Erstellen des Benutzers, wenn er nicht vorhanden ist
        currentBalance = 0;
        transaction.set(ref, {'balance': currentBalance});
      } else {
        // Aktualisieren des Saldos
        currentBalance = snapshot.get('balance');
      }

      double updatedBalance = currentBalance + balance;

      // Schreiben der neuen Bilanz in die Datenbank
      transaction.update(ref, {'balance': updatedBalance});

      // Erstellen eines neuen Eintrags in der 'history'-Sammlung
      CollectionReference historyRef = ref.collection('history');
      await historyRef.add({
        'timestamp': Timestamp.now(),
        'oldBalance': currentBalance,
        'newBalance': updatedBalance,
        'userId': FirebaseAuth.instance.currentUser!.uid!,
        'action': 'Add Cash',
      });
    }).catchError((error) {
      print('Fehler beim Hinzufügen des Guthabens: $error');
    });
  }

  static Future sellItem(String customerId, Stand stand, int count) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference customerRef = FirestorePathsService.getCustomersDoc(customerKey: customerId);
    await firestore.runTransaction((transaction) async {
      // Lesen des aktuellen Kundendokuments
      DocumentSnapshot customerSnapshot = await transaction.get(customerRef);

      if (!customerSnapshot.exists) {
        throw Exception("Kunde nicht vorhanden");
      }

      // Aktualisieren des Kunden-Guthabens
      double currentBalance = customerSnapshot.get('balance');
      double totalPrice = stand.price! * count;
      if (currentBalance < totalPrice) {
        throw Exception("Nicht genügend Guthaben");
      }

      double updatedBalance = currentBalance - totalPrice;
      transaction.update(customerRef, {'balance': updatedBalance});

      // Erstellen eines neuen Eintrags in der 'history'-Sammlung des Kunden
      CollectionReference customerHistoryRef = customerRef.collection('history');
      await customerHistoryRef.add({
        'timestamp': Timestamp.now(),
        'oldBalance': currentBalance,
        'newBalance': updatedBalance,
        'userId': FirebaseAuth.instance.currentUser!.uid!,
        'action': 'Sell Item',
        'standId': stand.id,
        'standName': stand.name,
        'count': count,
        'pricePerItem': stand.price,
        'totalPrice': totalPrice,
      });

      // Optional: Aktualisieren der Stand-Statistiken oder Lagerbestände
    }).catchError((error) {
      print('Fehler beim Verkaufen des Artikels: $error');
    });
  }
}

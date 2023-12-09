import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rushcash/models/stand_list.dart';
import 'package:rushcash/services/bazaar_service.dart';
import 'package:rushcash/services/firestore_paths_service.dart';

import '../models/stand.dart';
import '../widgets/feedback_popup_widget.dart';

class BalanceService {

  static Future<double> getUserBalance(String userId) async {
    DocumentReference ref = FirestorePathsService.getCustomersDoc(customerKey: userId);

    DocumentSnapshot snapshot = await ref.get();

    if (!snapshot.exists) {
      return 0.0;
    }

    return snapshot.get('balance') + 0.0;
  }



  static Future<bool> addBalance(String id, double balance, String bazaarId, {bool isLocked = false, required BuildContext context}) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference ref = FirestorePathsService.getCustomersDoc(customerKey: id);
    DocumentReference bazaarRef = FirestorePathsService.getBazaarsDoc(bazaarId: bazaarId);
    bool success = false;

    await firestore.runTransaction((transaction) async {
      // Lesen des aktuellen Dokuments und des Bazaar-Dokuments
      DocumentSnapshot snapshot = await transaction.get(ref);
      DocumentSnapshot bazaarSnapshot = await transaction.get(bazaarRef);

      print(ref.path);
      print(bazaarRef.path);

      double currentBalance;

      if (!snapshot.exists) {
        // Erstellen des Benutzers, wenn er nicht vorhanden ist
        currentBalance = 0;
        transaction.set(ref, {
          'balance': currentBalance,
          'locked': isLocked
        });
      } else {
        // Aktualisieren des Saldos
        currentBalance = snapshot.get('balance') + 0.0;
      }

      double updatedBalance = currentBalance + balance;

      // Überprüfen, ob der aktualisierte Saldo nicht negativ ist
      if (updatedBalance >= 0) {
        // Schreiben der neuen Bilanz in die Datenbank
        transaction.update(ref, {'balance': updatedBalance});

        // Aktualisieren der totalDeposit oder totalPayout im Bazaar-Dokument
        double currentTotalDeposit = bazaarSnapshot.get('totalDeposit') + 0.0;
        double currentTotalPayout = bazaarSnapshot.get('totalPayout') + 0.0;

        if (balance > 0) {
          transaction.update(bazaarRef, {'totalDeposit': currentTotalDeposit + balance});
        } else {
          transaction.update(bazaarRef, {'totalPayout': currentTotalPayout - balance});
        }

        // Erstellen eines neuen Eintrags in der 'history'-Sammlung
        CollectionReference historyRef = ref.collection('history');
        await historyRef.add({
          'timestamp': Timestamp.now(),
          'oldBalance': currentBalance,
          'newBalance': updatedBalance,
          'userId': FirebaseAuth.instance.currentUser!.uid!,
          'action': balance>=0?'Add Cash':'Payout Cash',
        });

        success = true;
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return FeedbackPopupWidget(
              errorMessage: 'Der Auszahlungsbetrag darf das Guthaben nicht übersteigen.',
            );
          },
        );
        return false;
      }
    }).catchError((error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return FeedbackPopupWidget(
            errorMessage: 'Fehler beim Hinzufügen des Guthabens: $error',
          );
        },
      );
      return false;
    });

    return success;
  }

  static Future sellItems(String customerId, List<Stand> stands) async {

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference customerRef = FirestorePathsService.getCustomersDoc(customerKey: customerId);
    DocumentReference bazaarRef = FirestorePathsService.getBazaarsDoc(bazaarId: stands.first.bazaarId!);
    List<StandDocument> standDocs = [];
    for (var element in stands) {
      standDocs.add(StandDocument(id: element.id!, documentReference: FirestorePathsService.getStandDoc(bazaarId: element.bazaarId!, standId: element.id!)));
    }

    await firestore.runTransaction((transaction) async {
      // Lesen des aktuellen Kundendokuments, Bazaar- und Stand-Dokuments
      DocumentSnapshot customerSnapshot = await transaction.get(customerRef);
      DocumentSnapshot bazaarSnapshot = await transaction.get(bazaarRef);
      for (var element in standDocs) {
        element.documentSnapshot = await transaction.get(element.documentReference);
      }

      if (!customerSnapshot.exists) {
        throw Exception("Kunde nicht vorhanden");
      }

      // Aktualisieren des Kunden-Guthabens
      double currentBalance = customerSnapshot.get('balance') + 0.0;
      double totalPrice = 0;
      stands.forEach((element) {
        totalPrice += (element.price??0) * element.count;
      });
      if (currentBalance < totalPrice) {
        throw Exception("Nicht genügend Guthaben");
      }

      double updatedBalance = currentBalance - totalPrice;

      // Aktualisieren der totalSales im Bazaar- und Stand-Dokument
      double currentBazaarTotalSales = bazaarSnapshot.get('totalSales') + 0.0;
      double updatedBazaarTotalSales = currentBazaarTotalSales + totalPrice;
      List<String> summary = [];
      for (var standDoc in standDocs) {

        Stand stand = Stand.fromSnapshot(standDoc.documentSnapshot!, BazaarService.bazaar.id);
        stand.count = stands.where((element) => element.id == stand.id).first.count;
        if (stand.count != 0) {
          summary.add('${stand.id}, ${stand.name}, ${stand.price?.toStringAsFixed(2)} €, ${stand.count}}');
        }

        int currentStandTotalSales = 0;

        try {
          currentStandTotalSales = standDoc.documentSnapshot?.get('totalSales');
        } catch (e) {
          try {
            currentStandTotalSales  = (standDoc.documentSnapshot?.get('totalSales') as double).toInt();
          } catch (e) {
            currentStandTotalSales = 0;
          }
        }

        int updatedStandTotalSales = currentStandTotalSales + stand.count;
        transaction.update(standDoc.documentReference, {'totalSales': updatedStandTotalSales});
      }

      transaction.update(customerRef, {'balance': updatedBalance});
      transaction.update(bazaarRef, {'totalSales': updatedBazaarTotalSales});
      // Erstellen eines neuen Eintrags in der 'history'-Sammlung des Kunden
      CollectionReference customerHistoryRef = customerRef.collection('history');
      await customerHistoryRef.add({
        'timestamp': Timestamp.now(),
        'oldBalance': currentBalance,
        'newBalance': updatedBalance,
        'userId': FirebaseAuth.instance.currentUser!.uid!,
        'action': 'Sell Item',
        'summary': summary,
        'totalPrice': totalPrice,
      });

      // Optional: Aktualisieren der Stand-Statistiken oder Lagerbestände
    }).catchError((error) {
      throw Exception('Fehler beim Verkaufen des Artikels: $error');
    });
  }
}

class StandDocument {
  String id;
  DocumentReference documentReference;
  DocumentSnapshot? documentSnapshot;

  StandDocument({required this.id, required this.documentReference});
}
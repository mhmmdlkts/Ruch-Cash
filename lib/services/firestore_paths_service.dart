import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestorePathsService {

  static const String _usersKey = "users";
  static const String _bazaarsKey = "bazaars";
  static const String _standKey = "stand";
  static const String _listsKey = "lists";
  static const String _customersKey = "customers";

  static CollectionReference getUsersCol() => FirebaseFirestore.instance.collection(_usersKey);
  static DocumentReference getUserDoc({String? userId}) => getUsersCol().doc(userId??FirebaseAuth.instance.currentUser!.uid);

  static CollectionReference getBazaarsCol() => FirebaseFirestore.instance.collection(_bazaarsKey);
  static DocumentReference getBazaarsDoc({required String bazaarId}) => getBazaarsCol().doc(bazaarId);

  static CollectionReference getCustomersCol() => FirebaseFirestore.instance.collection(_customersKey);
  static DocumentReference getCustomersDoc({required String customerKey}) => getCustomersCol().doc(customerKey);

  static CollectionReference getStandCol({required String bazaarId}) => FirebaseFirestore.instance.collection(_bazaarsKey).doc(bazaarId).collection(_standKey);
  static DocumentReference getStandDoc({required String bazaarId, required String standId}) => getStandCol(bazaarId: bazaarId).doc(standId);

  static CollectionReference getStandListCol({required String bazaarId}) => FirebaseFirestore.instance.collection(_bazaarsKey).doc(bazaarId).collection(_listsKey);
  static DocumentReference getStandListDoc({required String bazaarId, required String listId}) => getStandListCol(bazaarId: bazaarId).doc(listId);
}
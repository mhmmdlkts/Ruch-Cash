import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rushcash/screens/sell_screen.dart';

import '../models/stand.dart';

class AllStandsScreen extends StatefulWidget {
  const AllStandsScreen({Key? key}) : super(key: key);

  @override
  State<AllStandsScreen> createState() => _AllStandsScreenState();
}

class _AllStandsScreenState extends State<AllStandsScreen> {
  List<Stand> stands = [];
  @override
  void initState() {
    super.initState();
    initStands();
  }

  Future initStands() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String authId = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot bazaarsSnapshot = await firestore.collection('bazaars').get();

    List<Stand> fetchedStands = [];

    for (DocumentSnapshot bazaarDoc in bazaarsSnapshot.docs) {
      QuerySnapshot standsSnapshot = await bazaarDoc.reference.collection('stand').where('seller', isEqualTo: authId).get();

      for (DocumentSnapshot standDoc in standsSnapshot.docs) {
        Stand s = Stand.fromSnapshot(standDoc);
        fetchedStands.add(s);
      }
    }

    setState(() {
      stands = fetchedStands;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Bar'),
      ),
      body: ListView.builder(
        itemCount: stands.length,
        itemBuilder: (ctx, i) => InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SellScreen(stand: stands[i]),
                )
            );
          },
          child: ListTile(
            title: Text(stands[i].name!),
            subtitle: Text(stands[i].price!.toStringAsFixed(2)),
          ),
        )
      ),
    );
  }
}

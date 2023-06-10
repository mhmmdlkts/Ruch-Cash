import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rushcash/models/stand_list.dart';
import 'package:rushcash/screens/sell_screen.dart';
import 'package:rushcash/services/bazaar_service.dart';

import '../models/stand.dart';

class AllStandsScreen extends StatefulWidget {
  const AllStandsScreen({Key? key}) : super(key: key);

  @override
  State<AllStandsScreen> createState() => _AllStandsScreenState();
}

class _AllStandsScreenState extends State<AllStandsScreen> {
  //List<Stand> stands = [];
  List<StandList> standLists = [];
  @override
  void initState() {
    super.initState();
    initStands();
  }

  Future initStands() async {


    setState(() {
      standLists = BazaarService.bazaar.standLists;
    });
    return;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String authId = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot bazaarsSnapshot = await firestore.collection('bazaars').get();

    List<StandList> fetchedStands = [];

    for (DocumentSnapshot bazaarDoc in bazaarsSnapshot.docs) {
      //QuerySnapshot standsSnapshot = await bazaarDoc.reference.collection('stand').where('seller', arrayContains: authId).get();
      QuerySnapshot standsSnapshot = await bazaarDoc.reference.collection('lists').get();

      for (DocumentSnapshot standDoc in standsSnapshot.docs) {
        StandList s = StandList.fromSnapshot(standDoc, BazaarService.bazaar.id);
        fetchedStands.add(s);
      }
    }

    setState(() {
      standLists = fetchedStands;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stands'),
      ),
      body: ListView.builder(
        itemCount: standLists.length,
        itemBuilder: (ctx, i) => InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SellScreen(standList: standLists[i]),
                )
            );
          },
          child: ListTile(
            title: Text(standLists[i].name!),
            subtitle: Text('${standLists[i].stands?.length} Items'),
          ),
        )
      ),
    );
  }
}

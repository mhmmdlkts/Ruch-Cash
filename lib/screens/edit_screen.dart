import 'package:flutter/material.dart';
import 'package:rushcash/screens/add_stand_screen.dart';
import 'package:rushcash/services/bazaar_service.dart';
import 'package:rushcash/widgets/custom_button.dart';

import '../models/stand.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({Key? key}) : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(BazaarService.bazaar.name!),
      ),
      body: ListView.builder(
        itemBuilder: (ctx, i) {
          Stand stand = BazaarService.bazaar.stands[i];
          return ListTile(
            title: Text(stand.name!),
            subtitle: Text(stand.readablePrice),
          );
        },
        itemCount: BazaarService.bazaar.stands.length,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddStandScreen(),
              )
          );
          setState(() {});
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:rushcash/screens/add_stand_screen.dart';
import 'package:rushcash/services/bazaar_service.dart';
import 'package:rushcash/widgets/custom_button.dart';

import '../models/stand.dart';
import '../models/stand_list.dart';
import 'add_list_screen.dart';

class EditListScreen extends StatefulWidget {
  final StandList? standList;
  const EditListScreen({this.standList, Key? key}) : super(key: key);

  @override
  State<EditListScreen> createState() => _EditListScreenState();
}

class _EditListScreenState extends State<EditListScreen> {


  late final StandList standList;
  @override
  void initState() {
    super.initState();
    if (widget.standList != null) {
      standList = StandList.copy(widget.standList!);
    } else {
      standList = StandList.create(name: '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(BazaarService.bazaar.name!),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(15),
                child: TextFormField(
                  initialValue: standList.name,
                  decoration: InputDecoration(
                    hintText: 'List Name'
                  ),
                  onChanged: (String val) {
                    setState(() {
                      standList.name = val;
                    });
                  },
                ),
              ),
              Expanded(
                child: allStands()
              ),
              Container(height: 50)
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(standList);
              },
              child: const Padding(
                padding: EdgeInsets.only(top: 20),
                child: SafeArea(
                  child: Text('Save'),
                ),
              )
            ),
          )
        ],
      )
    );
  }

  Widget checkBox(bool isChecked) {
    return Checkbox(
      value: isChecked,
      onChanged: null
    );
  }


  Widget allStands() => ListView.builder(
    shrinkWrap: true,
    itemBuilder: (ctx, i) {
      Stand stand = BazaarService.bazaar.stands[i];
      return InkWell(
        onTap: () {
          if (standList.contains(stand)) {
            standList.remove(stand);
          } else {
            standList.add(stand);
          }
          setState(() {});
        },
        child: ListTile(
          title: Text(stand.name!),
          subtitle: Text(stand.readablePrice),
          trailing: checkBox(standList.contains(stand)),
        ),
      );
    },
    itemCount: BazaarService.bazaar.stands.length,
  );
}

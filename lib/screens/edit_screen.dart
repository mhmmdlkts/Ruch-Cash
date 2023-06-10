import 'package:flutter/material.dart';
import 'package:rushcash/screens/add_stand_screen.dart';
import 'package:rushcash/screens/edit_list_screen.dart';
import 'package:rushcash/services/bazaar_service.dart';
import 'package:rushcash/widgets/custom_button.dart';

import '../models/stand.dart';
import '../models/stand_list.dart';
import 'add_list_screen.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({Key? key}) : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(BazaarService.bazaar.name!),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.table_bar)),
              Tab(icon: Icon(Icons.list)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            allStands(),
            allLists(),
          ],
        ),
      )
    );
  }

  Widget? getStatus(Stand stand) {
    switch (stand.status) {
      case 0:
        return IconButton(
          icon: Icon(Icons.circle, color: Colors.red),
          onPressed: () async {
            await stand.changeStatus(1);
            setState(() {});
          },
        );
      case 1:
        return IconButton(
          icon: Icon(Icons.circle, color: Colors.green),
          onPressed: () async {
            await stand.changeStatus(0);
            setState(() {});
          },
        );
    }
  }

  Widget allStands() => Stack(
    children: [
      ListView.builder(
        itemBuilder: (ctx, i) {
          Stand stand = BazaarService.bazaar.stands[i];
          return ListTile(
            title: Text(stand.name!),
            subtitle: Text(stand.readablePrice),
            trailing: getStatus(stand),
          );
        },
        itemCount: BazaarService.bazaar.stands.length,
      ),
      Positioned(
        bottom: 16,
        right: 16,
        child: SafeArea(
          child: FloatingActionButton(
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
        ),
      )
    ],
  );

  Widget allLists() => Stack(
    children: [
      ListView.builder(
        itemBuilder: (ctx, i) {
          StandList list = BazaarService.bazaar.standLists[i];
          return InkWell(
            onTap: () async {
              StandList? standList = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditListScreen(standList: list),
                )
              );
              if (standList != null) {
                list = standList;
                BazaarService.bazaar.standLists[i] = list;
                await list.update();
              }
              setState(() {});
            },
            child: ListTile(
              title: Text(list.name!),
              subtitle: Text('${list.stands?.length??0} Stands'),
            ),
          );
        },
        itemCount: BazaarService.bazaar.standLists.length,
      ),
      Positioned(
        bottom: 16,
        right: 16,
        child: SafeArea(
          child: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () async {
              StandList? standList = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditListScreen(),
                  )
              );
              if (standList != null) {
                BazaarService.bazaar.standLists.add(standList);
                await standList.push();
              }
              setState(() {});
            },
          ),
        ),
      )
    ],
  );
}
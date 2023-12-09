import 'package:flutter/material.dart';
import 'package:rushcash/models/bazaar.dart';
import 'package:rushcash/models/stand.dart';
import 'package:rushcash/services/bazaar_service.dart';
import 'package:rushcash/services/person_service.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({Key? key}) : super(key: key);

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Status'),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            statusItem('Kassa', bazaar.cash),
            SizedBox(height: 10.0),
            statusItem('Total Sales', bazaar.totalSales??0),
            SizedBox(height: 10.0),
            statusItem('Deposit', bazaar.totalDeposit??0),
            SizedBox(height: 10.0),
            statusItem('Payout', bazaar.totalPayout??0),
            SizedBox(height: 10.0),
            Divider(),
            SizedBox(height: 10.0),
            ListView(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: stands().map((e) => statusItem(e.name??'', e.totalSalesPrice, asFixed: 2)).toList(),
            ),
            if (PersonService.person.role! >= 6)
              ElevatedButton(
                onPressed: () {},
                onLongPress: () async {
                  await _showResetConfirmationDialog();
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Reset'),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Future _showResetConfirmationDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Zurücksetzen bestätigen'),
          content: Text('Sind Sie sicher, dass Sie es zurücksetzen möchten?'),
          actions: [
            TextButton(
              onPressed: () async {
                await BazaarService.resetBazaar();
                Navigator.of(context).pop();
              },
              child: Text('Ja'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Nein'),
            ),
          ],
        );
      },
    );
  }


  List<Stand> stands () {
    return BazaarService.bazaar.stands;
  }

  Future<void> refresh() async {
    await BazaarService.initBazaar();
    setState(() {});
  }

  Bazaar get bazaar => BazaarService.bazaar;

  Widget statusItem(String title, double value, {int asFixed = 2, String? subfix = '€'}) {
    return Card(
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          '${value.toStringAsFixed(asFixed)} ${subfix??''}',
          style: TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }
}

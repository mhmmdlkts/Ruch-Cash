import 'package:flutter/material.dart';
import 'package:rushcash/models/bazaar.dart';
import 'package:rushcash/models/stand.dart';
import 'package:rushcash/services/bazaar_service.dart';

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
              children: stands().map((e) => statusItem(e.name??'', e.totalSalesPrice, asFixed: 0, subfix: null)).toList(),
            )
          ],
        ),
      ),
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
